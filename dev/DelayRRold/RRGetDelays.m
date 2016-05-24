function delays = RRGetDelays(sd,varargin)
% Produces delay matrix.
% delay = RRGetDelays(sd)
% where     delay is nSubsess x trial vector of delays offered
%           
%           sd is nSubsess x 1 structure of sd.
%
% OPTIONAL:
% nLaps     (default 200)   maximum number of laps
% nZones    (default 4)     number of zones

nLaps = 200;
nZones = 4;
process_varargin(varargin);

delays = nan(length(sd),nLaps*nZones);
for s = 1 : length(sd)
    zone = sd(s).ZoneIn;

    ds = sd(s).ZoneDelay;
    delays(s,1:length(zone)) = ds(1:length(zone));

end