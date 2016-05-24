function [x,y]=RRlinearizePath(sd)
%
%
%
%

z = tsd(sd.EnteringZoneTime',sd.ZoneIn');
x0 = sd.x;
y0 = sd.y;
ZoneTheta = [-pi/2;
             0;
             pi/2;
             -pi];
% Each zone has an angle.
CoM = nan(4,2);
for iZ=1:4
    CoM(iZ,:) = [nanmean(sd.x.data(sd.EnteringZoneTime(sd.ZoneIn==iZ))) nanmean(sd.y.data(sd.EnteringZoneTime(sd.ZoneIn==iZ)))];
end
CoM = nanmean(CoM);

theta0 = tsd(x0.range,atan2(sd.y.data-CoM(2),sd.x.data-CoM(1)));
radius0 = tsd(x0.range,sqrt((sd.y.data-CoM(2)).^2+(sd.x.data-CoM(1)).^2));

r = nanmean(radius0.data(sd.EnteringZoneTime));
trackWidth = 50;

theta = [];
radius = [];
timestamps = [];
for iTrl=1:length(sd.ZoneIn)-1
    ZoneEntryTheta = theta0.data(sd.EnteringZoneTime(iTrl));
    NextEntryTheta = theta0.data(sd.EnteringZoneTime(iTrl+1));
    
    thetaTmp = data(theta0.restrict(sd.EnteringZoneTime(iTrl),sd.EnteringZoneTime(iTrl+1)));
    radiusTmp = data(radius0.restrict(sd.EnteringZoneTime(iTrl),sd.EnteringZoneTime(iTrl+1)));
    idTrack = radiusTmp<r+trackWidth;
    idArm = radiusTmp>=r+trackWidth;
    [~,maxRad] = max(radiusTmp);
    thetaArm = thetaTmp(maxRad);
    
    tOut = range(theta0.restrict(sd.EnteringZoneTime(iTrl),sd.EnteringZoneTime(iTrl+1)));
    thetaOut = nan(length(thetaTmp),1);
    
    % From ZoneEntryTheta to thetaArm,
    %       ZoneEntryTheta -> ZoneTheta(iTrl)
    %       thetaArm       -> ZoneTheta(iTrl)+pi/4
    thetaOut(1:maxRad) = ZoneTheta(sd.ZoneIn(iTrl))+((thetaTmp(1:maxRad)-ZoneEntryTheta)./(thetaArm-ZoneEntryTheta)).*(pi/4);
    
    % From thetaArm to NextEntryTheta,
    %       thetaArm       -> ZoneTheta(iTrl)+pi/4
    %       NextEntryTheta -> ZoneTheta(iTrl+1)
    thetaOut(maxRad+1:end) = ZoneTheta(sd.ZoneIn(iTrl))+pi/4+((thetaTmp(maxRad+1:end)-thetaArm)./(NextEntryTheta-thetaArm)).*(pi/4);
    
    radiusOut = radiusTmp;
    
    timestamps = [timestamps; tOut];
    theta = [theta; thetaOut];
    radius = [radius; radiusOut];
end

x = tsd(timestamps,radius.*cos(theta));
y = tsd(timestamps,radius.*sin(theta));
