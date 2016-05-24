function [AIC,AICc] = glmAIC(stats)
% Computes the Akaike Information Criterion for the GLM.
% AIC = 2*k + n*ln(RSS) using assumptions of GLM (errors are iid).
% where k is the number of parameters in the model, 
%       n is the number of observations, and
%       RSS is the residual sum of squares.
% When estimating the model Y = bX+e, the residuals e are assumed to be iid
% with zero-mean Gaussian, thereby requiring 
% - one parameter for estimating error variance,
% - one parameter for each predictor slope, including the possible
% constant predictor.
% The corrected-for-small-samples AICc can also be returned as
% AICc = AIC + (2*k*(k+1)) / (n-k-1).
% When comparing two AIC values, the quantity
% RL = exp((AIC_j - AIC_i)/2) 
% provides the relative likelihood of model i compared to model j.
%
% [AIC] = glmAIC(stats)
% [AIC,AICc] = glmAIC(stats)
% where     AIC         is the Akaike Information Criterion,
%           AICc        is the Akaike Information Criterion corrected for
%                           small sample sizes,
%
%           stats       is a structure produced by glmfit.
% 
% Lower values of AIC correspond to "better" models: models that fit the
% data better using fewer parameters.
%

k = length(stats.beta)+1;
n = length(stats.resid);
RSS = stats.resid'*stats.resid;

AIC = 2*k + n*log(RSS);

AICc = AIC + (2*k*(k+1)) / (n-k-1);