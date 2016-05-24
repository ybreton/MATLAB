function [threshByTrial,sdOut] = RRthreshByTrial(sd,varargin)
% Produces threshold matrix.
% [threshByTrial,correctByTrial,incorrectByTrial] = RRthreshByTrial(sd)
% where         threshByTrial   is nSubsess x nTrials matrix of thresholds
%                                   for each trial.
%               if sd output is specified, will add field threshByTrial to each subsession.
%
%               sd              is nSubsess x 1 structure of sd.
%
% OPTIONAL:
% nLaps     (default 200)   maximum number of laps
%
nLaps = 200;
process_varargin(varargin);

pellets = RRGetPellets(sd);
zones = RRGetZones(sd);
nZones = length(unique(zones(~isnan(zones(:)))));
staygo = RRGetStaygo(sd);

nSubsess = numel(sd);
nPlist = unique(pellets(~isnan(pellets)));
nPlist = nPlist(:)';

thresholds = RRThresholds(sd);
threshByTrial = nan(size(staygo));
for iSess = 1 : nSubsess
    for iZ = 1 : nZones
        idZ = zones(iSess,:)==iZ;
        for nP = nPlist
            idP = pellets(iSess,:) == nP;
            threshByTrial(iSess,idZ&idP) = thresholds(iZ,nP);
        end
    end
end

if nargout>1
    for s = 1 : numel(sd)
        sd0 = sd(s);
        sd0.threshByTrial = threshByTrial(s,:);
        sdOut(s) = sd0;
    end
end