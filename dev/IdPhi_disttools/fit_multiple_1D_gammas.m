function [bestfit,fitlist] = fit_multiple_1D_gammas(x,c,varargin)
%
%
%
%

if isempty(c)
    c = false(size(x));
end
criticalER = 10;
maxK = 5;
plotFlag = false;
process_varargin(varargin);

K = 0;
lastER = 0;
fprintf('\n')
converge = false;

if plotFlag
    fh=figure;
end

while K<maxK & ~converge
    K = K + 1;
    
    [fit(K).fit,LnL] = fit_1D_EM_gamma_mixture(x,c,K);
    % Number of parameters for mixed gaussians:
    % K-1 for weights,
    % K for means,
    % K for standard deviations.
    % AIC = 2*nParams - 2 * ln(L)
    nParams = K - 1 + 2 * K;
    AIC(K) = 2*nParams - 2*LnL;
    %  Akaike weights, from Wagenmakers & Farrell (2004). AIC model
    %  selection using Akaike weights. Psychonomic Bulletin & Review, 11,
    %  192-196.
    %
    %  delta_i = aic_i - min(aic)
    %  w_i = exp(-1/2*delta_i)./sum(-1/2*delta_i)
    %  ER = w_i/min(w_i)
    [minAIC,idMin] = min(AIC);
    delta = AIC - minAIC;
    weight = exp(1).^(-0.5*delta)/sum(exp(1).^(-0.5*delta));
    fprintf('%.0f components, AIC: %.4f\n', K, AIC(K))
    if K>1
        ER = weight(K)/weight(K-1);
        fprintf('ER, i vs i-1: %.3f\n',ER)
        if ER<criticalER
            converge = true;
        end
    end
    if plotFlag
        set(0,'currentFigure',fh)
        cla
        ah = hist_gamma_overlay(x(~c),fit(K).fit);
        drawnow
    end
end
% [minAIC,id] = min(AIC);
id = K-1;
bestfit = fit(id).fit;
fprintf('BEST FIT: %.0f components.\n',size(bestfit,2))
for k = 1 : size(bestfit,2)
    fprintf('Tau %.4f\tKappa %.3f\tTheta %.3f\n',bestfit(1,k),bestfit(2,k),bestfit(3,k))
end
if nargout > 1
    fitlist = fit;
end
if plotFlag
    close(fh)
end