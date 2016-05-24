function outStruc = RRIdentifyBadLuck(inStruc)
% Adds field isUnlucky to RR data structure for each trial t:
% delay on trial t-1 > threshold, choice on trial t-1 = skip
% delay on trial t   > threshold
%
% outStruc = RRIdentifyBadLuck(inStruc)
% where     outStruc    is a structure containing nSess x nTrial matrix of
%                           bad luck instances (1) or not unlucky (0).
%
%           inStruc     is a structure produced by wrap_RR_analysis.
%


inStruc = RRthreshByTrial(inStruc);
inStruc = RRIdentifyShouldStayGo(inStruc);

ShouldSkip = inStruc.ShouldSkip;

isUnlucky = nan(size(inStruc.staygo));
for iSess = 1 : size(inStruc.staygo,1)
    for t = 2 : size(inStruc.staygo,2)
        lastSkip = inStruc.staygo(iSess,t-1)==0;
        lastShouldSkip = ShouldSkip(iSess,t-1)==1;
        curShouldSkip = ShouldSkip(iSess,t)==1;
        
        isUnlucky(iSess,t) = lastSkip&lastShouldSkip&curShouldSkip;
    end
end

outStruc = inStruc;
outStruc.isUnlucky = isUnlucky;