function [isCellType,nCells] = identifyTTtarget(sdRecRats,target,varargin)
PFN=false;
minSpikes=0;
process_varargin(varargin);

if ischar(target)
    target = {target};
end
sz = size(sdRecRats);

nCells = nan(sz);
isCellType = cell(sz);
for iS=1:length(sdRecRats(:))
    sd = sdRecRats{iS};
    if ~isempty(sd)
        I = RRassignTetrodeClusters(sd);
        if ~isempty(I)
            TargetList = sd.ExpKeys.Target(:)';
            targetIdx = false(length(TargetList),length(target));
            for iTarg=1:length(target)
                for iList=1:length(TargetList)
                    targetIdx(iTarg,iList) = ~isempty(regexpi(TargetList{iList},target{iTarg}));
                end
            end
            targetIdx = any(targetIdx,1);
            idx = any(I(targetIdx,:),1)';

            if PFN
                pfnTF = IdentifyPFNs(sd,'target',target);
                disp([num2str(sum(idx)-sum(idx&pfnTF)) ' Non-phasic neurons excluded.'])
            else
                pfnTF = true(length(idx),1);
            end
            nSpikes=cellfun(@(x) length(data(x.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack))),sd.S);
            spikeTF=nSpikes>=minSpikes;
            idx = idx & pfnTF & spikeTF;
        else
            idx = false(0,1);
        end
        
        nCells(iS) = sum(idx);
        isCellType{iS} = idx;
    end
end
