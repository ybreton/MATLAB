function [fit,fitResults] = fitSegments1to4(sd)

InDelay = sd.ZoneIn == sd.DelayZone;
fitResults.HEADER = {'Model' 'Place' 'AIC' 'ER' 'Segments'};
fitResults.DATA = cell(4,5);
for K = 1 : 4
    [fit(K).fit,LnL] = fitSegmentDurationProbabilities((1:numel(InDelay))',InDelay,K,'minDuration',0);
    
%     clf
%     plot_choice_segment_overlay(fit(K).fit,InDelay)
%     drawnow
    
    % 1 for each of K-1 durations,
    % 1 for each even j probability.
    params = (K-1)+floor(K/2);
    AIC(K) = 2*params - 2*LnL;
    [minAIC,idMin] = min(AIC);
    delta = AIC - minAIC;
    weight = exp(1).^(-0.5*delta)/sum(exp(1).^(-0.5*delta));

    fit(K).AIC = AIC(K);
    fitResults.DATA{K,1} = K;
    fitResults.DATA{K,3} = AIC(K);
    fitResults.DATA{K,5} = fit(K).fit;
end

[AIC0,id] = sort(can2mat(fitResults.DATA(:,3)),1,'ascend');

[minAIC,idMin] = min(AIC);
delta = AIC - minAIC;
weight = exp(1).^(-0.5*delta)/sum(exp(1).^(-0.5*delta));
ER = weight./weight(idMin);

fitResults.DATA(:,4) = mat2can(ER);
fitResults.DATA = fitResults.DATA(id,:);
place = (1:size(fitResults.DATA,1))';
fitResults.DATA(:,2) = mat2can(place);