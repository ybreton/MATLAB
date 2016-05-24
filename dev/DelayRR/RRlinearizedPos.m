function [linPos,landmarks] = RRlinearizedPos(sd,varargin)
%
%
%
%

nBins = 64;
nZones = 4;
process_varargin(varargin);
nSections = 4;

nextZone = [2 3 4 1];

% Restrict to times the rat is on track.
sd.x = sd.x.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);
sd.y = sd.y.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);

% Center maze on origin, return recentered x,y.
[x,y] = RRcentreMaze(sd);
% Calculate radial (radius) and angular (theta) distance.
sd.theta = tsd(x.range,atan2(y.data,x.data));
sd.radius = tsd(x.range,sqrt(y.data.^2+x.data.^2));
% Calculate radial velocity (radialVel).
radialVel = dxdt(sd.radius);

% Get angles for zone entry and arm location, as well as radius of zone
% entry and maximum radius of track/minimum radius of arm.
[entryTheta,armTheta,entryRadius,armRadius] = RRzoneAngles(sd);

% Set up linearized positions.
entryPos = [0:4:4*(nZones-1)]*nBins/(nSections*nZones);
armPosIn = [1:4:4*(nZones-1)+1]*nBins/(nSections*nZones);
armPosOut = [2:4:4*(nZones-1)+2]*nBins/(nSections*nZones);
exitPos = [3:4:4*(nZones-1)+3]*nBins/(nSections*nZones);

entryThetaXY = nan(2,4);
armThetaXY = nan(2,4);
feederThetaXY = nan(2,4);

ths = sd.theta.data;
rds = sd.radius.data;
times = sd.theta.range;
linearized = nan(length(ths),1);
for iZ=1:4
    anchor1 = entryTheta(iZ);
    anchor2 = armTheta(iZ);
    anchor3 = entryTheta(nextZone(iZ));
    
    % Linearize track segment to arm.
    if anchor2<anchor1
        id = wrapTo2Pi(ths)>=wrapTo2Pi(anchor1) & wrapTo2Pi(ths)<wrapTo2Pi(anchor2) & rds<armRadius(iZ);
        thZ = wrapTo2Pi(ths(id));
        [f,bin] = hist(thZ,nBins/(nSections*nZones));
        I = identifyBins(thZ,bin);
        bin = wrapToPi(bin);
    else
        id = ths>=anchor1 & ths<anchor2 & rds<=armRadius(iZ);
        thZ = ths(id);
        [f,bin] = hist(thZ,nBins/(nSections*nZones));
        I = identifyBins(thZ,bin);
    end
    linearized(id) = entryPos(iZ)+I;
    entryThetaXY(1,iZ) = entryRadius(iZ)*cos(bin(1));
    entryThetaXY(2,iZ) = entryRadius(iZ)*sin(bin(1));
    
    % Linearize arm segment.
    if anchor3<anchor1
        id = wrapTo2Pi(ths)>=wrapTo2Pi(anchor1) & wrapTo2Pi(ths)<wrapTo2Pi(anchor3) & rds>=armRadius(iZ);
    else
        id = ths>=anchor1 & ths<anchor3 & rds>armRadius(iZ);
    end
    rdZ = rds(id);
    tsZ = times(id);
    
    rvZ = radialVel.data(tsZ);
    
    I = nan(length(rvZ),1);
    idIn = rvZ>0;
    [f,binIn] = hist(rdZ(idIn),nBins/(nSections*nZones));
    I(idIn) = armPosIn(iZ)+identifyBins(rdZ(idIn),binIn);
    idOut = rvZ<0;
    [f,binOut] = hist(rdZ(idOut),nBins/(nSections*nZones));
    binOut = binOut(end:-1:1);
    I(idOut) = armPosOut(iZ)+identifyBins(rdZ(idOut),binOut);
    linearized(id) = I;
    
    armThetaXY(1,iZ) = binIn(1)*cos(armTheta(iZ));
    armThetaXY(2,iZ) = binIn(1)*sin(armTheta(iZ));
    feederThetaXY(1,iZ) = binOut(1)*cos(armTheta(iZ));
    feederThetaXY(2,iZ) = binOut(1)*sin(armTheta(iZ));
    
    % Linearize track segment from arm to next zone.
    if anchor3<anchor2
        id = wrapTo2Pi(ths)>=wrapTo2Pi(anchor2) & wrapTo2Pi(ths)<wrapTo2Pi(anchor3) & rds<armRadius(iZ);
    else
        id = ths>=anchor2 & ths<anchor3 & rds<=armRadius(iZ);
    end
    thZ = ths(id);
    [f,bin] = hist(thZ,nBins/(nSections*nZones));
    I = identifyBins(thZ,bin);
    linearized(id) = exitPos(iZ)+I;
end

linPos = tsd(times,linearized);
landmarks.SoM.LinPos = entryPos(1)+1;
landmarks.SoM.X = entryThetaXY(1,1);
landmarks.SoM.Y = entryThetaXY(2,1);
landmarks.EoM.LinPos = exitPos(end)+nBins/(nSections*nZones);
landmarks.ZoneEntry.LinPos = entryPos+1;
landmarks.ZoneEntry.X = entryThetaXY(1,:);
landmarks.ZoneEntry.Y = entryThetaXY(2,:);
landmarks.ChoicePoint.LinPos = armPosIn+1;
landmarks.ChoicePoint.X = armThetaXY(1,:);
landmarks.ChoicePoint.Y = armThetaXY(2,:);
landmarks.Feeder.LinPos = armPosOut+1;
landmarks.Feeder.X = feederThetaXY(1,:);
landmarks.Feeder.Y = feederThetaXY(2,:);
landmarks.ArmExit.LinPos = exitPos+1;
landmarks.ArmExit.X = armThetaXY(1,:);
landmarks.ArmExit.Y = armThetaXY(2,:);