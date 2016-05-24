function Decoding = RRdecodeGoalAtEntry(sd,S,varargin)
% Produces a structure with fields
%     Decoding.Current, current goal
%     Decoding.Next, next goal
%     Decoding.Previous, previous goal
%     Decoding.Opposite, opposite-side goal
%     Decoding.OutZone, non-specific activity
%     Decoding.nCells, number of cells contributing
Rtime = [0 3];
Etime = [-2 5];
dt = 0.125;
PrevZone = [4 1 2 3];
NextZone = [2 3 4 1];
OppZone = [3 4 1 2];
process_varargin(varargin);
nTS = (Etime(2)-Etime(1))/dt+1;
nTrls = length(sd.ZoneIn);

disp('Training on [ExitZoneTime, ExitZoneTime+Rtime], excluding any entering zone times...')
% Training set for decoding is activity in 3s following exit
% time
In = nan(max(length(sd.EnteringZoneTime),length(sd.ExitZoneTime)),1);
Out = In;
In(1:length(sd.EnteringZoneTime)) = sd.EnteringZoneTime;
Out(1:length(sd.ExitZoneTime)) = sd.ExitZoneTime;
In = max(In,sd.ExpKeys.TimeOnTrack);
Out = min(Out,sd.ExpKeys.TimeOffTrack);
OutR = Out+Rtime(2);
overlap = find(In(2:end)<OutR(1:end-1));
OutR(overlap) = In(overlap+1);

sd = sdZoneInTsd(sd,'Rtime',Rtime);
training = sd.zonetsd.restrict(Out,OutR);
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
    Out = min(In+Etime(2),Out);
    t = (In+Etime(1):dt:Out)';

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
    N = pxs(:,NextZone(CurZone));
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