function [theta,radius] = RRstandardizeMaze_old(sd)
%
%
%
%
nextZone = [2 3 4 1];

[sd.x,sd.y] = RRcentreMaze(sd);
% Maze is now centered on the origin.

zoneEntryXY = nan(4,2);
zoneMaxXY = nan(4,2);
for iZ=1:4
    idZ = sd.ZoneIn==iZ;
    idN = sd.ZoneIn==nextZone(iZ);
    Tin = sd.EnteringZoneTime(idZ);
    zoneEntryXY(iZ,:) = [nanmean(sd.x.data(Tin)) nanmean(sd.y.data(Tin))];
    Tout = sd.EnteringZoneTime(idN);
    if Tout(1)<Tin(1)
        Tout(1) = [];
    end
    nTrls = min(length(Tin),length(Tout));
    
    maxR = -inf;
    maxXY = [nan nan];
    for iTrl=1:nTrls
        x = data(sd.x.restrict(Tin(iTrl),Tout(iTrl)));
        y = data(sd.y.restrict(Tin(iTrl),Tout(iTrl)));
        r = sqrt(x.^2+y.^2);
        [maxR0,idR] = max(r);
        comparisonR = [maxR maxR0];
        comparisonXY = [maxXY; x(idR) y(idR)];
        [maxR,idMax] = max(comparisonR);
        maxXY = comparisonXY(idMax,:);
    end
    zoneMaxXY(iZ,:) = maxXY;
end

theta0 = atan2(sd.y.data,sd.x.data);
radius0 = sqrt(sd.x.data.^2+sd.y.data.^2);

maxTheta = atan2(zoneMaxXY(:,2),zoneMaxXY(:,1));
entryTheta = atan2(zoneEntryXY(:,2),zoneEntryXY(:,1));
rescaledEntryTheta = round((entryTheta/pi)*2)/2*pi;
rescaledMaxTheta = round((maxTheta/pi)*4)/4*pi;

maxRadius = max(radius0);
minRadius = min(radius0);

theta = nan(length(theta0),1);
radius = nan(length(theta0),1);
for iZ=1:4
    
    if entryTheta(iZ)>0 && maxTheta(iZ)<0
        idZin = wrapTo2Pi(theta0)>=wrapTo2Pi(entryTheta(iZ)) & wrapTo2Pi(theta0)<wrapTo2Pi(maxTheta(iZ));
    else
        idZin = theta0>=entryTheta(iZ) & theta0<maxTheta(iZ);
    end
    if maxTheta(iZ)>0 && entryTheta(nextZone(iZ))<0
        idZout = wrapTo2Pi(theta0)>=wrapTo2Pi(maxTheta(iZ)) & wrapTo2Pi(theta0)<wrapTo2Pi(entryTheta(nextZone(iZ)));
    else
        idZout = theta0>=maxTheta(iZ) & theta0<entryTheta(nextZone(iZ));
    end
    
    din = theta0(idZin)-entryTheta(iZ);
    pin = din./(maxTheta(iZ)-entryTheta(iZ));
    dnew = pin*(rescaledMaxTheta(iZ)-rescaledEntryTheta(iZ));
    thetaInNew = dnew+rescaledEntryTheta(iZ);
    
    theta(idZin) = thetaInNew;
    
    dout = theta0(idZout)-maxTheta(iZ);
    pout = dout./(entryTheta(nextZone(iZ))-maxTheta(iZ));
    dnew = pout*(rescaledEntryTheta(nextZone(iZ))-rescaledMaxTheta(iZ));
    thetaOutNew = dnew+rescaledMaxTheta(iZ);
    
    theta(idZin) = thetaInNew;
    theta(idZout) = thetaOutNew;
    
    radius(idZin|idZout) = (radius0(idZin|idZout)-minRadius)./(maxRadius-minRadius)+1;
end

theta = tsd(sd.x.range,theta);
radius = tsd(sd.x.range,radius);