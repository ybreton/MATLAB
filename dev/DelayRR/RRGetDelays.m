function [delays,sdOut] = RRGetDelays(sd,varargin)
% Produces delay matrix.
% [delay,sd] = RRGetDelays(sd)
% where     delay is nSubsess x trial vector of delays offered
%           if sd output is specified, will add field Delays to each subsession.
%           
%           sd is nSubsess x 1 structure of sd.
%
% OPTIONAL:
% nLaps     (default 200)   maximum number of laps
% nZones    (default 4)     number of zones

nLaps = 200;
nZones = 4;
process_varargin(varargin);

delays = nan(numel(sd),nLaps*nZones*numel(sd));
for s = 1 : numel(sd)
    zone = sd(s).ZoneIn;

    ds = sd(s).ZoneDelay;
    delays(s,1:length(zone)) = ds(1:length(zone));

end

if nargout>1
    for s = 1 : numel(sd)
        sd0 = sd(s);
        sd0.Delays = delays(s,:);
        sdOut(s) = sd0;
    end
end