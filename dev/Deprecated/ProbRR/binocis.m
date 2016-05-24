function [mY,lo,hi] = binocis(entries,skips,dim,alpha)
% produces means and confidence intervals of proportion of entries along
% dimension dim.
% [mY,lo,hi] = binocis(entries,skips,dim,alpha)
% where
%           mY is the mean proportion of entries,
%           lo is the lower bound of the confidence interval,
%           hi is the upper bound of the confidecne interval,
%           
%           entries is the number of entries,
%           skips is the number of skips,
%           dim is the dimension along which to take means and confidence
%           intervals (default is 1)
%           alpha is the desired type-I error rate level of the confidence
%           interval (default is 0.05).
%
%

if nargin < 4
    alpha = 0.05;
end
if nargin < 3
    dim = 1;
end

    mY = binofit(nansum(entries,dim),nansum(entries,dim)+nansum(skips,dim));

% mean

lo = binoinv(alpha/2,nansum(entries,dim)+nansum(skips,dim),mY);
hi = binoinv(1-alpha/2,nansum(entries,dim)+nansum(skips,dim),mY);
% number of entries out of total entries+skips you would expect to sample
% from +/-2.5% of the time if the true population mean is the sample mean

lo = lo./(nansum(entries,dim)+nansum(skips,dim));
hi = hi./(nansum(entries,dim)+nansum(skips,dim));
sY = [lo(:) hi(:)];