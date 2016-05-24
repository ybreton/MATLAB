function outStruc = RRIdentifyRegret(inStruc)
% Adds field isRegret to RR data structure for each trial t:
% delay on trial t-1 < threshold, choice on t-1 = go
% delay on trial t   > threshold
%
% outStruc = RRIdentifyRegret(inStruc)
% where     outStruc    is a structure containing nSess x nTrial matrix of
%                           regret instances (1) or not regret (0).
%
%           inStruc     is a structure produced by wrap_RR_analysis.
%


inStruc = RRthreshByTrial(inStruc);
inStruc = RRIdentifyShouldStayGo(inStruc);

ShouldSkip = inStruc.ShouldSkip;
ShouldStay = inStruc.ShouldStay;

isRegret = nan(size(inStruc.staygo));
for iSess = 1 : size(inStruc.staygo,1)
    for t = 2 : size(inStruc.staygo,2)
        lastSkip = inStruc.staygo(iSess,t-1)==0;
        lastShouldStay = ShouldStay(iSess,t-1)==1;
        curShouldSkip = ShouldSkip(iSess,t)==1;
        
        isRegret(iSess,t) = lastSkip&lastShouldStay&curShouldSkip;
    end
end

outStruc = inStruc;
outStruc.isRegret = isRegret;