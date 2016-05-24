function [B, RSS, exitflag, bootSE, bootCI] = sigmoidfit(x,y,varargin)
% Fits a sigmoid of the form
% y = 1/(1+e^-(b*(x-a)))
% to the data in x and y,
% where b is a vector of slopes for each dimension of x, and a is a vector
% of locations (thresholds) for each dimension of x.
% sigmoidfit returns the array
%           [a_j;
%            b_j]
% for each predictor Xj of y, ignoring rows x_i where x_ij or y_i are NaN.
%
% B = sigmoidfit(x,y)
% [B, RSS] = sigmoidfit(x,y)
% [B, RSS, exitflag] = sigmoidfit(x,y)
% [B, RSS, exitflag, bootSE, bootCI] = sigmoidfit(x,y)
% where     B       is a 2 x nDimensions matrix of locations (thresholds)
%                       and slopes for each dimension in the columns of x.
%                       B(1,:) is the location of the sigmoid along each
%                       dimension in x, or the x point at which y=0.5.
%                       B(2,:) is the slope of the sigmoid along each
%                       dimension in x, or the odds increase for a unit
%                       increase in x.
%           RSS     is a scalar specifying the minimum-residual sum of
%                       squares of the fit
%           exitflag is a flag from fminsearch specifying whether the fit
%                       blew up or not.
%                           1           fminsearch converged to a solution x.
%                           0           Maximum number of function evaluations or iterations was reached.
%                           -1          Algorithm was terminated by the output function.
%           bootSE  is a 2 x nDim matrix of the standard error of
%                       the location and slope, as estimated by a
%                       bootstrapping procedure
%           bootCI  is a 2 x nDim x 2 matrix of the bounds of the
%                       confidence interval around the location and slope,
%                       as estimated by a bootstrapping procedure
%                       bootCI(:,:,1) provides the lower bound of location
%                       and slope for each dimension,
%                       bootCI(:,:,2) provides the upper bound of location
%                       and slope for each dimension,
%                       bootCI(1,:,:) provides the lower and upper bounds
%                       of the location for each dimension,
%                       bootCI(2,:,:) provides the lower and upper bounds
%                       of the slope for each dimension.
%
%           x       is a 1 x n,
%                        n x 1, or
%                        n x nDim
%                       array of x values for the predictor(s) of the
%                       sigmoid
%           y       is a 1 x n or n x 1 vector of outcome values.
%
% OPTIONAL ARGUMENTS:
% ******************
%
% Statistics settings:
% 
% removeNaNs        (true)
%   Removes entire case (y value and all related x values) for any outcome
%   or predictor that is NaN. If false, replaces NaN with the mean. When
%   calculating the bootstrap-derived standard error and confidence
%   interval, when replacing missing values with the mean, the mean will be
%   re-calculated on every re-sampling.
% alpha             (0.05)
%   level at which to evaluate the confidence interval, estimated by
%   bootstrap resampling.
% nboot             (minimum such that number of samples in each tail is
%                   at least 10)
%   The number of samples to use in the bootstrapping procedure. Smaller
%   values are more inaccurate, while larger values will be computationally
%   demanding.
%   The equation used to derive the default value is
%   10^(ceil(-log10(alpha/2))+1),
%   which ensures that at alpha=0.05, using 1000 samples will result in 25
%   in each of the tails.
% 
% Nonlinear optimizer settings:
% LB                ([])
%   Lower bound on the allowed values of B. Default is no bounds.
% UB                ([])
%   Upper bound on the allowed values of B. Default is no bounds.
% Algorithm         ('interior-point')
%   Algorithm for iteratively finding the minimum least-squares solution to
%   the best fitting values of B. Valid values are
%       'interior-point'
%       'trust-region-reflective'
%       'sqp'
%       'active-set'
% Display           ('off')
%   Display progress. Valid values are
%       'off'       no output
%       'iter'      output each iteration
%       'final'     final output
%       'notify'    output only if did not converge
% FunValCheck       ('off')
% 	Check whether objective function values are valid. 'on' displays an
% 	error when the objective function returns a value that is complex, Inf
% 	or NaN. 'off' (the default) displays no error.
% MaxFunEvals       ('200*numberofvariables')
% 	Maximum number of function evaluations allowed
% MaxIter           ('200*numberofvariables')
% 	Maximum number of iterations allowed
% OutputFcn         ([])
% 	User-defined function that is called at each iteration. See Output
% 	Functions in MATLAB Mathematics for more information.
% PlotFcns          ([])
% 	Plots various measures of progress while the algorithm executes, select
% 	from predefined plots or write your own. Pass a function handle or a
% 	cell array of function handles. The default is none ([]).
% 		@optimplotx plots the current point
% 		@optimplotfval plots the function value
% 		@optimplotfunccount plots the function count
% 		See Plot Functions in MATLAB Mathematics for more information.
% TolFun            (1e-4)
% 	Termination tolerance on the loss (error/RSS) function
% TolX              (1e-4)
% 	Termination tolerance on B
%

