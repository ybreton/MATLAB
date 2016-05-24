function [path,zone] = RRextendedLinPath(sd,varargin)
% Returns a structure with fields "data" and "time" containing extended
% linearized position for each trial, starting at the same landmark in the
% previous zone and counting up to 0, the entry into the current zone.
%
% path = RRextendedLinPath(sd)
% where     path        is a structure array with fields
%               .data   nTrials x nPositions matrix of linearized position
%                           on each trial
%               .time   nTrials x nPositions matrix of time stamps for each
%                           linearized position
%
% [path,zone] = RRextendedLinPath(...)
% where     zone        is a structure array with fields
%               .data   nTrials x nPositions matrix of zone occupancy
%               .time   nTrials x nPositions matrix of time stamps for each
%                           zone
%
% OPTIONAL ARGUMENTS:
% ******************
% lastLinSkip   (default: sd.World.LinLandmarks.Skip.Arm)
%               1 x nZones
%               linearized position to begin last zone calculation when
%               last zone was a skip
% lastLinStay   (default: sd.World.LinLandmarks.Stay.OutArm)
%               1 x nZones
%               linearized position to begin last zone calculation when
%               last zone was a stay
% exitLinSkip   (default: sd.World.LinLandmarks.Skip.Exit)
%               1 x nZones
%               linearized position to end last zone calculation to make it
%               count from negative to 0 when last zone was a skip
% exitLinStay   (default: sd.World.LinLandmarks.Stay.Exit)
%               1 x nZones
%               linearized position to end last zone calculation to make it
%               count from negative to 0 when last zone was a stay
% recalculateLinPos (default: false)
%               force a re-calculation of linearized position.
%
% The following will be checked if sd does not contain both sd.linearized
% and sd.World.LinLandmarks, or if recalculateLinPos is true.
% normFact      (default: ones(4))
%               nZones x nSegments normalization factor for linearizing
%               vectors
%               (1) start to arm
%               (2) arm to feeder
%               (3) feeder to arm
%               (4) arm to exit
% startStay     (default: [0 1 2 3;0 1 2 3;0 1 2 3;0 1 2 3])
%               nZones x nSegments starting positions for segments'
%               linearized position on stays
% startSkip     (default: [0 1;0 1;0 1;0 1])
%               nZones x nSegments starting positions for segments'
%               linearized position on skips
%
%

normFact = ones(4);
startStay = repmat(0:3,4,1);
startSkip = repmat(0:1,4,1);
recalculateLinPos = false;
process_varargin(varargin);

if ~isfield(sd.World,'LinLandmarks')||~isfield(sd,'linearized')||recalculateLinPos;
    disp('Calculating linearized path...')
    for iZ=1:size(normFact,2)
        fprintf('\n                            S->A\tA->F\tF->A\tA->X')
        fprintf('\nNormalization factor Z%d   : %.2f\t%.2f\t%.2f\t%.2f',iZ,normFact(iZ,:))
        fprintf('\nSegment starts on Z%d stays: %.2f\t%.2f\t%.2f\t%.2f',iZ,startStay(iZ,:))
        fprintf('\nSegment starts on Z%d skips: %.2f\t\t\t%.2f',iZ,startSkip(iZ,:))
    end
    fprintf('\n')
    
    [linearized,LinLandmarks] = RRLinearizeIdealPath(sd,'normFact',normFact,'startStay', startStay, 'startSkip', startSkip);
else
    LinLandmarks = sd.World.LinLandmarks;
    linearized = sd.linearized;
end
lastLinSkip = LinLandmarks.Skip.Arm;
lastLinStay = LinLandmarks.Stay.OutArm;
exitLinSkip = LinLandmarks.Skip.Exit;
exitLinStay = LinLandmarks.Stay.Exit;
process_varargin(varargin);

lastZoneTime = nan(length(sd.EnteringZoneTime),1);
L = linearized.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);
D = L.data;
T = L.range;
dt = L.dt;

