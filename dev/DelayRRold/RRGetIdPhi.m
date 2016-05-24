function [IdPhi,Z] = RRGetIdPhi(sd,varargin)
% Produces IdPhi matrices.
% [IdPhi,Z,fnOut] = RRGetIdPhi(sd)
% where     IdPhi is n x trial vector of IdPhi values encountered,
%           Z is n x lap vector of zIdPhi values,
%           
%           sd is nSubsess x 1 structure of sd.
%
% OPTIONAL:
% nLaps     (default 200)   maximum number of laps
% nZones    (default 4)     number of zones
% VTEtime   (default 2)     time window for VTE calculation (sec)
%

nLaps = 200;
nZones = 4;
VTEtime = 2;
process_varargin(varargin);


IdPhi = nan(numel(sd)*nZones,nLaps*nZones);
Z = IdPhi;

for s = 1 : numel(sd)
    sd0 = sd(s);
    sd0.EnteringCPTime = sd0.EnteringZoneTime;
    sd0.ExitingCPTime = sd0.EnteringZoneTime+VTEtime;
    sd0 = zIdPhi(sd0);

    X = sd0.IdPhi;
    Zx = sd0.zIdPhi;

    IdPhi(s,1:length(X)) = X;
    Z(s,1:length(X)) = Zx;
end