% X must be a 2D array.
assert(length(size(x))==2,'x must be 2D array: 1 x n, n x 1, or n x nDim.');

% If single row vector, turn into column vector.
if size(x,2)>1&&size(x,1)==1
    x = x(:);
end
% Otherwise, treat each column as a dimension of x.
y = y(:);

Algorithm = 'interior-point';           % fminsearch algorithm
Display = 'off';                        % fminsearch display option
FunValCheck='off';                      % fminsearch check each iteration
MaxFunEvals='200*numberofvariables';    % fminsearch loss function evaluations
MaxIter='200*numberofvariables';        % fminsearch iterations
OutputFcn=[];                           % fminsearch output function each iteration
PlotFcns=[];                            % fminsearch plotting function each iteration
TolFun=1e-4;                            % fminsearch loss function change tolerance
TolX=1e-4;                              % fminsearch parameter change tolerance
LB = -inf(2,size(x,2));                 % fmincon lower bound
UB = inf(2,size(x,2));                  % fmincon upper bound

removeNaNs = true;                      % Remove all y values where at least one x is NaN
alpha = 0.05;                           % confidence level
process_varargin(varargin);
nboot = 10^(ceil(-log10(alpha/2))+1);   % number of boots in resampling procedure
process_varargin(varargin);

assert(length(y)==size(x,1),'Each outcome observation must have at least one predictor. Length of y should be equal to the number of rows in x.')
assert(all(y==1|y==0),'Outcome vector must be only 1''s and 0''s.')
idNan = isnan(x)|isnan(repmat(y,[1 size(x,2)]));
if any(idNan(:))
    if removeNaNs
        disp(['Removing ' num2str(sum(double(idNan(:)))) ' NaNs from the data set...'])
        incl = all(~idNan,2);
        X = x(incl,:);
        Y = y(incl);
    else
        disp([num2str(sum(double(isnan(x(:))))) ' NaNs along x dimensions replaced with mean x...'])
        X = x;
        for iDim=1:size(x,2)
            X(idNan(:,iDim),iDim) = nanmean(x(idNan(:,iDim),iDim));
        end
        disp([num2str(sum(double(isnan(y)))) ' NaNs along y replaced with mean y...'])
        Y = y;
        y(isnan(y)) = nanmean(y);
    end
else
    X = x;
    Y = y;
end

bGLM = glmfit(X,Y,'binomial');  % Start by finding the GLM solution.
a0 = min(max(min(X),bGLM(1,:)./(-bGLM(2,:))),max(X));   
% Starting values of location parameters, -glm intercept/slope, restricted
% between the lowest and highest x values.
b0 = bGLM(2,:);                 
% Starting values of slope parameters.

B0 = [a0(:)'; b0(:)'];
% Start values of location/slope.

options = optimset('Algorithm',Algorithm, ...
                   'Display',Display, ...
                   'FunValCheck',FunValCheck, ...
                   'MaxFunEvals',MaxFunEvals, ...
                   'MaxIter',MaxIter, ...
                   'OutputFcn',OutputFcn, ...
                   'PlotFcns',PlotFcns, ...
                   'TolFun',TolFun, ...
                   'TolX',TolX);

if all(isinf(LB)); LB = []; end
if all(isinf(UB)); UB = []; end

if ~isempty(LB)||~isempty(UB)
    [B, RSS, exitflag] = fmincon(@(B) LSerrfun(B,X,Y,@sigmoidval), B0(:), [], [], [], [], LB, UB, [], options);
else
    [B, RSS, exitflag] = fminsearch(@(B) LSerrfun(B,X,Y,@sigmoidval), B0(:), options);
end

if nargout>3
    [~,bootsam] = bootstrp(nboot,@nanmean, y);
    bootstat = nan(2,size(x,2),nboot);
    parfor iboot=1:nboot
        idx = bootsam(:,iboot);
        x0 = x(idx);
        y0 = y(idx);
        bootstat(:,:,iboot) = sigmoidfit(x0,y0);
    end
    bootSE = squeeze(nanstd(bootstat),0,3);
    bootCI = cat(3,prctile(bootstat,100*alpha/2,3),prctile(bootstat,100*(1-alpha/2),3));
end