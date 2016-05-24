function zones = RRGetZones(sd,varargin)
% Produces zone matrix.
% [zone,fnOut] = RRGetZones(sd)
% where     zone is nSubsess x trial vector of zones encountered.
%           
%           sd is nSubsess x 1 structure of sd.
%
% OPTIONAL:
% nLaps     (default 200)   maximum number of laps
% nZones    (default 4)     number of zones

nLaps = 200;
nZones = 4;
process_varargin(varargin);

zones = nan(numel(sd),nLaps*nZones);

for s = 1 : numel(sd)
    zn = sd(s).ZoneIn;
    zones(s,1:length(zn)) = zn;
end
