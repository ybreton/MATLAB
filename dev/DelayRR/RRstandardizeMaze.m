function [theta,radius] = RRstandardizeMaze(sd,varargin)
%
%
%
%

thetaArm = [-pi/4 pi/4 3*pi/4 -3*pi/4];
trackWidth = 50;
process_varargin(varargin);
nZones = length(thetaArm);
nextZone = [2 3 4 1];

% Restrict to times the rat is actually on track.
sd.x = sd.x.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);
sd.y = sd.y.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);

[x,y] = RRcentreMaze(sd);
% Maze is now centered on the origin.
thetaIn = tsd(x.range,atan2(y.data,x.data));
radiusIn = tsd(x.range,sqrt(y.data.^2+x.data.^2));
% Angle and radius from the recentered maze.
maxX = max(x.data);
minX = min(x.data);
maxY = max(y.data);
minY = min(y.data);

armZone = nan(nZones,1);
trackZone = nan(nZones,1);
stayGo = RRGetStaygo(sd);

% identify zone arm angles and track widths.
for iZ=1:nZones
    enterZone = sd.EnteringZoneTime(iZ:nZones:end);
    leaveZone = sd.EnteringZoneTime(iZ+1:nZones:end);
    stayZone = stayGo(iZ:nZones:end)==1;
    nTrls = length(leaveZone);
    Zang = nan(nTrls,length(data(thetaIn.restrict(enterZone(1:nTrls),leaveZone(1:nTrls)))));
    entryZoneRadius = nan(nTrls,1);
    for iTrl=1:nTrls
        datAng = data(thetaIn.restrict(enterZone(iTrl),leaveZone(iTrl)));
        nPts = length(datAng);
        Zang(iTrl,1:nPts) = datAng;
        entryZoneRadius(iTrl,:) = radiusIn.data(enterZone(iTrl));
    end
    armZone(iZ) = nanmedian(nanmedian(Zang(stayZone,:),2));
    trackRad(iZ) = nanmedian(entryZoneRadius);
end
% armZone contains the median (across trials) arm location for each zone.
% trackRad contains the median (across trials) radius of the track.

% identify zone feeder distances.
xList = linspace(minX,maxX,(ceil(maxX)-floor(minX))/2);
yList = linspace(minY,maxY,(ceil(maxY)-floor(minY))/2);

for iZ=1:nZones
    enterZone = sd.EnteringZoneTime(iZ:nZones:end);
    leaveZone = sd.EnteringZoneTime(iZ+1:nZones:end);
    stayZone = stayGo(iZ:nZones:end)==1;
    nTrls = length(leaveZone);
    feederRad = nan(nTrls,1);
    for iTrl=1:nTrls
        datRad = data(radiusIn.restrict(enterZone(iTrl),leaveZone(iTrl)));
        datAng = data(thetaIn.restrict(enterZone(iTrl),leaveZone(iTrl)));
        idArm = datRad>trackRad(iZ)+trackWidth;
        x0 = datRad(idArm).*cos(datAng(idArm));
        y0 = datRad(idArm).*sin(datAng(idArm));
        if stayZone(iTrl) && ~isempty(x0) && ~isempty(y0)
            h = histcn([x0 y0],xList,yList);
            [~,pkX] = max(max(h,[],2));
            [~,pkY] = max(max(h,[],1));
            feederRad(iTrl) = sqrt(xList(pkX).^2+yList(pkY).^2);
        end
    end
    armRad(iZ) = nanmedian(feederRad);
end

theta = thetaIn.data;
thRot = nan(length(theta),1);
for iZ=1:nZones
    anchor1 = armZone(iZ);
    rescaled1 = thetaArm(iZ);
    anchor2 = armZone(nextZone(iZ));
    rescaled2 = thetaArm(nextZone(iZ));
    
    if anchor2<anchor1
        id = wrapTo2Pi(theta)>=wrapTo2Pi(anchor1) & wrapTo2Pi(theta)<wrapTo2Pi(anchor2);
        ths = wrapTo2Pi(theta(id));
        dTheta = ths - wrapTo2Pi(anchor1);
        p = dTheta./(wrapTo2Pi(anchor2)-wrapTo2Pi(anchor1));
        thRot(id) = wrapToPi(wrapTo2Pi(rescaled1)+(wrapTo2Pi(rescaled2)-wrapTo2Pi(rescaled1))*p);
    else
        id = theta>=anchor1 & theta<anchor2;
        ths = theta(id);
        dTheta = ths - anchor1;
        p = dTheta./(anchor2-anchor1);
        thRot(id) = rescaled1+(rescaled2-rescaled1)*p;
    end
end

% thRot contains theta angle values rotated and rescaled so each arm is at
% pi/2 increments starting at -3*pi/4

radius = radiusIn.data;
radRot = nan(length(radius),1);
for iZ=1:nZones
    rescaled1 = thetaArm(iZ);
    rescaled2 = thetaArm(nextZone(iZ));
    
    if rescaled2<rescaled1
        id = wrapTo2Pi(thRot)>=wrapTo2Pi(anchor1) & wrapTo2Pi(thRot)<wrapTo2Pi(anchor2);
        rds = radius(id);
        
    else
        id = thRot>=anchor1 & thRot<anchor2;
        
        
    end
end

theta = tsd(sd.x.range,thRot);
radius 