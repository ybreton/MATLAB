function [VEHzd,VEHtiz] = wrap_RR_summarizeStayDurations(VEH,varargin)
% Wrapper produces nSessions x nTrials matrix of delays (VEHzd) and stay
% durations (VEHtiz).
% [VEHzd,VEHtiz] = wrap_RR_summarizeStayDurations(VEH)
% where     VEHzd       is nSessions x nTrials matrix of zone delays
%           VEHtiz      is nSessions x nTrials matrix of stay durations
%
%           VEH         is nSessions x 1 structure array with field sd
%                           containing standard session data
%

maxZones = 4;
maxLaps = 200;
process_varargin(varargin);

VEHzd = nan(length(VEH),maxZones*maxLaps);
VEHtiz = nan(length(VEH),maxZones*maxLaps);
for iSess = 1 : length(VEH)
    sd = VEH(iSess).sd;
    if length(sd)==1 && length(sd.maxTimeToRun)==1
        ZoneDelay = sd(1).ZoneDelay(1:end);
        ExitZoneTime = sd(1).ExitZoneTime(1:end);
        EnterZoneTime = sd(1).EnteringZoneTime(1:end);
        if length(ExitZoneTime) < length(EnterZoneTime)
            ZoneDelay = ZoneDelay(1:(end-1));
            EnterZoneTime = EnterZoneTime(1:(end-1));
        end            
        TimeInZone = ExitZoneTime - EnterZoneTime;
        VEHzd(iSess,1:length(ZoneDelay)) = ZoneDelay;
        VEHtiz(iSess,1:length(TimeInZone)) = TimeInZone;
    end
end