function Encode = RRowEncode(sd,events,window,nsStart,nsEnd,varargin)
% Returns a tsd where events within window are indicated, and non-specific
% activity w.
% Encode = RRowEncode(sd,events,window,nsStart,nsEnd)
% where     Encode      is a tsd of the entire session, with event data
%                           within a window around their times indicated
%                           and non-specific activity coded outside of
%                           event times and windows.
%           
%           sd          is a standard session data structure.
%           events      is a tsd of punctate events and timings.
%           window      is a 1x2 or a nEvents x 2 list of window offsets
%                           for encoding events.
%           nsStart     is a vector of non-specific activity start times.
%           nsEnd       is a vector of non-specific activity end times.
%
%   Non-specific activity is inserted first, and overwritten by specific
%   event-related activity if overlapping.
%
% OPTIONAL ARGUMENTS:
% ******************
% nonSpecificAct    (default max event+1)
%       how to encode non-specific activity outside of event windows.
%
% Example:
% Encode feeder fired within 3s window of feeder fire time, or non-specific
% activity from zone exit to next zone entry.
%
% Encode = RRowEncode(sd,tsd(sd.FeederTimes,sd.FeedersFired),[0 3],sd.ExitZoneTime,sd.NextZoneTime)

assert(isa(events,'tsd'),'Events must be a time-stamped data structure with the events to encode.')
assert(any(size(window)==2),'Window must have a dimension of size 2 for lower and upper limits of the event window.')
assert(length(nsStart)==length(nsEnd),'Non-specific activity times must have equal length.')

nonSpecificAct = max(events.data)+1;
process_varargin(varargin);
disp(['Non-specific activity coded as ' num2str(nonSpecificAct)]);

t = sd.x.range;
d = nan(length(sd.x.data),1);

sz=size(window);
if all(sz>1)
    dims = 1:length(sz);
    limitDim = find(sz==2,1,'first');
    eventDim = dims(dims~=limitDim);
    window = permute(window,[eventDim limitDim]);
else
    window = repmat(window(:)',[length(events.data) 1]);
end
window = sort(window,2);


eventData = events.data;
eventTime = events.range;

for iNS=1:length(nsStart)
    idx = t>nsStart(iNS) & t<nsEnd(iNS);
    d(idx) = nonSpecificAct;
end

for iEvent=1:length(eventData)
    idx = t>=eventTime(iEvent)+window(iEvent,1) & t<eventTime(iEvent)+window(iEvent,2);
    d(idx) = eventData(iEvent);
end

Encode = tsd(t,d);