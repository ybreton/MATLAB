function avgTimes = RROW_avgTimes(fd, varargin)

% Wrapper to go through file directories and pull in staySkip proportions by flavor
% INPUT
%   fc = list of directories
% OUTPUT
%   staySkip = structure with number of stays by flavor, number skips by
%   flavor, etc.

% variables
PhaseLimit = '';
process_varargin(varargin);

% Build base
avgTimes.flavors = {};
% Step through directories
nD = length(fd);
for iD = 1:nD
    sd = mouseRROWTaskInit(fd{iD});
    if isempty(PhaseLimit) || ...
            strncmp(sd.keys.PhaseOfStudy,PhaseLimit,length(PhaseLimit))
        disp(sd.keys.SSN);
    else
        fprintf('%s - SKIPPED\n', sd.keys.SSN);
        continue;
    end
    
    if isempty(avgTimes.flavors)
        avgTimes.flavors = sd.keys.Flavors;
        avgTimes.offerlist = sd.keys.FeederDelayList;
        cumEnterTime = zeros(length(avgTimes.offerlist),length(avgTimes.flavors));
        cumSkipTime = zeros(length(avgTimes.offerlist),length(avgTimes.flavors));
        cumQuitTime = zeros(length(avgTimes.offerlist),length(avgTimes.flavors));
        cumEarnTime = zeros(length(avgTimes.offerlist),length(avgTimes.flavors));
        cumWorkTime = zeros(length(avgTimes.offerlist),length(avgTimes.flavors));
        nEnters = zeros(length(avgTimes.offerlist),length(avgTimes.flavors));
        nSkips = zeros(length(avgTimes.offerlist),length(avgTimes.flavors));
        nQuits = zeros(length(avgTimes.offerlist),length(avgTimes.flavors));
        nEarns = zeros(length(avgTimes.offerlist),length(avgTimes.flavors));
    else % check to make sure same flavor set
        flavorMatch = cellfun(@strcmp, sd.keys.Flavors, avgTimes.flavors);
        assert(all(flavorMatch));
    end
    
    for iF = 1:length(avgTimes.flavors)
        for iO = 1:length(sd.keys.FeederDelayList)
            cumEnterTime(iO,iF) = cumEnterTime(iO,iF)+nansum(sd.taskEvents.EnterTime(sd.taskEvents.Flavor==iF & sd.taskEvents.Offer==iO));
            cumSkipTime(iO,iF) = cumSkipTime(iO,iF)+nansum(sd.taskEvents.SkipTime(sd.taskEvents.Flavor==iF & sd.taskEvents.Offer==iO));
            cumQuitTime(iO,iF) = cumQuitTime(iO,iF)+nansum(sd.taskEvents.QuitTime(sd.taskEvents.Flavor==iF & sd.taskEvents.Offer==iO));
            cumEarnTime(iO,iF) = cumEarnTime(iO,iF)+nansum(sd.taskEvents.EarnTime(sd.taskEvents.Flavor==iF & sd.taskEvents.Offer==iO));
            cumWorkTime(iO,iF) = cumWorkTime(iO,iF)+nansum(sd.taskEvents.WorkTime(sd.taskEvents.Flavor==iF & sd.taskEvents.Offer==iO));
            nSkips(iO,iF) = nSkips(iO,iF)+sum(~isnan(sd.taskEvents.SkipTimeStamp(sd.taskEvents.Flavor==iF & sd.taskEvents.Offer==iO)));
            nEnters(iO,iF) = nEnters(iO,iF)+sum(~isnan(sd.taskEvents.EnterTimeStamp(sd.taskEvents.Flavor==iF & sd.taskEvents.Offer==iO)));
            nQuits(iO,iF) = nQuits(iO,iF)+sum(~isnan(sd.taskEvents.QuitTimeStamp(sd.taskEvents.Flavor==iF & sd.taskEvents.Offer==iO)));
            nEarns(iO,iF) = nEarns(iO,iF)+sum(~isnan(sd.taskEvents.EarnTimeStamp(sd.taskEvents.Flavor==iF & sd.taskEvents.Offer==iO)));
            
        end
    end
    
end

avgTimes.avgEnterTime=((cumEnterTime)./nEnters);
avgTimes.avgSkipTime=((cumSkipTime)./nSkips);
avgTimes.avgQuitTime=((cumQuitTime)./nQuits);
avgTimes.avgEarnTime=((cumEarnTime)./nEarns);
avgTimes.avgWorkTime=((cumWorkTime)./nEarns);

% Package up
% OK

