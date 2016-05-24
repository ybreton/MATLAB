function [rotX,rotY] = RRrotateXY(sd)
%
%
%
%

for iZ=1:4
    idx = sd.ZoneIn==iZ;
    xZ(iZ) = nanmedian(sd.x.data(sd.EnteringCPTime(idx)));
    yZ(iZ) = nanmedian(sd.y.data(sd.EnteringCPTime(idx)));
end
xCentre = nanmean(xZ);
yCentre = nanmean(yZ);

startTime = sd.EnteringCPTime;
stopTime = [sd.EnteringCPTime(2:end) sd.ExpKeys.TimeOffTrack];

t = sd.x.range;
xPrime = nan(length(t),1);
yPrime = nan(length(t),1);
for iTrl = 1 : length(startTime)
    xZ = sd.x.data(startTime(iTrl))-xCentre;
    yZ = sd.y.data(startTime(iTrl))-yCentre;
    theta = atan2(yZ,xZ);
    
    rotMat = [cos(-theta) -sin(-theta); sin(-theta) cos(-theta)];
    % rotation matrix.
    idx = t>=startTime(iTrl)&t<stopTime(iTrl);
    
    x0 = sd.x.data(t(idx))-xCentre;
    y0 = sd.y.data(t(idx))-yCentre;
    
    xyPrime = rotMat*[x0';y0'];
    xPrime(idx) = xyPrime(1,:);
    yPrime(idx) = xyPrime(2,:);
end

rotX = tsd(t,xPrime);
rotY = tsd(t,yPrime);