function [threshold,bootSE,bootCI] = fitHeavisideSigmoidHybrid(x,y,varargin)
% Fits a Heaviside; if the resulting threshold of the fit is within the
% first or last bin of x values, uses that value. If the resulting
% threshold from the fit are not within the first or last bins of x values,
% fits a logistic regression function. If that logistic regression blows up
% (produces a threshold value b(2)/(-b(1)) below the lowest x bin or above
% the highest x bin), reverts to a Heaviside function.
%
% threshold = fitHeavisideSigmoidHybrid(x,y)
% where     threshold           is a scalar of the identified threshold
%                                   value, the x point at which 
%                                   P[y==1] == P[y==0]
%
%           x                   is a numerical vector of x values
%           y                   is a logical or binary vector of 1's and
%                                   0's
%
% [threshold,bootSE,bootCI] = fitHeavisideSigmoidHybrid(x,y)
% where     bootSE              is a scalar with the standard error of the
%                                   threshold estimated from a
%                                   bootstrapping procedure
%           bootCI              is a 1x2 vector with the bounds of the
%                                   confidence interval about the
%                                   threshold, estimated from a
%                                   bootstrapping procedure
%
% OPTIONAL ARGUMENTS:
% ******************
% output    (default true if nargout<2; false if nargout>1)
%   Display progress of the fitter
% minThresh (default lowest x + (second lowest-lowest x)/2)
%   Highest low-threshold cutoff to skip sigmoid fit and use Heaviside
% maxThresh (default highest x - (second highest-highest x)/2)
%   Lowest high-threshold cutoff to skip sigmoid fit and use Heaviside
% alpha     (default 0.05)
%   The level at which to evaluate the confidence interval
% nboot     (default: minimum such that number of samples in each tail is
%               at least 10)
%   The number of samples to use in the bootstrapping procedure. Smaller
%   values are more inaccurate, while larger values will be computationally
%   demanding.
%   The equation used to derive the default value is
%   10^(ceil(-log10(alpha/2))+1),
%   which ensures that at alpha=0.05, using 1000 samples will result in 25
%   in each of the tails.
%

uniqueDelays = unique(x);
width = diff(uniqueDelays);
halfWidth = width/2;
if isempty(halfWidth)
    halfWidth = 0;
end

% Optional Arguments
output = nargin<2;
alpha = 0.05;
minThresh = uniqueDelays(1)+halfWidth(1);
maxThresh = uniqueDelays(end)-halfWidth(end);

process_varargin(varargin);
nboot = 10^(ceil(-log10(alpha/2))+1);
process_varargin(varargin);

x = x(:);
y = y(:);
idnan = isnan(x)|isnan(y);
x = x(~idnan);
y = y(~idnan);

if output
    disp('Fitting Heaviside function...')
end
threshold = heavisidefit(x,y);
if threshold>minThresh && threshold<maxThresh
    if output
        disp('Fitting sigmoid...')
    end
    B = sigmoidfit(x,y);
    thresholdS = B(1,:);
    
    if thresholdS<=maxThresh && thresholdS>=minThresh;
        threshold = thresholdS;
    end
end

if nargout>1
    [~,bootsam]=bootstrp(nboot,@mean,y);
    bootstat = nan(nboot,1);
    parfor iBoot=1:nboot
        idx = bootsam(:,iBoot);
        x0 = x(idx);
        y0 = y(idx);
        bootstat(iBoot) = fitHeavisideSigmoidHybrid(x0,y0);
    end
    bootSE = nanstd(bootstat);
    bootCI(1) = prctile(bootstat,100*alpha/2);
    bootCI(2) = prctile(bootstat,100*(1-alpha/2));
end