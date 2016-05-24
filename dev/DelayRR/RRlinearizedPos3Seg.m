function [linPos,landmarks] = RRlinearizedPos3Seg(sd,varargin)
%
%
%
%

nBins = 64;
nZones = 4;
process_varargin(varargin);
nSections = 3;

nextZone = [2 3 4 1];

% Restrict to times the rat is on track.
sd.x = sd.x.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);
sd.y = sd.y.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);

% Center maze on origin, return recentered x,y.
[x,y] = RRcentreMaze(sd);
% Calculate radial (radius) and angular (theta) distance.
sd.theta = tsd(x.range,atan2(y.data,x.data));
sd.radius = tsd(x.range,sqrt(y.data.^2+x.data.^2));

% Get angles for zone entry and arm location, as well as radius of zone
% entry and maximum radius of track/minimum radius of arm.
[entryTheta,armTheta,feederTheta] = RRzoneAngles(sd);
[entryRadius,armRadius,feederRadius] = RRzoneRadii(sd);

% Set up linearized positions.
entryPos = [0:nSections:nSections*(nZones-1)]*nBins/(nSections*nZones);
armPosIn = [1:nSections:nSections*(nZones-1)+1]*nBins/(nSections*nZones);
armPosOut = [2:nSections:nSections*(nZones-1)+2]*nBins/(nSections*nZones);

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
        edges = linspace(wrapTo2Pi(anchor1),wrapTo2Pi(anchor2),nBins/(nSections*nZones)+1);
        [I,bin] = identifyBins(thZ,edges,'edges',true);
        bin = wrapToPi(bin);
    else
        id = ths>=anchor1 & ths<anchor2 & rds<=armRadius(iZ);
        thZ = ths(id);
        edges = linspace(anchor1,anchor2,nBins/(nSections*nZones)+1);
        [I,bin] = identifyBins(thZ,edges,'edges',true);
    end
    I(I>8) = 8;
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
    
    edges = linspace(armRadius(iZ),feederRadius(iZ),nBins/(nSections*nZones)+1);
    [I,bin] = identifyBins(rdZ,edges,'edges',true);
    I(I>8) = 8;
    linearized(id) = armPosIn(iZ)+I;
    
    armThetaXY(1,iZ) = bin(1)*cos(armTheta(iZ));
    armThetaXY(2,iZ) = bin(1)*sin(armTheta(iZ));
    feederThetaXY(1,iZ) = bin(end)*cos(armTheta(iZ));
    feederThetaXY(2,iZ) = bin(end)*sin(armTheta(iZ));
    
    % Linearize track segment from arm to next zone.
    if anchor3<anchor2
        id = wrapTo2Pi(ths)>=wrapTo2Pi(anchor2) & wrapTo2Pi(ths)<wrapTo2Pi(anchor3) & rds<armRadius(iZ);
        thZ = wrapTo2Pi(ths(id));
        edges = linspace(wrapTo2Pi(anchor2),wrapTo2Pi(anchor3),nBins/(nSections*nZones)+1);
    else
        id = ths>=anchor2 & ths<anchor3 & rds<=armRadius(iZ);
        thZ = ths(id);
        edges = linspace(anchor2,anchor3,nBins/(nSections*nZones)+1);
    end
    [I,bin] = identifyBins(thZ,edges,'edges',true);
    I(I>8) = 8;
    linearized(id) = armPosOut(iZ)+I;
end

linPos = tsd(times,linearized);
landmarks.SoM.LinPos = entryPos(1)+1;
landmarks.SoM.X = entryThetaXY(1,1);
landmarks.SoM.Y = entryThetaXY(2,1);
landmarks.EoM.LinPos = armPosOut(end)+nBins/(nSections*nZones);
landmarks.ZoneEntry.LinPos = entryPos+1;
landmarks.ZoneEntry.X = entryThetaXY(1,:);
landmarks.ZoneEntry.Y = entryThetaXY(2,:);
landmarks.ChoicePoint.LinPos = armPosIn+1;
landmarks.ChoicePoint.X = armThetaXY(1,:);
landmarks.ChoicePoint.Y = armThetaXY(2,:);
landmarks.Feeder.LinPos = armPosOut;
landmarks.Feeder.X = feederThetaXY(1,:);
landmarks.Feeder.Y = feederThetaXY(2,:);
landmarks.ArmExit.LinPos = armPosOut+1;
landmarks.ArmExit.X = armThetaXY(1,:);
landmarks.ArmExit.Y = armThetaXY(2,:);