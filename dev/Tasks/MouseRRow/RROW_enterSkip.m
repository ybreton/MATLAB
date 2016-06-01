function enterSkip = RROW_enterSkip(fd, varargin)

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
enterSkip.flavors = {};
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
    
    if isempty(enterSkip.flavors)
        enterSkip.flavors = sd.keys.Flavors;
        enterSkip.nSkips = zeros(size(enterSkip.flavors));
        enterSkip.nEnters = zeros(size(enterSkip.flavors));        
    else % check to make sure same flavor set
        flavorMatch = cellfun(@strcmp, sd.keys.Flavors, enterSkip.flavors);
        assert(all(flavorMatch));
    end
    
    for iF = 1:length(enterSkip.flavors)
        enterSkip.nSkips(iF) = enterSkip.nSkips(iF)+sum(~isnan(sd.taskEvents.SkipTimeStamp(sd.taskEvents.Flavor==iF)));
        enterSkip.nEnters(iF) = enterSkip.nEnters(iF)+sum(~isnan(sd.taskEvents.EnterTimeStamp(sd.taskEvents.Flavor==iF)));
    end          

end

% Package up
% OK

