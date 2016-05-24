function [lin,landmarks,seg,zon,dist2vec] = RRLinearizeIdealPath(sd,varargin)
% Linearizes the path in sd according to World aligning to landmarks in
% World. Linearized landmarks are also returned. 
% Segment assignments and zones can also be returned.
% [lin,landmarks] = RRLinearizeIdealPath(sd)
% where     lin             is tsd of linearized position,
%           landmarks       is structure of linearized landmarks, with 1 x nZone fields
%                       .Start          Zone entry (stays and skips)
%                       .InArm          Arriving at arm (stays and skips)
%                       .Feeder         Arrival at feeder (stays)
%                       .OutArm         Exit from feeder (stays)
%                       .Exit           Zone exit (stays and skips)
%
%                           and with 1 x nSegments fields
%                       .StaySequence       Sequence of mean linearized
%                                           position of stay landmarks:
%                                           [PrevArm Start InArm Feeder OutArm]
%                       .StaySeqLabels      Labels of linearized stay
%                                           landmarks:
%                                           {'S' 'in' 'F' 'out' 'X'}
%                       .SkipSequence       Sequence of mean linearized
%                                           position of skip landmarks:
%                                           [PrevArm Start InArm]
%                       .SkipSeqLabels      Labels of linearized skip
%                                           landmarks:
%                                           {'S' 'in' 'X'}
%
%           sd              is standard session data structre.
%
% [lin,landmarks,seg,zon,dist2vec] = RRLinearizeIdealPath(sd)
% where     seg             is tsd of assigned segment (see below)
%           zon             is tsd of zone identity.
%           dist2vec        is tsd of shortest distance to ideal vector.
% 
% OPTIONAL ARGUMENTS:
% ******************
% normFact  (default 1)             nZone x nSegment vector of
%                                   normalization factors. Projection onto
%                                   vector v is normalized from 0 to 1 and
%                                   then multiplied by normalization factor
%                                   normFact. If any normFact is NaN, v is
%                                   normalized by its own norm (i.e., not
%                                   normalized).
% startStay (default [0 1 2 3; 0 1 2 3; 0 1 2 3; 0 1 2 3])
%                                   nZone x nSegment vector of start
%                                   positions for each stay segment.
% startSkip (default [0 1; 0 1; 0 1; 0 1])
%                                   nZone x nSegment vector of start
%                                   positions for each skip segment.
%
% if any of the start values are NaN, they cumulate the segment norms so
% far.
%
% stays:
% ZoneEntry to Arm (1)
% Arm to Feeder (2)
% Feeder to Arm (3)
% Arm to Exit (4)
%
% skips:
% ZoneEntry to Arm (1)
% Arm to Exit (2)
%
% Linearized position is aligned to ZoneEntry. If all segments have
% normalization factor of 1 and the default stay/skip segment start
% positions, then stays have the sequence:
% Zone entry -> Cur arm:            [ 0 1]
% Cur arm -> Feeder:                [ 1 2]
% Feeder -> Arm out:                [ 2 3]
% Arm out -> Zone exit:             [ 3 4]
% and skips have the sequence:
% Zone entry -> Cur arm:            [ 0 1]
% Cur arm -> Zone exit:             [ 1 2]
%
%
% 
normFact = ones(4);
startStay = [0 1 2 3;
             0 1 2 3;
             0 1 2 3;
             0 1 2 3];
startSkip = [0 1;
             0 1;
             0 1;
             0 1];
process_varargin(varargin);

sd.stayGo = nan(length(sd.ZoneIn),1);
sd.stayGo(1:length(sd.ExitZoneTime)) = ismember(sd.ExitZoneTime,sd.FeederTimes);

% Get x and y positions
x = sd.x.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);
y = sd.y.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);

