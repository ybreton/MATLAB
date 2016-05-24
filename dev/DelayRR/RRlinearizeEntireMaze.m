function [L,Landmarks] = RRlinearizeEntireMaze(linPos,zonPos,varargin)
% Uses output of RRLinearizeIdealPath to linearize entire maze, with 0
% corresponding to SoM.

%
t = linPos.range;
z = zonPos.data(t);
uniqueZones = unique(z(~isnan(z)))';

zoneStarts = [0:4:4*(max(uniqueZones)-1)];
zoneExits = [4:4:4*max(uniqueZones)];
Sbound = [0 0 0 0];
process_varargin(varargin);

l = linPos.data;
t = linPos.range;
z = zonPos.data(t);

L = nan(length(l),1);
Landmarks.position = [];
Landmarks.label = {};

uniqueZones = unique(z(~isnan(z)))';

for iZ=uniqueZones
    idZ = z==iZ;
    
    ltemp = l(idZ);
    
    le = zoneExits(iZ)+ltemp(ltemp<Sbound(iZ));
    ls = zoneStarts(iZ)+ltemp(ltemp>=Sbound(iZ));
    
    l0 = nan(length(ltemp),1);
    l0(ltemp<0) = le;
    l0(ltemp>=0) = ls;
    
    L(idZ) = l0;
end

L = tsd(t,L);
