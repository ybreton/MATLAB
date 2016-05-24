function tau = fit_gauss_tauCI(x,mu,sigma,varargin)
% produces bootstrap-derived confidence intervals for mixing coefficient of
% a gaussian mixture model specified by mu and sigma.
% CI = fit_gauss_CI(x,mu,sigma,varargin)
% where
%       CI      is a (2 x k) matrix of the lower (1,:) and upper (2,:)
%               bounds of the mixing coefficient for each component
%               (columns);
%       x       is a vector of observations,
%       mu      is a vector of means for each component,
%       sigma   is a vector of variances for each component.
% optional parameters
%       censoring (default false)   a logical vector specifying which
%                                   observations are censored
%       alpha     (default 0.05)    a scalar specifying the type-I error
%                                   rate for the confidence interval.
%

censoring = false(length(x),1);
alpha = 0.05;
process_varargin(varargin);

nBoot = 10^(-floor(log10(alpha/2))+1);

idnan = isnan(x)|isinf(x);
x0 = x(~idnan);
c0 = censoring(~idnan);

[~,bootsam] = bootstrp(nBoot,@mean,x0);

tList = nan(k,nBoot);
parfor boot = 1 : nBoot
    id = bootsam(:,bootsam);
    
    tList(:,boot) = fit_gauss_taus(x0,mus,sqrt(sigmas),[],'censoring',censoring);
end

lo = prctile(tList,(alpha/2)*100,2);
hi = prctile(tList,(1-alpha/2)*100,2);

tau = [lo'; hi'];