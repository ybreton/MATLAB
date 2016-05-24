function [exclusions,inclusions] = RRidentifyFarPoints(sd,varargin)
% Identifies timestamps associated with position samples farther than x cm
% from an ideal path.
% sd = RRidentifyFarPoints(sd)
%
%
%
% OPTIONAL ARGUMENTS:
% ******************
% thresh        (default 10)        number of cm away from ideal path to
%                                   count as "far"

thresh = 10;
debug = false;
process_varargin(varargin);
px2cm = 1./RRpx2cm(sd,1);
threshPx = thresh*px2cm;

% start and end points, x and y
% Landmark 1: last arm 
A(:,:,1) = [sd.World.ArmLocations.x([4 1 2 3])' sd.World.ArmLocations.y([4 1 2 3])'];
% Landmark 2: start of zone
A(:,:,2) = [sd.World.ZoneLocations.x' sd.World.ZoneLocations.y'];
% Landmark 3: zone arm
A(:,:,3) = [sd.World.ArmLocations.x' sd.World.ArmLocations.y'];
% Landmark 4: zone feeder
A(:,:,4) = [sd.World.FeederLocations.x' sd.World.FeederLocations.y'];
% Landmark 5: next zone
A(:,:,5) = [sd.World.ZoneLocations.x([2 3 4 1])' sd.World.ZoneLocations.y([2 3 4 1])'];

sd.stayGo = nan(length(sd.ZoneIn),1);
sd.stayGo(1:length(sd.ExitZoneTime)) = ismember(sd.ExitZoneTime,sd.FeederTimes);

StayGo = sd.stayGo(:);

InZoneTime = sd.EnteringZoneTime(:);

ZoneIn = sd.ZoneIn(:);

OutZoneTime = [sd.EnteringZoneTime(2:end) sd.ExpKeys.TimeOffTrack];

x = sd.x.smooth(0.1,0.2);
y = sd.y.smooth(0.1,0.2);
dt = sd.x.dt;

I = nan(length(x.data),1);
X = nan(length(x.data),1);
T = x.range;
RID = tsd(T,(1:length(x.range))');

for iTrl=1:length(ZoneIn)
    iZ = ZoneIn(iTrl);
    tin = InZoneTime(iTrl);
    tout = OutZoneTime(iTrl)-dt;
    
    xZ = data(x.restrict(tin,tout));
    yZ = data(y.restrict(tin,tout));
    tZ = range(x.restrict(tin,tout));
    sg = StayGo(iTrl);
    
    idxy = false(length(xZ),3);
    idEx = false(length(xZ),3);
    B(1) = LastAlignToB(A(iZ,:,2),A(iZ,:,3),xZ,yZ);
    idxy(1:B(1),2)=true;
    
    if sg==1
        B(2) = LastAlignToA(A(iZ,:,3),A(iZ,:,4),xZ,yZ);
        if isnan(B(2)); B(2)=B(1); end
        idxy(B(1)+1:B(2),3) = true;
        idxy(B(2)+1:end,1) = true;
    else
        idxy(B(1)+1:end,1) = true;
    end
    idEx(:,1) = excludeFarPoints(A(iZ,:,3),A(iZ,:,5),xZ,yZ,threshPx);
    idEx(:,2) = excludeFarPoints(A(iZ,:,2),A(iZ,:,3),xZ,yZ,threshPx);
    idEx(:,3) = excludeFarPoints(A(iZ,:,3),A(iZ,:,4),xZ,yZ,threshPx);
    
    excludedRows = any(idEx&idxy,2);
    includedRows = ~excludedRows;
    
    if debug
        clf
        hold on
        plot(xZ(includedRows),yZ(includedRows),'.','color',[0.8 0.8 0.8])
        plot(xZ(excludedRows),yZ(excludedRows),'r.')
        plot(squeeze(A(iZ,1,:)),squeeze(A(iZ,2,:)),'kp')
        hold off
        drawnow
    end
    
    Tinc = tZ(includedRows);
    Texc = tZ(excludedRows);
    
    % Assemble.
    idIn = RID.data(Tinc);
    idEx = RID.data(Texc);
    
    I(idIn) = true;
    X(idEx) = true;
end

inclusions = ts(T(I==1));
exclusions = ts(T(X==1));

function last = LastAlignToB(A,B,Zx,Zy)
% Rotates A-to-B, then re-aligns to B. When is realigned last negative
% before the first time it is positive?
V = B-A;
N = norm(V);
theta = atan2(V(2),V(1));
rotMat = [cos(-theta) -sin(-theta); sin(-theta) cos(-theta)];
x0 = Zx-A(1);
y0 = Zy-A(2);
xyR0 = (rotMat*[x0';y0'])';
xRA = xyR0(:,1)-N;
t0 = (1:length(Zx))';
if any(xRA>0)
    pos = find(xRA>0,1,'first');
    neg = find(xRA<0&t0<pos,1,'last');
    if isempty(neg)
        neg=0;
    end
    last = neg;
else
    last = length(Zx);
end

function last = LastAlignToA(A,B,Zx,Zy)
% Rotates A-to-B, then re-aligns to A. When is realigned first negative
% after the last time it is positive?
V = B-A;
N = norm(V);
theta = atan2(V(2),V(1));
rotMat = [cos(-theta) -sin(-theta); sin(-theta) cos(-theta)];
x0 = Zx-A(1);
y0 = Zy-A(2);
xyR0 = (rotMat*[x0';y0'])';
xRA = xyR0(:,1);
t0 = (1:length(Zx))';
if any(xRA>0)
    pos = find(xRA>0,1,'last');
    neg = find(xRA<0&t0>pos,1,'first');
    if isempty(neg)
        neg=length(Zx);
    end
    last = neg;
else
    last = nan;
end

