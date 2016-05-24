function [tauLo,tauHi,tauMean,tauMedian] = gmmfitTauCI(gmobj,Y,varargin)
% finds bootstrap-derived confidence interval about mixing coefficients
% [tauLo,tauHi,tauMean,tauMedian] = gmmfitTauCI(gmobj,Y,varargin)
% where     tauLo   is the lower bound,
%           tauHi   is the upper bound,
%           tauMean is the overall estimate without resampling Y,
%           tauMedian is the median of the resampled values.
%
%           gmobj   is a gmdistribution object,
%           Y       are n x d data for fitting
%
% OPTIONAL:
%           alpha (default 0.05)    type I error rate for confidence
%                                   interval
%           clean (default true)    replace Inf values with NaN.

alpha = 0.05;
clean = true;
process_varargin(varargin);
if clean
    Y(isinf(Y)) = [];
end
nBoots = 10.^(-floor(log10(alpha/2))+1);

[~,bootsam] = bootstrp(nBoots,@mean,Y(:,1));
tauMean = nanmean(gmobj.posterior(Y),1);

parfor boot = 1 : nBoots
    idBoot = bootsam(:,boot);
    posteriors = gmobj.posterior(Y(idBoot,:));
    tau(boot,:) = nanmean(posteriors);
end
tauLo = prctile(tau,alpha/2*100,1);
tauHi = prctile(tau,(1-alpha/2)*100,1);

tauMedian = nanmedian(tau,1);