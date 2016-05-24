function [lin,landmarks,seg,zon] = RRLinearizeIdealPath_old(sd,varargin)
% Linearizes the path in sd according to World aligning to landmarks in
% World. Linearized landmarks are also returned. 
% Segment assignments and zones can also be returned.
% [lin,landmarks] = RRLinearizeIdealPath(sd)
% where     lin             is tsd of linearized position,
%           landmarks       is structure of linearized landmarks, with 1 x nZone fields
%                       .ZoneEntry      Entry into zone (stays and skips)
%                       .ArmIn          Entry into arm (stays)
%                       .Feeder         Arrival at feeder (stays)
%                       .ArmOut         Exit from arm (stays)
%                       .ZoneExit       Exit from zone (stays)
%                       .SkipArm        Arrival at skipped arm (skips)
%                       .SkipExit       Exit from zone (skips)
%                           and with 1xnSegments fields
%                       .StaySequence       Sequence of mean linearized
%                                           position of stay landmarks:
%                                           [ZoneEntry ArmIn Feeder ArmOut ZoneExit]
%                       .StaySeqLabels      Labels of linearized stay
%                                           landmarks:
%                                           {'S' 'A in' 'F' 'A out' 'X'}
%                       .SkipSequence       Sequence of mean linearized
%                                           position of skip landmarks:
%                                           [ZoneEntry SkipArm SkipExit]
%                       .SkipSeqLabels      Labels of linearized skip
%                                           landmarks:
%                                           {'S' 'A' 'X'}
%
%           sd              is standard session data structre.
%
% [lin,landmarks,seg,zon] = RRLinearizeIdealPath(sd)
% where     seg             is tsd of assigned segment (see below)
%           zon             is tsd of zone identity.
% 
% OPTIONAL ARGUMENTS:
% ******************
% normFact  (default 1)             4x1 vector of normalization factors.
%                                   Projection onto vector v is normalized
%                                   from 0 to 1 and then multiplied by
%                                   normalization factor normFact. If any
%                                   normFact is NaN, the normalization
%                                   factor is the longest norm of the set
%                                   of projection vectors.
%
% stays:
% ZoneEntry to Arm (seg 1)
% Arm to Feeder (2)
% Feeder to Arm (3)
% Arm to nextZone (4)
% skips:
% ZoneEntry to Arm (1)
% Arm to nextZone (4)
% 
normFact = ones(4,1);
process_varargin(varargin);

sd.stayGo = nan(length(sd.ZoneIn),1);
sd.stayGo(1:length(sd.ExitZoneTime)) = ismember(sd.ExitZoneTime,sd.FeederTimes);

L = nan(length(sd.x.data),3);
T = tsd(sd.x.range,(1:length(sd.x.range))');

x = sd.x.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);
y = sd.y.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);
x = x.smooth(0.1, 0.2);
y = y.smooth(0.1, 0.2);
dt = sd.x.dt;

% start and end points, x and y
A(:,:,1) = [sd.World.ZoneLocations.x' sd.World.ZoneLocations.y'];
A(:,:,2) = [sd.World.ArmLocations.x' sd.World.ArmLocations.y'];
A(:,:,3) = [sd.World.FeederLocations.x' sd.World.FeederLocations.y'];
A(:,:,4) = [sd.World.ZoneExitLocations.x' sd.World.ZoneExitLocations.y'];
A(:,:,5) = [sd.World.ZoneLocations.x([2 3 4 1])' sd.World.ZoneLocations.y([2 3 4 1])'];

% Vectors of segments of interests
v1 = A(:,:,2)-A(:,:,1);
v2 = A(:,:,3)-A(:,:,2);
v3 = A(:,:,2)-A(:,:,3);
v4 = A(:,:,5)-A(:,:,2);
v = cat(3,v1,v2,v3,v4);
u = v;

if isnan(normFact(1))
    for iV=1:size(v1,1)
        normFact(1) = max(normFact(1),norm(v1(iV,:)));
    end
end
if isnan(normFact(2))
    for iV=1:size(v2,1)
        normFact(2) = max(normFact(2),norm(v2(iV,:)));
    end
end
if isnan(normFact(3))
    for iV=1:size(v3,1)
        normFact(3) = max(normFact(3),norm(v3(iV,:)));
    end
end
if isnan(normFact(4))
    for iV=1:size(v4,1)
        normFact(4) = max(normFact(4),norm(v4(iV,:)));
    end
end

% Prepare the v vector
vn = nan(size(v,1),1,size(v,3));
N=nan(size(v,3),1);
for iV=1:size(v,3)
    % the norm of each vector
    vt = v(:,:,iV)*v(:,:,iV)';
    vn(:,1,iV) = sqrt(vt(eye(size(vt))==1));
    % Longest norm
    Nmax = max(vn(:,1,iV));
    % Unit vector
    u0 = v(:,:,iV)./repmat(vn(:,1,iV),1,2);
    % Rescale all to longest norm
    v(:,:,iV) = u0*Nmax;
    u(:,:,iV) = u0;
    N(iV) = Nmax;
