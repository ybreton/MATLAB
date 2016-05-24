function outStruc = RRIdentifyElationControl2(inStruc)
% Adds field isElationControl2 to RR data structure for each trial t:
% delay on trial t-1 < threshold, choice on trial t-1 = go
% delay on trial t   < threshold
%
% outStruc = RRIdentifyRejoice(inStruc)
% where     outStruc    is a structure containing nSess x nTrial matrix of
%                           rejoice instances (1) or not rejoice (0).
%
%           inStruc     is a structure produced by wrap_RR_analysis.
%


inStruc = RRthreshByTrial(inStruc);
inStruc = RRIdentifyShouldStayGo(inStruc);

ShouldSkip = inStruc.ShouldSkip;
ShouldStay = inStruc.ShouldStay;

isElationControl2 = nan(size(inStruc.staygo));
for iSess = 1 : size(inStruc.staygo,1)
    for t = 2 : size(inStruc.staygo,2)
        lastSkip = inStruc.staygo(iSess,t-1)==0;
        lastShouldStay = ShouldSkip(iSess,t-1)==1;
        curShouldStay = ShouldStay(iSess,t)==1;
        
        isElationControl2(iSess,t) = lastSkip&lastShouldStay&curShouldStay;
    end
end

outStruc = inStruc;
outStruc.isRejoice = isElationControl2;
