function [FE,FR] = RRfiringRateEntryReward(sd,S,varargin)
% Calculates the firing rate at entry, reward
% - nSpikes from entry+Estart to first of entry+Etime and reward+Rstart
%          /
%           first of entry+Etime and reward+Rstart - entry+Estart
% - nSpikes from reward+Rstart to first of reward+Rtime and next entry+Estart
%          /
%           first of reward+Rtime and next entry+Estart - reward+Rstart
Estart = 1;
Etime = 5;
Rstart = 1;
Rtime = 5;
process_varargin(varargin);

ExitZoneTime = nan(length(sd.ZoneIn),1);
ExitZoneTime(1:length(sd.ExitZoneTime)) = sd.ExitZoneTime;
NextZoneTime = nan(length(sd.ZoneIn),1);
NextZoneTime(1:length(sd.NextZoneTime)) = sd.NextZoneTime;
EnteringZoneTime = nan(length(sd.ZoneIn),1);
EnteringZoneTime(1:length(sd.EnteringZoneTime)) = sd.EnteringZoneTime;
stayGo = nan(length(sd.ZoneIn),1);
stayGo(1:length(sd.ExitZoneTime)) = ismember(sd.ExitZoneTime,sd.FeederTimes);

FE = nan(length(sd.ZoneIn),1);
FR = nan(length(sd.ZoneIn),1);
for iT=1:length(sd.ZoneIn)
    t1 = EnteringZoneTime(iT)+Estart;
    t2 = EnteringZoneTime(iT)+Etime;
    t3 = ExitZoneTime(iT)+Rstart;
    t4 = ExitZoneTime(iT)+Rtime;
    t5 = NextZoneTime(iT)+Estart;

    % t2 is the first of t2 and t3.
    t2 = min(t2,t3);

    % t4 is the first of t4 and t5.
    t4 = min(t4,t5);

    E = length(data(S.restrict(t1,t2)));
    FE(iT) = E/(t2-t1);
    if stayGo(iT)==1
        R = length(data(S.restrict(t3,t4)));
        FR(iT) = R/(t4-t3);
    end
end