end


% Prepare landmarks
ZoneEntry = nan(length(sd.ZoneIn),4);
SkipArm = nan(length(sd.ZoneIn),4);
SkipExit = nan(length(sd.ZoneIn),4);
ArmIn = nan(length(sd.ZoneIn),4);
Feeder = nan(length(sd.ZoneIn),4);
ArmOut = nan(length(sd.ZoneIn),4);
ZoneExit = nan(length(sd.ZoneIn),4);

InZoneTime = sd.EnteringZoneTime;
OutZoneTime = [sd.EnteringZoneTime(2:end) sd.ExpKeys.TimeOffTrack];
for iTrl=1:length(sd.ZoneIn)
    iZ = sd.ZoneIn(iTrl);
    tin = InZoneTime(iTrl);
    tout = OutZoneTime(iTrl)-dt;
    
    xZ = data(x.restrict(tin,tout));
    yZ = data(y.restrict(tin,tout));
    tZ = range(x.restrict(tin,tout));
    sg = sd.stayGo(iTrl);
    
    
    idxy = false(length(xZ),4);
    B = [];
    v1 = v(iZ,:,1);
    v2 = v(iZ,:,2);
    v3 = v(iZ,:,3);
    v4 = v(iZ,:,4);
    u1 = u(iZ,:,1);
    u2 = u(iZ,:,2);
    u3 = u(iZ,:,3);
    u4 = u(iZ,:,4);
    if sg==1
        B(1) = IdentifyFirstTime(A(iZ,:,3),A(iZ,:,2),xZ,yZ);
        B(2) = IdentifyLastTime(A(iZ,:,3),A(iZ,:,2),xZ,yZ)+1;
        cols = [1 3 4];
        idxy(1:B(1)-1,1)=true;
        idArmxy = false(size(idxy,1),1);
        idArmxy(B(1):B(2)-1)=true;
        
        % separate into and out of arm.
        CDp = projectionNormalized([xZ(idArmxy)-A(iZ,1,2) yZ(idArmxy)-A(iZ,2,2)],A(iZ,:,3)-A(iZ,:,2),normFact(2));
        ArmVel = dxdt(tsd(tZ(idArmxy),CDp));
        VelDat = ArmVel.data;
        VelTim = ArmVel.range;
        % The last time velocity is positive is the last time he's headed
        % toward the feeder.
        idLastPos = find(VelDat>0,1,'last');
        % If this is empty, he never headed toward the feeder: all arm
        
        % The first time velocity is negative after that is the next time
        % he's headed toward the arm
        idFirstNeg = find(VelDat<0&(1:length(VelDat))'>=idLastPos,1,'first');
        % If this is empty, he never headed to the arm: all feeder
        
        if ~isempty(idFirstNeg)&~isempty(idLastPos)
            % if he moves from going feeder-bound to arm-bound, the time
            % point at which that changes is where the velocity to feeder
            % crosses the y axis.
            PosToNegT = VelTim(idLastPos:idFirstNeg);
            PosToNegV = VelDat(idLastPos:idFirstNeg);
            % Fit a line, and solve for y=0.
            b = glmfit(PosToNegT-tin,PosToNegV,'normal');
            t0 = -b(1)/b(2);
            idxy(idArmxy&tZ<t0+tin,2)=true;
            idxy(idArmxy&tZ>=t0+tin,3)=true;
        elseif ~isempty(idLastPos)
            idxy(idArmxy,2)=true;
        elseif ~isempty(idFirstNeg)
            idxy(idArmxy,3)=true;
        end
        
        idxy(B(2):end,4)=true;
        
        % Projection of xy onto Av, normalized.
        Ap = projectionNormalized([xZ(idxy(:,1))-A(iZ,1,1) yZ(idxy(:,1))-A(iZ,2,1)],v1,normFact(1))-(norm(u1)*normFact(1));
        Ta = tZ(idxy(:,1));
        Bp = projectionNormalized([xZ(idxy(:,2))-A(iZ,1,2) yZ(idxy(:,2))-A(iZ,2,2)],v2,normFact(2));
        Tb = tZ(idxy(:,2));
        Cp = norm(u2)+projectionNormalized([xZ(idxy(:,3))-A(iZ,1,3) yZ(idxy(:,3))-A(iZ,2,3)],v3,normFact(3));
        Tc = tZ(idxy(:,3));
        Dp = norm(u2)+norm(u3)+projectionNormalized([xZ(idxy(:,4))-A(iZ,1,2) yZ(idxy(:,4))-A(iZ,2,2)],v4,normFact(4));
        Td = tZ(idxy(:,4));
        
        ZoneEntry(iTrl,iZ) = -norm(u1)*normFact(1);
        ArmIn(iTrl,iZ) = projectionNormalized(v1,v1,normFact(1))-(norm(u1)*normFact(1));
        Feeder(iTrl,iZ) = projectionNormalized(v2,v2,normFact(2));
        ArmOut(iTrl,iZ) = norm(u2)+projectionNormalized(v3,v3,normFact(3));
        ZoneExit(iTrl,iZ) = norm(u2)+norm(u3)+projectionNormalized(v4,v4,normFact(4));
    else
        B(1) = length(xZ)-IdentifyLastTime(A(iZ,:,5),A(iZ,:,2),xZ(end:-1:1),yZ(end:-1:1))+1;
        cols = [1 4];
        idxy(1:B(1)-1,1)=true;
        idxy(B(1):end,4)=true;
        
        % Projection of xy onto Av, normalized.
        Ap = projectionNormalized([xZ(idxy(:,1))-A(iZ,1,1) yZ(idxy(:,1))-A(iZ,2,1)],v1,normFact(1))-(norm(u1)*normFact(1));
        Ta = tZ(idxy(:,1));
        Bp = [];
        Tb = [];
        Cp = [];
        Tc = [];
        Dp = norm(u2)+norm(u3)+projectionNormalized([xZ(idxy(:,4))-A(iZ,1,2) yZ(idxy(:,4))-A(iZ,2,2)],v4,normFact(4));
        Td = tZ(idxy(:,4));
        
        ZoneEntry(iTrl,iZ) = -norm(u1)*normFact(1);
        SkipArm(iTrl,iZ) = projectionNormalized(v1,v1,normFact(1))-(norm(u1)*normFact(1));
        SkipExit(iTrl,iZ) = norm(u2)+norm(u3)+projectionNormalized(v4,v4,normFact(4));
    end
    
    % Assemble.
    idA = T.data(Ta);
    idB = T.data(Tb);
    idC = T.data(Tc);
    idD = T.data(Td);
    
    L(idA,1) = Ap;
    L(idB,1) = Bp;
    L(idC,1) = Cp;
    L(idD,1) = Dp;
    
    L(idA,2) = 1;
    L(idB,2) = 2;
    L(idC,2) = 3;
    L(idD,2) = 4;
    
    L(idA,3) = iZ;
    L(idB,3) = iZ;
    L(idC,3) = iZ;
    L(idD,3) = iZ;
end
lin = tsd(sd.x.range,L(:,1));
landmarks.ZoneEntry = nanmean(ZoneEntry,1);
landmarks.ArmIn = nanmean(ArmIn,1);
landmarks.Feeder = nanmean(Feeder,1);
landmarks.ArmOut = nanmean(ArmOut,1);
landmarks.ZoneExit = nanmean(ZoneExit,1);
landmarks.SkipArm = nanmean(SkipArm,1);
landmarks.SkipExit = nanmean(SkipExit,1);
landmarks.StaySequence = [nanmean(landmarks.ZoneEntry,2) nanmean(landmarks.ArmIn,2) nanmean(landmarks.Feeder,2) nanmean(landmarks.ArmOut,2) nanmean(landmarks.ZoneExit,2)];
landmarks.SkipSequence = [nanmean(landmarks.ZoneEntry,2) nanmean(landmarks.SkipArm,2) nanmean(landmarks.SkipExit,2)];
landmarks.StaySeqLabels = {'S' 'A in' 'F' 'A out' 'X'};
landmarks.SkipSeqLabels = {'S' 'A' 'X'};

seg = tsd(sd.x.range,L(:,2));
zon = tsd(sd.x.range,L(:,3));

function P = projectionNormalized(A,B,normFact)
% project A onto B.
Bn = norm(B);
N = B/Bn;
A = A/Bn;
P = nan(size(A,1),1);
for iP=1:size(A,1)
    P(iP) = dot(A(iP,:),N)*normFact;
end
P(P>normFact) = normFact;

function first = IdentifyFirstTime(A,B,Zx,Zy)
V = B-A;
N = norm(V);
theta = atan2(V(2),V(1));
rotMat = [cos(-theta) -sin(-theta); sin(-theta) cos(-theta)];
xA = Zx-A(1);
yA = Zy-A(2);
xyR = (rotMat*[xA';yA'])';
t0 = (1:length(Zx))';
xRA = (xyR(:,1)-N);
if any(xRA<0)
    neg = find(xRA<0,1,'first');
    pos = find(xRA>0&t0<neg,1,'last');
    if isempty(pos)
        pos=0;
    end
    first = pos+1;
else
    first = 1;
end

function last = IdentifyLastTime(A,B,Zx,Zy)
V = B-A;
N = norm(V);
theta = atan2(V(2),V(1));
rotMat = [cos(-theta) -sin(-theta); sin(-theta) cos(-theta)];
xA = Zx-A(1);
yA = Zy-A(2);
xyR = (rotMat*[xA';yA'])';
t0 = (1:length(Zx))';
xRA = (xyR(:,1)-N);
if any(xRA<0)
    neg = find(xRA<0,1,'last');
    pos = find(xRA>0&t0>neg,1,'first');
    if isempty(pos)
        pos = length(Zx)+1;
    end
    last = pos-1;
else
    last = length(Zx);
end