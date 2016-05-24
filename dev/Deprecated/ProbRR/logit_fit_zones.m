function [fitX,betas_logit_fit,deviance,stats] = logit_fit_zones(x0,entries,skips)
% produces a logistic regression of predictors in x0 of proportion of
% entries, where x0(:,1) is the zone number.
% [fitX,betas_logit_fit,deviance,stats] = logit_fit_zones(x0,entries,skips)
% where
%           fitX is a matrix of all the predictors appropriately coded in the
%           regression,
%           betas_logit_fit is a vector of regression slopes,
%           deviance is the deviance of the logistic fit,
%           stats is a structure with general linear model statistics;
%           
%           x0 is a matrix of predictors where x0(:,1) is zone number,
%           entries is a vector of the number of times feeder is entered,
%           skips is a vector of the number of times it is skipped.
% Note that
% fitX * betas_logit_fit = predicted odds ratio in favour of an entry, or
%   P[entry]/(1-P[entry]) = X*B
%
%

y0 = [entries entries+skips];
nZones = max(x0(:,1));
fitX = nan(size(x0,1),nZones+size(x0,2)-1);
for z = 1 : nZones
    fitX(:,z) = double(x0(:,1)==z);
end
for pred = 2 : size(x0,2)
    fitX(:,nZones+pred-1) = x0(:,pred);
end
    
[betas_logit_fit,deviance,stats] = glmfit(fitX,y0,'binomial','link','logit','constant','off');