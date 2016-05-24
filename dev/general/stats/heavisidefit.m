function [th,correct,incorrect,LSE, bootSE, bootCI] = heavisidefit(x,y,varargin)
% Fit heaviside function of x to y boolean data by least squares. Assumes
% that each column should have a separate threshold, and that each value in
% x(i,j) corresponds to y(i,j).
% [th,correct,incorrect,LSE, bootSE, bootCI] = heavisidefit(x,y)
% where     th  is 1 x nDim array of thresholds,
%           correct is 1 x nDim array of the number of accurately predicted choices,
%           incorrect is 1 x nDim array of the number of inaccurately predicted choices,
%           LSE is 1 x nDim array of the least squared deviation of observed from predicted.
%           bootSE is 1 x nDim array of bootstrap-derived standard errors.
%           bootCI is 2 x nDim array of lower and upper bounds of the
%                  bootstrap-derived confidence interval.
%
%           x   is 1 x n
%                  n x 1 
%                  n x nDim vector of predictors of Heaviside function
%           y   is 1 x n
%                  n x 1 
%                  n x nDim vector of outcomes of Heaviside function
%
%
% OPTIONAL ARGUMENTS:
% ******************
% slope     (-1)
%   Sign of the slope of the Heaviside step function. Negative means that
%   y=1 when x<th. Positive means that y=1 when x>th.
% alpha     (0.05)
%   Type-I error rate of bootstrap-derived confidence interval.
% nboot     (min 10 samples in each tail)
%   Number of samples to use for bootstrap estimation of standard error and
%   confidence interval. Default is calculated according to 
%       10^(ceil(-log10(alpha/2))+1),
%   which ensures that at alpha=0.05, using 1000 samples will result in 25
%   in each of the tails.
%
slope = -1;
alpha = 0.05;
process_varargin(varargin);
nboot = 10^(ceil(-log10(alpha/2))+1);
process_varargin(varargin);

assert(length(size(y))==2 && length(size(x))==2,'x and y must be at most 2D matrix of booleans.')
assert(all(size(x)==size(y)),'x and y must have identical size.')
if sum(double(size(y)>1))==1
    y = y(:);
end
if sum(double(size(x)>1))==1
    x = x(:);
end

th = nan(1,size(y,2));
correct = th;
incorrect = th;
for iDim=1:size(y,2)
    Y = y(:,iDim);
    idnan = isnan(x)|isnan(Y);
    Y = Y(~idnan);
    X = x(~idnan);

    uniqueXs = unique(X(:));

    if length(uniqueXs)>1
        width = diff(uniqueXs)/2;
        widthLo = [width(1);width(:)];
        widthHi = [width;width(end)];

        x0list = unique([uniqueXs-widthLo;uniqueXs;uniqueXs+widthHi]);
        SSE = nan(length(x0list),1);
        C = nan(length(x0list),1);
        I = nan(length(x0list),1);
        for iX = 1 : length(x0list)
            x0 = x0list(iX);
            predY = heavisideval(x0,X,'slope',slope);

            SSE(iX) = (Y-predY)'*(Y-predY);
            C(iX) = nansum(predY==Y);
            I(iX) = nansum(predY~=Y);
        end
        [LSE,idMin]=min(SSE);
        th(iDim) = x0list(idMin);
        correct(iDim) = C(idMin);
        incorrect(iDim) = I(idMin);
    else
        th(iDim) = nan;
        correct(iDim) = nan;
        incorrect(iDim) = nan;
        LSE(iDim) = inf;
    end
end

if nargout > 4
    [~,bootsam] = bootstrp(nboot,@nanmean, y);
    bootstat = nan(nboot,size(x,2));
    parfor iboot=1:nboot
        idx = bootsam(:,iboot);
        x0 = x(idx);
        y0 = y(idx);
        bootstat(iboot,:) = heavisidefit(x0,y0);
    end
    bootSE = nanstd(bootstat,0,1);
    bootCI = [prctile(bootstat,100*alpha/2,1);
              prctile(bootstat,100*(1-alpha/2),1)];
end