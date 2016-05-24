function sd = RRPosDerivatives(sd,varargin)
% Assembles velocity/acceleration vector tsds and speed/acceleration scalar tsds.
% sd = RRPosDerivatives(sd,varargin)
% where     sd      is a standard session data structure
%
% adds fields
%
%           sd.dx             x-velocity
%           sd.dy             y-velocity
%           sd.ddx            x-acceleration
%           sd.ddy            y-acceleration
%           sd.absSpeed       absolute speed (sqrt(dx^2+dy^2))
%           sd.absAccel       absolute acceleration (sqrt(ddx^2+ddy^2))
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

dx = cell(length(theta),1);
dy = cell(length(theta),1);
dxy = cell(length(theta),1);
ddx = cell(length(theta),1);
ddy = cell(length(theta),1);
ddxy = cell(length(theta),1);
for iZ=1:length(theta)
    xyZ = xy*squeeze(rotation(:,:,iZ));
    x0 = tsd(t,xyZ(:,1));
    y0 = tsd(t,xyZ(:,2));
    
    dx{iZ} = dxdt(x0);
    dy{iZ} = dxdt(y0);
    dxy{iZ} = tsd(dx{iZ}.range,sqrt(dx{iZ}.data.^2+dy{iZ}.data.^2));
    ddx{iZ} = dxdt(dx{iZ});
    ddy{iZ} = dxdt(dy{iZ});
    ddxy{iZ} = tsd(ddx{iZ}.range,sqrt(ddx{iZ}.data.^2+ddy{iZ}.data.^2));
end

t = [];
dx0 = [];
dy0 = [];
ddx0 = [];
ddy0 = [];
spd = [];
accel = [];
for iLap=1:length(EnteringZoneTime)
    ZoneIn = sd.ZoneIn(iLap);
    t0 = range(x.restrict(EnteringZoneTime(iLap),ExitZoneTime(iLap)));
    t = [t; t0];
    dx0 = [dx0; dx{ZoneIn}.data(t0)];
    dy0 = [dy0; dy{ZoneIn}.data(t0)];
    ddx0 = [ddx0; ddx{ZoneIn}.data(t0)];
    ddy0 = [ddy0; ddy{ZoneIn}.data(t0)];
    spd = [spd; dxy{ZoneIn}.data(t0)];
    accel = [accel; ddxy{ZoneIn}.data(t0)];
end

sd.dx = tsd(t,dx0);
sd.dy = tsd(t,dy0);
sd.ddx = tsd(t,ddx0);
sd.ddy = tsd(t,ddy0);
sd.absSpeed = tsd(t,spd);
sd.absAccel = tsd(t,accel);