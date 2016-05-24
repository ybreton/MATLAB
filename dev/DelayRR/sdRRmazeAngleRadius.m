function sd = sdRRmazeAngleRadius(sd)
% Adds fields
%   .mazeAngle
%   .mazeRadius
%   .zoneAngle
% to standard session data.

xZone = nan(4,1);
yZone = nan(4,1);
for iZ=1:4
    xZone(iZ) = nanmedian(sd.x.data(sd.EnteringZoneTime(sd.ZoneIn==iZ)));
    yZone(iZ) = nanmedian(sd.y.data(sd.EnteringZoneTime(sd.ZoneIn==iZ)));
end
centerx = nanmean(xZone);
centery = nanmean(yZone);

sd.zoneAngle = atan2(yZone-centery,xZone-centerx);

x = tsd(sd.x.range,sd.x.data-centerx);
y = tsd(sd.y.range,sd.y.data-centery);

sd.mazeAngle = tsd(x.range,atan2(y.data,x.data));
sd.mazeRadius = tsd(x.range,sqrt(x.data.^2+y.data.^2));