function outStruc = RRIdentifyDisappoint(inStruc)
% Adds field isDisappoint to RR data structure for each trial t:
% delay on trial t-1 < threshold, choice on trial t-1 = stay
% delay on trial t   > threshold
%
% outStruc = RRIdentifyDisappoint(inStruc)
% where     outStruc    is a structure containing nSess x nTrial matrix of
%                           disappointment instances (1) or not disappointing (0).
%
%           inStruc     is a structure produced by wrap_RR_analysis.
%

inStruc = RRthreshByTrial(inStruc);
inStruc = RRIdentifyShouldStayGo(inStruc);

ShouldSkip = inStruc.ShouldSkip;
ShouldStay = inStruc.ShouldStay;

isDisappoint = nan(size(inStruc.staygo));
for iSess = 1 : size(inStruc.staygo,1)
    for t = 2 : size(inStruc.staygo,2)
        lastStay = inStruc.staygo(iSess,t-1)==1;
        lastShouldStay = ShouldStay(iSess,t-1)==1;
        curShouldSkip = ShouldSkip(iSess,t)==1;
        
        isDisappoint(iSess,t) = lastStay&lastShouldStay&curShouldSkip;
    end
end

outStruc = inStruc;
outStruc.isDisappoint = isDisappoint;