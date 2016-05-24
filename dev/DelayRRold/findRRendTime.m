function [tEnd,idleSec] = findRRendTime(nvt,startTime,varargin)
% Finds restaurant row session end times from the videotracking data.
% tEnd = findRRendTime(nvt,startTime)
% where     tEnd        is the timestamp with the last real (x,y) location
%                           before the rat is determined to be off-track.
% 
%           nvt         is a string with the NVT file to check,
%           startTime   is the session start time to begin checking from.
%
% OPTIONAL ARGUMENTS:
% ******************
% nSec      (default 30s)       checks for nSec seconds of non-recording ACQ data to
%                                   determine when the rat is off-track.
% stopTime  (default max time)  restricts search from startTime to stopTime
% plotFlag  (default false)     plots xy position against time along with
%                                   start and end times.

[xx,yy] = LoadVT_lumrg(nvt);

nSec = 30;
stopTime = max(max(xx.range),max(yy.range));
plotFlag = false;
process_varargin(varargin);

x = xx.restrict(startTime,stopTime);
y = yy.restrict(startTime,stopTime);

idle = isnan(x.data)|isnan(y.data);
t = x.range;
x = x.restrict(min(t(~idle)),stopTime);
y = y.restrict(min(t(~idle)),stopTime);

t = x.range;
nNaNs = ceil(nSec/x.dt);

tdat = x.range;
tdiff = [nan; diff(tdat(:))];
% xdat = x.data;
% ydat = y.data;
% indat = isnan(xdat(:))|isnan(ydat(:));
% dat = nan(length(indat),nNaNs);
% dat(:,1) = indat;
% for displ = 2 : nNaNs
%     fut = indat(displ:end);
%     dat(1:end-displ+1,displ) = fut;
% end
tStamp = 1:size(tdiff,1);
% nanCount = sum(dat,2);
% idnan = all(dat,2);
% idnan1 = dat(:,1)==1;
idle = tdiff>=nSec;
[idleSec,idTs]=max(tdiff);
if all(~idle)
    firstIdle = idTs;
else
    firstIdle = find(idle,1,'first');
    idleSec = nSec;
end
tEnd = t(firstIdle-1);

x = x.restrict(startTime,tEnd);
y = y.restrict(startTime,tEnd);
t = x.range;
lastNot = find(~isnan(x.data),1,'last');
tEnd = t(lastNot);

if plotFlag
    x0 = xx.data-nanmean(x.data);
    y0 = yy.data-nanmean(y.data);
    theta = atan2(y0,x0);
    clf
    ph=plot(xx.range,theta);
    hold on
    ph(2)=plot(startTime, nanmean(theta),'gs');
    ph(3)=plot(tEnd, nanmean(theta), 'ro');
    xlabel('Time');
    ylabel('Maze Position (Rads)')
    legend(ph,{'Tracking' 'startTime' 'TimeOffTrack'});
    hold off
    set(gca,'ylim',[-pi pi])
    set(gca,'xlim',[min(xx.range) max(yy.range)])
    drawnow
end