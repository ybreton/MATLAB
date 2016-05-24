function [thresholds,correct,incorrect] = RRThresholds(sd,varargin)
% Produces threshold matrix.
% [thresholds,correct,incorrect] = RRThresholds(sd)
% where     thresholds      is nZone x nPellet vector of thresholds for session
%                               in sd.
%           correct         is nZone x nPellet vector of correct choices
%                               for session in sd.
%           incorrect       is nZone x nPellet vector of incorrect (error)
%                               choices for session in sd.
%           
%           sd              is nSubsess x 1 structure of sd.
%
% OPTIONAL ARGUMENTS:
% ******************
% nZones        (default 4)     number of zones
% maxPellets    (default 3)     maximum number of pellets delivered
%


nZones = 4;
maxPellets = 3;
process_varargin(varargin);

pellets = RRGetPellets(sd);
zones = RRGetZones(sd);
staygo = RRGetStaygo(sd);
delays = RRGetDelays(sd);

nPlist = unique(pellets(~isnan(pellets)));
nPlist = nPlist(:)';

thresholds = nan(nZones,maxPellets);
correct = nan(nZones,maxPellets);
incorrect = nan(nZones,maxPellets);
for iZ=1:nZones
    idZ = zones==iZ;
    for nP = nPlist
        idP = pellets==nP;
        if any(idZ(:)&idP(:))
            [thresholds(iZ,nP),correct(iZ,nP),incorrect(iZ,nP)] = RRheaviside(delays(idZ&idP),staygo(idZ&idP));
        end
    end
end