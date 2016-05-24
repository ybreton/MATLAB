function [isRewardCell,nRewCell] = identifyRewardCell(sdRecRat,isCellType,varargin)
window = [0 3];
process_varargin(varargin);

sz = size(sdRecRat);
isRewardCell(prod(sz)) = struct('Z',[],'wilcoxonP',[],'bootP',[]);
nRewCell = nan(sz);
for iS=1:length(sdRecRat(:))
    sd = sdRecRat{iS};
    cType = isCellType{iS};
    if ~isempty(sd)
        cellNums = find(cType);
        S = sd.S(cType);
        tIn = sd.FeederTimes+window(1);
        tOut = sd.FeederTimes+window(2);
        tStart = sd.ExpKeys.TimeOnTrack;
        tEnd = sd.ExpKeys.TimeOffTrack;
        [~,p,~,x,~,bootstat,xsam] = testTimeShuffles(S,tIn,tOut,tStart,tEnd,'nBoots',500);
        m = nanmean(bootstat,1);
        s = nanstd(bootstat,0,1);
        Z = (x(:)-m(:))./s(:);
        isRewardCell(iS).Z(~cType) = nan;
        isRewardCell(iS).Z(cType) = Z;
        
        tRand = rand(500,1)*(tEnd-tStart)+tStart;
        t1 = tRand+window(1);
        t2 = tRand+window(2);
        bootstat = nan(length(t1),length(S));
        for iC=1:length(S)
            parfor iWin=1:length(t1)
                bootstat(iWin,iC) = length(data(S{iC}.restrict(t1(iWin),t2(iWin))))/(window(2)-window(1));
            end
        end
        
        isRewardCell(iS).wilcoxonP(~cType) = nan;
        wilcoxonP = nan(length(cellNums),1);
        for iC=1:length(cellNums)
            wilcoxonP(iC) = ranksum(xsam(:,iC),bootstat(:,iC));
            isRewardCell(iS).wilcoxonP(cellNums(iC)) = wilcoxonP(iC);
        end
        isRewardCell(iS).bootP(~cType) = nan;
        isRewardCell(iS).bootP(cType) = p;
        nRewCell(iS) = nansum(wilcoxonP<0.05);
    end
end
isRewardCell = reshape(isRewardCell,sz);