% Initialize linearized position vector
L = nan(length(x.data),4);
% Initialize tsd of time indices
T = tsd(x.range,(1:length(x.range))');

% Smooth x and y positions
x = x.smooth(0.1, 0.2);
y = y.smooth(0.1, 0.2);
dt = sd.x.dt;

% start and end points, x and y
% Landmark 1: start of zone
A(:,:,1) = [sd.World.ZoneLocations.x' sd.World.ZoneLocations.y'];
% Landmark 2: zone arm
A(:,:,2) = [sd.World.ArmLocations.x' sd.World.ArmLocations.y'];
% Landmark 3: zone feeder
A(:,:,3) = [sd.World.FeederLocations.x' sd.World.FeederLocations.y'];
% Landmark 4: next zone
A(:,:,4) = [sd.World.ZoneLocations.x([2 3 4 1])' sd.World.ZoneLocations.y([2 3 4 1])'];

% Vectors of segments of interests
% Segment 1: start of zone to arm
v(:,:,1) = A(:,:,2)-A(:,:,1);
% Segment 2: arm to feeder
v(:,:,2) = A(:,:,3)-A(:,:,2);
% Segment 3: feeder back to arm
v(:,:,3) = A(:,:,2)-A(:,:,3);
% Segment 4: arm to zone exit
v(:,:,4) = A(:,:,4)-A(:,:,2);

u = v;

% Prepare the u vector
vn = nan(size(v,1),1,size(v,3));
for iV=1:size(v,3)
    % the norm of each vector
    vt = v(:,:,iV)*v(:,:,iV)';
    vn(:,1,iV) = sqrt(vt(eye(size(vt))==1));
    % Unit vector
    u0 = v(:,:,iV)./repmat(vn(:,1,iV),1,2);
    % Rescale unit vector by normFact.
    f = normFact(:,iV);
    % wherever normFact is nan, do not normalize.
    f(isnan(f)) = vn(isnan(f),1,iV);
    u(:,:,iV) = u0.*repmat(f,1,2);
end

% v is non-normalized vector of segments
% u is normalized vector of segments with norm normFact.

% if any startStay values are NaN, previous start+prev norm
if isnan(startStay(1)); startStay(1)=0; end;
startStay0=startStay';
sz1=size(startStay0);
startStay0=startStay0(:);
N = nan(size(u,1),size(u,3));
for iZ=1:size(u,1)
    for iV=1:size(u,3)
        N(iZ,iV) = norm(squeeze(u(iZ,:,iV)));
    end
end
N0=N';
sz2=size(N);
N0 = N0(:);
for iSeg=2:length(startStay0)
    if isnan(startStay0(iSeg));
        startStay0(iSeg) = startStay0(iSeg-1)+N0(iSeg-1);
    end
end
startStay0=reshape(startStay0,sz1);
startStay=startStay0';
N0=reshape(N0,sz2);
N=N0';
startStay(:,end+1) = startStay(:,end)+N(:,4);

labelStay = cell(size(startStay));
for iZ=1:size(startStay,1)
    labelStay(iZ,:) = {sprintf('S%d',iZ) sprintf('In%d',iZ) sprintf('F%d',iZ) sprintf('Out%d',iZ) sprintf('X%d',iZ)};
end
[staySeq,idUnique] = unique(startStay(:),'first');
staySeqLbl = labelStay(idUnique);

landmarks.Stay.Start = startStay(:,1)';
landmarks.Stay.InArm = startStay(:,2)';
landmarks.Stay.Feeder = startStay(:,3)';
landmarks.Stay.OutArm = startStay(:,4)';
landmarks.Stay.Exit = startStay(:,4)'+N(:,4)';

landmarks.Stay.Sequence = staySeq;
landmarks.Stay.SeqLabels = staySeqLbl;

% if any startSkip values are NaN, previous start+prev norm
if isnan(startSkip(1)); startSkip(1)=0; end;
startSkip0=startSkip';
sz1=size(startSkip0);
startSkip0=startSkip0(:);
N = nan(size(u,1),2);
col=[1 4];
for iZ=1:size(u,1)
    for iV=1:2;
        N(iZ,iV) = norm(squeeze(u(iZ,:,col(iV))));
    end
end
N0=N';
sz2=size(N0);
N0 = N0(:);
for iSeg=2:length(startSkip0)
    if isnan(startSkip0(iSeg));
        startSkip0(iSeg) = startSkip0(iSeg-1)+N0(iSeg-1);
    end
end
startSkip0=reshape(startSkip0,sz1);
startSkip=startSkip0';
N0=reshape(N0,sz2);
N=N0';
startSkip(:,end+1) = startSkip(:,end)+N(:,2);

labelSkip = cell(size(startSkip));
for iZ=1:size(startSkip,1)
    labelSkip(iZ,:) = {sprintf('S%d',iZ) sprintf('A%d',iZ) sprintf('X%d',iZ)};
end
[skipSeq,idUnique] = unique(startSkip(:),'first');
skipSeqLbl = labelSkip(idUnique);

landmarks.Skip.Start = startSkip(:,1)';
landmarks.Skip.Arm = startSkip(:,2)';
landmarks.Skip.Exit = startSkip(:,2)'+N(:,2)';

landmarks.Skip.Sequence = skipSeq;
landmarks.Skip.SeqLabels = skipSeqLbl;

StayGo = sd.stayGo(:);

InZoneTime = sd.EnteringZoneTime(:);

ZoneIn = sd.ZoneIn(:);

OutZoneTime = [sd.EnteringZoneTime(2:end) sd.ExpKeys.TimeOffTrack];

for iTrl=1:length(ZoneIn)
    iZ = ZoneIn(iTrl);
    tin = InZoneTime(iTrl);
    tout = OutZoneTime(iTrl)-dt;
    
    xZ = data(x.restrict(tin,tout));
    yZ = data(y.restrict(tin,tout));
    tZ = range(x.restrict(tin,tout));
    sg = StayGo(iTrl);
    
    idxy = false(length(xZ),4);
    d = nan(length(xZ),4);
    d(:,1) = calcDist(A(iZ,:,1),A(iZ,:,2),xZ,yZ);
    d(:,2) = calcDist(A(iZ,:,2),A(iZ,:,3),xZ,yZ);
    d(:,3) = calcDist(A(iZ,:,3),A(iZ,:,2),xZ,yZ);
    d(:,4) = calcDist(A(iZ,:,2),A(iZ,:,4),xZ,yZ);
    [d,closestV] = min(d,[],2);
    for iR=1:length(closestV)
        idxy(iR,closestV(iR))=true;
    end
    
    % Projections onto each vector and times
    P1 = [];
    D1 = [];
    T1 = [];
    P2 = [];
    D2 = [];
    T2 = [];
    P3 = [];
    D3 = [];
    T3 = [];
    P4 = [];
    D4 = [];
    T4 = [];
    if sg==1
        idArmxy = idxy(:,2)|idxy(:,3);
        firstArm = find(idArmxy,1,'first');
        lastArm = find(idArmxy,1,'last');
        
        idArmxy(firstArm:lastArm) = true;
        idxy(:,:) = false;
        
        idxy(1:firstArm-1,1) = true;
        if lastArm<size(idxy,1)
            idxy(lastArm+1:end,4) = true;
        end

%         B(1) = LastAlignToB(A(iZ,:,1),A(iZ,:,2),xZ,yZ);
%         idxy(1:B(1),1)=true;
%         
        % segment 1, from 0 to 1:
        P1 = startStay(iZ,1)+projectionNormalized([xZ(idxy(:,1))-A(iZ,1,1) yZ(idxy(:,1))-A(iZ,2,1)],v(iZ,:,1),u(iZ,:,1));
        D1 = calcDist(A(iZ,:,1),A(iZ,:,2),xZ(idxy(:,1)),yZ(idxy(:,1)));
        T1 = tZ(idxy(:,1));
%         
%         B(2) = LastAlignToA(A(iZ,:,2),A(iZ,:,3),xZ,yZ);
%         if isnan(B(2)); B(2)=B(1); end
%         idArmxy = false(size(idxy,1),1);
%         idArmxy(B(1)+1:B(2))=true;
        
        % separate into and out of arm.
        P23 = projectionNormalized([xZ(idArmxy)-A(iZ,1,2) yZ(idArmxy)-A(iZ,2,2)],v(iZ,:,2),u(iZ,:,2));
        if ~isempty(P23);
            ArmVel = dxdt(tsd(tZ(idArmxy),P23));
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

            if ~isempty(idFirstNeg)&&~isempty(idLastPos)
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
%         else
%             disp('Did not enter arm on stay.')
        end
%         idxy(B(2)+1:end,4) = true;
        
        % segment 2, from 1 to 2
        P2 = startStay(iZ,2)+projectionNormalized([xZ(idxy(:,2))-A(iZ,1,2) yZ(idxy(:,2))-A(iZ,2,2)],v(iZ,:,2),u(iZ,:,2));
        D2 = calcDist(A(iZ,:,2),A(iZ,:,3),xZ(idxy(:,2)),yZ(idxy(:,2)));
        T2 = tZ(idxy(:,2));
        % segment 3, from 2 to 3
        P3 = startStay(iZ,3)+projectionNormalized([xZ(idxy(:,3))-A(iZ,1,3) yZ(idxy(:,3))-A(iZ,2,3)],v(iZ,:,3),u(iZ,:,3));
        D3 = calcDist(A(iZ,:,3),A(iZ,:,2),xZ(idxy(:,3)),yZ(idxy(:,3)));
        T3 = tZ(idxy(:,3));
        % segment 4, from -1 to 0
        P4 = startStay(iZ,4)+projectionNormalized([xZ(idxy(:,4))-A(iZ,1,2) yZ(idxy(:,4))-A(iZ,2,2)],v(iZ,:,4),u(iZ,:,4));
        D4 = calcDist(A(iZ,:,2),A(iZ,:,4),xZ(idxy(:,4)),yZ(idxy(:,4)));
        T4 = tZ(idxy(:,4));
    else
        last1 = find(idxy(:,1),1,'last');
        first4 = find(idxy(:,4),1,'first');
        idxy(:,:) = false;
        idxy(1:ceil(nanmean([last1 first4]))-1,1) = true;
        idxy(ceil(nanmean([last1 first4])):end,4) = true;
%         B(1) = LastAlignToB(A(iZ,:,1),A(iZ,:,2),xZ,yZ);
%         idxy(1:B(1),1)=true;
        % segment 1, from 0 to 1:
        P1 = startSkip(iZ,1)+projectionNormalized([xZ(idxy(:,1))-A(iZ,1,1) yZ(idxy(:,1))-A(iZ,2,1)],v(iZ,:,1),u(iZ,:,1));
        D1 = calcDist(A(iZ,:,1),A(iZ,:,2),xZ(idxy(:,1)),yZ(idxy(:,1)));
        T1 = tZ(idxy(:,1));
%         idxy(B(1)+1:end,2) = true;
        % segment 2, from 1 to 2
        P2 = startSkip(iZ,2)+projectionNormalized([xZ(idxy(:,4))-A(iZ,1,2) yZ(idxy(:,4))-A(iZ,2,2)],v(iZ,:,4),u(iZ,:,4));
        D2 = calcDist(A(iZ,:,2),A(iZ,:,4),xZ(idxy(:,4)),yZ(idxy(:,4)));
        T2 = tZ(idxy(:,4));
    end
    
    
    % Assemble.
    id1 = T.data(T1);
    id2 = T.data(T2);
    id3 = T.data(T3);
    id4 = T.data(T4);
    
    L(id1,1) = P1;
    L(id2,1) = P2;
    L(id3,1) = P3;
    L(id4,1) = P4;
    
    L(id1,2) = 1;
    L(id2,2) = 2;
    L(id3,2) = 3;
    L(id4,2) = 4;
    
    L(id1,3) = iZ;
    L(id2,3) = iZ;
    L(id3,3) = iZ;
    L(id4,3) = iZ;
    
    L(id1,4) = D1;
    L(id2,4) = D2;
    L(id3,4) = D3;
    L(id4,4) = D4;
end

lin = tsd(x.range,L(:,1));

seg = tsd(x.range,L(:,2));
zon = tsd(x.range,L(:,3));
dist2vec = tsd(x.range,L(:,4));

function P = projectionNormalized(A,B,U)
% project A onto B, normalized by norm of U.
Bn = norm(B);
N = B/Bn;
A = A/Bn;
normFact = norm(U);
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

function d = calcDist(A,B,Zx,Zy)
V = B-A;
N = norm(V);
theta = atan2(V(2),V(1));
rotMat = [cos(-theta) -sin(-theta); sin(-theta) cos(-theta)];
x0 = Zx-A(1);
y0 = Zy-A(2);
xyR = (rotMat*[x0';y0'])';
idLo = xyR(:,1)<0;
idHi = xyR(:,1)>N;
idMid = xyR(:,1)>=0&xyR(:,1)<=N;
d = nan(length(Zx),1);
d(idLo) = sqrt(xyR(idLo,1).^2+xyR(idLo,2).^2);
d(idHi) = sqrt((xyR(idHi,1)-N).^2+(xyR(idHi,2)).^2);
d(idMid) = sqrt(xyR(idMid,2).^2);

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