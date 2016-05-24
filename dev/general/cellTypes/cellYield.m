function [yield,regions] = cellYield(sd)

[regions,I] = sort(sd.ExpKeys.Target);
TetrodeTargets = sd.ExpKeys.TetrodeTargets;
for iT=1:length(regions)
    id = sd.ExpKeys.TetrodeTargets==I(iT);
    TetrodeTargets(id) = iT;
end
sd.ExpKeys.TetrodeTargets = TetrodeTargets;

TTidx = (RRassignTetrodeClusters(sd))';
yield = nan(1,size(TTidx,2));
for iTarget=1:size(TTidx,2)
    S = sd.S(TTidx(:,iTarget));
    for iC=1:length(S)
        S{iC} = S{iC}.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);
        if isempty(S{iC}.data)
            TTidx(iC,iTarget)=false;
        end
    end
    
    yield(iTarget) = sum(double((TTidx(:,iTarget))));
end
