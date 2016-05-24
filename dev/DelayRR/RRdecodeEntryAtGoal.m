function Decoding = RRdecodeEntryAtGoal(sd,S,varargin)
% Produces a structure with fields
%     Decoding.Current, current zone
%     Decoding.Next, next zone
%     Decoding.Previous, previous zone
%     Decoding.Opposite, opposite-side zone
%     Decoding.OutZone, non-specific activity
%     Decoding.nCells, number of cells contributing
Etime = [0 3];
Rtime = [0 3];
Ttime = [-2 5];
dt = 0.125;
PrevZone = [4 1 2 3];
NextZoneTime = [2 3 4 1];
OppZone = [3 4 1 2];
process_varargin(varargin);

nTS = (Ttime(2)-Ttime(1))/dt+1;
nTrls = length(sd.ZoneIn);

disp('Training on [EnteringZoneTime, EnteringZoneTime+Etime], excluding any exit times')
% Training set for decoding is activity in 3s following entry time
sd = sdZoneInTsd(sd);

nTrls = length(sd.ZoneIn);
InTime = nan(nTrls,1);
OutTime = nan(nTrls,1);

InTime(1:length(sd.EnteringZoneTime)) = sd.EnteringZoneTime;
OutTime(1:length(sd.ExitZoneTime)) = sd.ExitZoneTime;
OutTime = nanmin(OutTime,sd.ExpKeys.TimeOffTrack);
NextTime = [InTime(2:end) sd.ExpKeys.TimeOffTrack];

tInStart = nan(nTrls,1);
tInStop = nan(nTrls,2);
tOutStart = nan(nTrls,3);
tOutStop = nan(nTrls,4);
for iZ=1:length(sd.ZoneIn)
    tInStart(iZ) = InTime(iZ)+Etime(1);
    tInStop(iZ) = InTime(iZ)+Etime(2);
    if sd.stayGo==1
        tOutStart(iZ) = OutTime(iZ)+Rtime(2);
    else
        tOutStart(iZ) = OutTime(iZ);
    end
    tOutStop(iZ) = NextTime(iZ)+Etime(1);
end
t = sortrows([tInStart(:) tInStop(:); tOutStart(:) tOutStop(:)]);
t1 = t(:,1);
t2 = t(:,2);

training = sd.zonetsd.restrict(t1,t2);
D = {{training, 1, 5, 5}};
TC = TuningCurves(S,D);

disp('Making Q sparse marix...')
% Intermediate steps.
Q = MakeQfromS(S,dt);

% Decoding.
disp('Decoding...')
R = BayesianDecoding(Q,TC);

Decoding.Current = nan(nTrls,nTS);
Decoding.Next = nan(nTrls,nTS);
Decoding.Previous = nan(nTrls,nTS);
Decoding.Opposite = nan(nTrls,nTS);
Decoding.OutZone = nan(nTrls,nTS);
Decoding.nCells = nan(nTrls,nTS);
% For each zone entry,
for iTrial=1:length(sd.ZoneIn);
    fprintf('.')
    if mod(iTrial,100)==0
        fprintf('\n')
    end
    CurZone = sd.ZoneIn(iTrial);
    % When he entered
    In = sd.EnteringZoneTime(iTrial);
    % When he left
    if iTrial>length(sd.ExitZoneTime)
        Out = sd.ExpKeys.TimeOffTrack;
    else
        Out = sd.ExitZoneTime(iTrial);
    end
    Out = min(In+Ttime(2),Out);
    t = (In+Ttime(1):dt:Out)';

    pxs = R.pxs.data(t);
    
    % Current, Next, Previous, Opposite, and OutZone is the decoded probability,
    % T is the timestamp,
    %
    % Value is the offer value (threshold-delay),
    % Delay is the offer delay,
    % Threshold is the zone threshold,
    % Rat is the rat's name,
    % Condition is the condition name,
    % Session is the chronological session pair number

    C = pxs(:,CurZone);
    N = pxs(:,NextZoneTime(CurZone));
    P = pxs(:,PrevZone(CurZone));
    O = pxs(:,OppZone(CurZone));
    NS = pxs(:,5);
    nCells = repmat(size(Q.data,2),[1,size(t,1)]);

    Decoding.Current(iTrial,1:size(t,1)) = C;
    Decoding.Next(iTrial,1:size(t,1)) = N;
    Decoding.Previous(iTrial,1:size(t,1)) = P;
    Decoding.Opposite(iTrial,1:size(t,1)) = O;
    Decoding.OutZone(iTrial,1:size(t,1)) = NS;
    Decoding.nCells(iTrial,1:size(t,1)) = nCells;
end
fprintf('\n');