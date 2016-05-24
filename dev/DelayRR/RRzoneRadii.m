function [entryRadius,armRadius,feederRadius] = RRzoneRadii(sd,varargin)
% Returns the radii of zone entry, arm entry, and feeder.
%
%
%

nZones=4;
process_varargin(varargin);

[sd.x,sd.y] = RRcentreMaze(sd);
if ~isfield(sd,'theta')
    sd.theta = tsd(sd.x.range,atan2(sd.y.data,sd.x.data));
end
if ~isfield(sd,'radius')
    sd.radius = tsd(sd.x.range,sqrt(sd.x.data.^2+sd.y.data.^2));
end
stayGo = RRGetStaygo(sd);
entryRadius = nan(nZones,1);
armRadius = nan(nZones,1);
feederRadius = nan(nZones,1);
for iZ=1:nZones
    Tin = sd.EnteringZoneTime(iZ:nZones:end);
    Tout = sd.EnteringZoneTime(iZ+1:nZones:end);
    nTrls = length(Tout);
    Tfire = sd.FeederTimes(sd.FeedersFired==iZ);
    sg = stayGo(iZ:nZones:end);
    % Radius of zone entry
    entryRadius(iZ) = nanmedian(sd.radius.data(Tin));
    
    % Radius of arm entry
    mR = nan(nTrls,1);
    for iTrl=1:nTrls
        mR(iTrl) = max(data(sd.radius.restrict(Tin(iTrl),Tout(iTrl))));
    end
    armRadius(iZ) = nanmedian(mR(sg(1:nTrls)==0));
    
    % Radius of feeder
    feederRadius(iZ) = nanmedian(sd.radius.data(Tfire));
end