Zd = nan(length(T),1);
for iTrl=1:length(sd.EnteringZoneTime)
    id = T>=sd.EnteringZoneTime(iTrl)&T<sd.NextZoneTime(iTrl);
    Zd(id) = sd.ZoneIn(iTrl);
end
Z = tsd(T,Zd);

stayGo = ismember(sd.ExitZoneTime,sd.FeederTimes);
lastZoneTime(1) = sd.ExpKeys.TimeOnTrack;
tIn = sd.EnteringZoneTime;
tOut = sd.NextZoneTime;
for iTrl=2:length(sd.EnteringZoneTime)
    lastSG = stayGo(iTrl-1);
    zLast = sd.ZoneIn(iTrl-1);
    if lastSG==1
        iLast = find(D<lastLinStay(zLast)&T<tIn(iTrl),1,'last');
    else
        iLast = find(D<lastLinSkip(zLast)&T<tIn(iTrl),1,'last');
    end
    if ~isempty(iLast)
        lastZoneTime(iTrl) = T(iLast+1);
    else
        lastZoneTime(iTrl) = tIn(iTrl)-dt;
    end
end

nPrev = nan(length(sd.EnteringZoneTime),1);
nCur = nan(length(sd.EnteringZoneTime),1);
for iTrl=1:length(sd.EnteringZoneTime)
    nPrev(iTrl) = length(data(L.restrict(lastZoneTime(iTrl),tIn(iTrl)-dt)));
    nCur(iTrl) = length(data(L.restrict(tIn(iTrl),tOut(iTrl)-dt)));
end

path0 = nan(length(sd.EnteringZoneTime),max(nPrev+nCur));
times = nan(length(sd.EnteringZoneTime),max(nPrev+nCur));
zone0 = nan(length(sd.EnteringZoneTime),max(nPrev+nCur));

path0(1,1:nPrev(1)+nCur(1)) = [data(L.restrict(lastZoneTime(1),tIn(1)-dt)); data(L.restrict(tIn(1),tOut(1)-dt))];
times(1,1:nPrev(1)+nCur(1)) = [range(L.restrict(lastZoneTime(1),tIn(1)-dt)); range(L.restrict(tIn(1),tOut(1)-dt))];
zone0(1,1:nPrev(1)) = Z.data(lastZoneTime(1));
zone0(1,nPrev(1)+1:nPrev(1)+nCur(1)) = Z.data(tIn(1));

for iTrl=2:length(sd.EnteringZoneTime)
    tLast = lastZoneTime(iTrl);
    tIn = sd.EnteringZoneTime(iTrl);
    tOut = sd.NextZoneTime(iTrl);
    lastSG = stayGo(iTrl-1);
    zLast = sd.ZoneIn(iTrl-1);
    
    if lastSG==1
        path0(iTrl,1:nPrev(iTrl)) = data(L.restrict(tLast,tIn-dt))-exitLinStay(zLast);
    else
        path0(iTrl,1:nPrev(iTrl)) = data(L.restrict(tLast,tIn-dt))-exitLinSkip(zLast);
    end
    times(iTrl,1:nPrev(iTrl)) = range(L.restrict(tLast,tIn-dt));
    zone0(iTrl,1:nPrev(iTrl)) = Z.data(tLast);
    
    path0(iTrl,nPrev(iTrl)+1:nPrev(iTrl)+nCur(iTrl)) = data(L.restrict(tIn,tOut-dt));
    times(iTrl,nPrev(iTrl)+1:nPrev(iTrl)+nCur(iTrl)) = range(L.restrict(tIn,tOut-dt));
    zone0(iTrl,nPrev(iTrl)+1:nPrev(iTrl)+nCur(iTrl)) = Z.data(tIn);
end

path.data = path0;
path.time = times;

zone.data = zone0;
zone.time = times;