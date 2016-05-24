function [gmobjVEH,gmobjCNO] = wrap_RR_summarizeGMMFit(LogIdPhiVeh,LogIdPhiCNO)
% Wrapper produces structures with gmdistribution objects, mean mixture
% coefficients, and confidence intervals.
% gmdistribution is fit to both conditions together, first.
% mixing coefficients for each condition are then estimated individually
% (mean posterior of each component across all condition values),
% and 95% confidence interval done by bootstrap for the condition.
% [gmobjVEH,gmobjCNO] = wrap_RR_summarizeLogIdPhi(VEH,CNO)
% where     gmobjVEH, gmobjCNO      are structure arrays with fields
%               .gmobj              gmdistribution object for the condition
%               .tau                mixing coefficients for the condition
%               .tauCIlo            lower bound of 95% confidence interval
%               .tauCIhi            upper bound of 95% confidence interval
%
%           VEH, CNO                are nSession x 1 structure arrays with
%                                       field sd containing standard
%                                       session data.
%

LogIdPhiVeh = LogIdPhiVeh(~isnan(LogIdPhiVeh)&~isinf(LogIdPhiVeh));
LogIdPhiCNO = LogIdPhiCNO(~isnan(LogIdPhiCNO)&~isinf(LogIdPhiCNO));

gmobjectCommon = gmmfit([LogIdPhiVeh;LogIdPhiCNO],2);

[tauLoVeh,tauHiVeh,tauMeanVeh] = gmmfitTauCI(gmobjectCommon,LogIdPhiVeh);
[tauLoCNO,tauHiCNO,tauMeanCNO] = gmmfitTauCI(gmobjectCommon,LogIdPhiCNO);

gmobjVehicle = gmdistribution(gmobjectCommon.mu,gmobjectCommon.Sigma,tauMeanVeh);
gmobjDrug = gmdistribution(gmobjectCommon.mu,gmobjectCommon.Sigma,tauMeanCNO);

gmobjVEH.gmobj = gmobjVehicle;
gmobjVEH.tau = tauMeanVeh;
gmobjVEH.tauCIlo = tauLoVeh;
gmobjVEH.tauCIhi = tauHiVeh;

gmobjCNO.gmobj = gmobjDrug;
gmobjCNO.tau = tauMeanCNO;
gmobjCNO.tauCIlo = tauLoCNO;
gmobjCNO.tauCIhi = tauHiCNO;
