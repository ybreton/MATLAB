function C = RRCurvature(sd,varargin)
% Assembles curvature for restaurant row.
% C = RRCurvature(sd,varargin)
% where     C       is a tsd of the curvature
%
%           sd      is a standard session data structure
%
% OPTIONAL ARGUMENTS:
% ******************
% EnteringZoneTime  (default sd.EnteringZoneTime)
%                       Time zone was entered on each trial
% ExitZoneTime      (default [sd.EnteringZoneTime(2:end) sd.ExpKeys.TimeOffTrack]-sd.x.dt)
%                       Time zone was exited on each trial
% x,y               (default is x,y recentered on maze center)
%                       Maze coordinates
% theta             (default is [-pi/2 0 pi/2 -pi])
%                       Radians to rotate each zone
%
%
%

EnteringZoneTime = sd.EnteringZoneTime;
ExitZoneTime = [sd.EnteringZoneTime(2:end) sd.ExpKeys.TimeOffTrack]-sd.x.dt;

[x,y]=RRcentreMaze(sd);
theta(1) = -pi/2;
theta(2) = 0;
theta(3) = pi/2;
theta(4) = -pi;

process_varargin(varargin);

rotation = nan(2,2,length(theta));
for iZ=1:length(theta)
    rotation(:,:,iZ) = [cos(theta(iZ)) -sin(theta(iZ));
                        sin(theta(iZ))  cos(theta(iZ))];
end

xy = [x.data y.data];
t = x.range;

Crot = cell(length(theta),1);
for iZ=1:length(theta)
    xyZ = xy*squeeze(rotation(:,:,iZ));
    x0 = tsd(t,xyZ(:,1));
    y0 = tsd(t,xyZ(:,2));
    
    Crot{iZ} = Curvature(x0,y0);
end

t = [];
c = [];
for iLap=1:length(EnteringZoneTime)
    ZoneIn = sd.ZoneIn(iLap);
    t = [t; range(Crot{ZoneIn}.restrict(EnteringZoneTime(iLap),ExitZoneTime(iLap)))];
    c = [c; data(Crot{ZoneIn}.restrict(EnteringZoneTime(iLap),ExitZoneTime(iLap)))];
end

C = tsd(t,c);
