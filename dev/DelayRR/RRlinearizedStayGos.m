function L = RRlinearizedStayGos(sd,stayGo,varargin)
% Produces a tsd of the linearized position for stays (stayGo==1) or skips
% (stayGo==0) exclusively.
%
% L = RRlinearizedStayGos(sd,stayGo)
% where     L       is a tsd of linearized position for only stays or skips
%
%           sd      is a standard session data structure with linearized
%                       position in sd.linearized
%           stayGo  is a logical specifying whether to extract linearized
%                       position for stays (1) or skips (0).
%
% OPTIONAL ARGUMENTS:
% ******************
% linPos    (default sd.linearized)
%               tsd of linearized position.
% included  (default ts(sd.linearized.range))
%               ts of times to include in linearized position. Useful if
%               excluding times when distance to ideal path is greater than
%               a threshold.
%

if isfield(sd,'linearized');
    linPos = sd.linearized;
else
    linPos = nan;
end
process_varargin(varargin);
assert(isa(linPos,'tsd'),'Linearized position must be a tsd in field sd.linearized or specified as optional input argument linPos.')
included = ts(linPos.range);
process_varargin(varargin);

assert((stayGo==1)|(stayGo==0),'stayGo must be 0 or 1.');

sd.stayGo = ismember(sd.ExitZoneTime,sd.FeederTimes);

idx = find(sd.stayGo==stayGo);

times = range(linPos.restrict(sd.EnteringZoneTime(idx),sd.NextZoneTime(idx)-sd.x.dt));
t = times(ismember(times,included.data));
t = t(~isnan(t));

L = tsd(t,linPos.data(t));