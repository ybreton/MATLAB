function [tEnd,tStart] = findRRendTime(vt,varargin)
% Finds restaurant row session end times from the videotracking data.
% tEnd = findRRendTime(nvt,startTime)
% where     tEnd        is the timestamp 1 dt after the last real (x,y) location
%                           before the rat is determined to be off-track.
% 
%           vt          is a string with the -VT.mat file to check,
%
% [tEnd,tStart] = findRRendTime(vt,varargin)
% where     tStart      is the first time stamp 1 dt before the first real
%                           (x,y) location before the rat is determined to
%                           be on-track.
%
% OPTIONAL ARGUMENTS:
% ******************
% nSec      (default 25s)       checks for nSec seconds of non-recording ACQ data to
%                                   determine when the rat is off-track.
% startTime (default min time)  session start time to begin checking from.
% stopTime  (default max time)  restricts search from startTime to stopTime
% plotFlag  (default false)     plots xy position against time along with
%                                   start and end times.

tracking = load(vt);
xx = tracking.x;
yy = tracking.y;

nSec = 25;
startTime = min(min(xx.range),min(yy.range));
stopTime = max(max(xx.range),max(yy.range));
plotFlag = true;
process_varargin(varargin);

x = xx.restrict(startTime,stopTime);
y = yy.restrict(startTime,stopTime);

t = x.range;

dt = diff([t;max(t)+x.dt]);
idBig = find(dt>nSec);

if isempty(idBig)
    [maxDiff,idBig] = max(dt);
    disp(['Largest recording gap: ' num2str(maxDiff) 's.'])
    pause;
end
tEnd = t(idBig(end))+x.dt;

if nargout>1
    tStart = t(idBig(1))-x.dt;
else
    tStart = startTime;
end

if plotFlag
    clf
    plot(x.range,x.data,'b-','linewidth',1)
    hold on
    plot(tStart,nanmean(x.data),'go','markerfacecolor','g','markersize',12)
    plot(tEnd,nanmean(x.data),'rs','markerfacecolor','r','markersize',12);
    hold off
    set(gca,'xlim',[min(xx.range) max(xx.range)])
    drawnow
end