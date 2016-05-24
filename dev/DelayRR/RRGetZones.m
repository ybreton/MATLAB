function [zones,sdOut] = RRGetZones(sd,varargin)
% Produces zone matrix.
% [zone,sd] = RRGetZones(sd)
% where     zone is nSubsess x trial vector of zones encountered.
%           if sd output is specified, will add field Zones to each subsession.           
%           
%           sd is nSubsess x 1 structure of sd.
%
% OPTIONAL:
% nLaps     (default 200)   maximum number of laps
% nZones    (default 4)     number of zones

nLaps = 200;
nZones = 4;
process_varargin(varargin);

zones = nan(numel(sd),nLaps*nZones*numel(sd));

for s = 1 : numel(sd)
    zn = sd(s).ZoneIn;
    zones(s,1:length(zn)) = zn;
end

if nargout>1
    for s = 1 : numel(sd)
        sd0 = sd(s);
        sd0.Zones = zones(s,:);
        sdOut(s) = sd0;
    end
end