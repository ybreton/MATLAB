function [bestfit,allFits] = fitIncreasingLineSegmentsDD(InDelay,varargin)

maxK = 4;
% criticalER = 1;

process_varargin(varargin);
AIC(1) = inf;
for K = 2 : maxK;
    [fit(K).fit,LnL] = fitSegmentDurationProbabilities((1:numel(InDelay))',InDelay,K);
    
    clf
    plot_choice_segment_overlay(fit(K).fit,InDelay)
    drawnow
    
    % 1 for each of K-1 durations,
    % 1 for each even j probability.
    params = (K-1)+floor(K/2);
    AIC(K) = 2*params - 2*LnL;
    [minAIC,idMin] = min(AIC);
    delta = AIC - minAIC;
    weight = exp(1).^(-0.5*delta)/sum(exp(1).^(-0.5*delta));
    if K > 1
        ER = weight(K)/weight(K-1);
        fprintf('ER, %d vs %d: %.3f\n',K,K-1,ER)
    end
    fit(K).AIC = AIC(K);
end

[minAIC,idMin] = min(AIC);
delta = AIC - minAIC;
weight = exp(1).^(-0.5*delta)/sum(exp(1).^(-0.5*delta));
ER = weight(idMin)./weight;
[~,idBest] = min(ER);
for f = 1 : length(fit)
    fit(f).ER = 1./ER(f);
end

bestfit = fit(idBest).fit;
allFits.list = fit;
allFits.ERs = 1./ER;
allFits.AICs = AIC;
allFits.weight = weight;
allFits.BestFit = idBest;
plot_choice_segment_overlay(bestfit,InDelay)