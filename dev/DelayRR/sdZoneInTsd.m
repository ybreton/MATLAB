function sd = sdZoneInTsd(sd,varargin)
% Wrapper to return sd with field containing a tsd of the active zone the
% rat is in: sd.zonetsd
%
%

Rtime = [0 3];
NoneZone = 5;
process_varargin(varargin);

ZI = sd.ZoneIn;
SG = sd.stayGo;
nTrls = length(ZI);

In = nan(length(ZI),1);
Out = nan(length(ZI),1);
Next = nan(length(ZI),1);

In(1:length(sd.EnteringZoneTime)) = sd.EnteringZoneTime;
Out(1:length(sd.ExitZoneTime)) = sd.ExitZoneTime;
Next(1:length(sd.NextZoneTime)) = sd.NextZoneTime;
In = max(sd.ExpKeys.TimeOnTrack,In);
Out = min(Out,sd.ExpKeys.TimeOffTrack);
Next = min(Next,sd.ExpKeys.TimeOffTrack);

t = sd.x.range;
n = length(t);
d = nan(n,1);

fprintf('\n')
for iZ=1:length(ZI)
    fprintf('.')
    StartEntering = In(iZ);
    StopEntering = Out(iZ)+Rtime(1);
    StartLeaving = Out(iZ)+Rtime(1);
    StopLeaving = Out(iZ)+Rtime(2);
    StartITI = Out(iZ)+Rtime(2);
    StopITI = Next(iZ);
    
    % Stop Leaving by the time you have done Start ITI
    StopLeaving = min(StopLeaving,StartITI);
    
    idIn = t>=StartEntering & t<StopEntering;
    idOut = t>=StartLeaving & t<StopLeaving;
    idOff = t>=StartITI & t<StopITI;
    
    % When entering zone, zone in
    d(idIn) = ZI(iZ);
    if SG(iZ)==1
        % When reward is delivered, zone in
        d(idOut) = ZI(iZ);
    elseif SG(iZ)==0
        % When skipping, none zone
        d(idOut) = NoneZone;
    end
    % After leaving reward/zone, none zone
    d(idOff) = NoneZone;
end
fprintf('\n')

sd.zonetsd = tsd(t,d);