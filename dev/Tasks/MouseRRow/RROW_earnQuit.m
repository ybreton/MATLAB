function earnQuit = RROW_earnQuit(fd, varargin)

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
earnQuit.flavors = {};
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
    
    if isempty(earnQuit.flavors)
        earnQuit.flavors = sd.keys.Flavors;
        earnQuit.nQuits = zeros(size(earnQuit.flavors));
        earnQuit.nEarns = zeros(size(earnQuit.flavors));        
    else % check to make sure same flavor set
        flavorMatch = cellfun(@strcmp, sd.keys.Flavors, earnQuit.flavors);
        assert(all(flavorMatch));
    end
    
    for iF = 1:length(earnQuit.flavors)
        earnQuit.nQuits(iF) = earnQuit.nQuits(iF)+sum(~isnan(sd.taskEvents.QuitTimeStamp(sd.taskEvents.Flavor==iF)));
        earnQuit.nEarns(iF) = earnQuit.nEarns(iF)+sum(~isnan(sd.taskEvents.EarnTimeStamp(sd.taskEvents.Flavor==iF)));
    end          

end

% Package up
% OK

