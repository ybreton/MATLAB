function [theta,radius,maxCurvature] = RRGetMaxCurvVelDirection(sd,varargin)
% Returns the angle and radius of the velocity vector that arises at the
% point in a window around entering the zone where the curvature is
% maximal.
%
%
%
window = [0 1];
plotFlag = false;
process_varargin(varargin);

% get curvature
C = RRCurvature(sd);
% enter/exit times
EnterZoneTime = sd.EnteringZoneTime+window(1);
ExitZoneTime = sd.EnteringZoneTime+window(2);

% next zone times
nextZone = [sd.EnteringZoneTime(2:end) sd.ExpKeys.TimeOffTrack]-sd.x.dt;

% stop time is first of exit time and next zone time
nL = length(EnterZoneTime);
ExitZoneTime = min(ExitZoneTime(1:nL),nextZone(1:nL));

% align to entry into every zone
sd = RRalignedXY(sd);
xEntry = [];
yEntry = [];

% rotated position upon entry into each zone
xRot = [];
yRot = [];
tRot = [];
for iLap=1:length(sd.EnteringZoneTime)
    zoneIn = sd.ZoneIn(iLap);
    t0 = range(sd.xAlign{zoneIn}.restrict(sd.EnteringZoneTime(iLap),nextZone(iLap)));
    xEntry = sd.xAlign{zoneIn}.data(sd.EnteringZoneTime(iLap));
    yEntry = sd.yAlign{zoneIn}.data(sd.EnteringZoneTime(iLap));
    xRot = [xRot; sd.xAlign{zoneIn}.data(t0)-xEntry];
    yRot = [yRot; sd.yAlign{zoneIn}.data(t0)-yEntry];
    tRot = [tRot; t0];
end

sd.xRot = tsd(tRot,xRot);
sd.yRot = tsd(tRot,yRot);

sd = RRPosDerivatives(sd);

x = sd.xRot;
y = sd.yRot;

maxCurvature = nan(1,length(sd.ZoneIn));
theta = nan(1,length(sd.ZoneIn));
radius = nan(1,length(sd.ZoneIn));
for iLap=1:length(sd.ZoneIn)
    in = EnterZoneTime(iLap);
    out = ExitZoneTime(iLap);
    zoneIn = sd.ZoneIn(iLap);
    
    xEntry = sd.xAlign{zoneIn}.data(sd.EnteringZoneTime(iLap));
    yEntry = sd.yAlign{zoneIn}.data(sd.EnteringZoneTime(iLap));
    
    x0 = data(sd.xAlign{zoneIn}.restrict(in,out))-xEntry;
    y0 = data(sd.yAlign{zoneIn}.restrict(in,out))-yEntry;
    t  = range(sd.yAlign{zoneIn}.restrict(in,out));
    if sum(~isnan(x0))>1
        xNaN = interp1(t(~isnan(x0)),x0(~isnan(x0)),t(isnan(x0)));
        yNaN = interp1(t(~isnan(y0)),y0(~isnan(y0)),t(isnan(y0)));
        xInterp = x0;
        yInterp = y0;
        xInterp(isnan(x0)) = xNaN;
        yInterp(isnan(y0)) = yNaN;
    else
        xInterp=x0;
        yInterp=x0;
    end
    
    
    if length(x0(~isnan(x0)&~isnan(y0)))>2
        dx0 = dxdt(tsd(t,xInterp));
        dy0 = dxdt(tsd(t,yInterp));
        C = Curvature(tsd(t,xInterp),tsd(t,yInterp));

        c = C.data(t);
        dx0 = dx0.data(t);
        dy0 = dy0.data(t);
    else
        dx0 = nan;
        dy0 = nan;
        c = nan;
    end
    
    if ~isempty(c)
        [maxCurvature(iLap),idMax]=max(c);
        xPoint = dx0(idMax);
        yPoint = dy0(idMax);
    else
        xPoint = nan;
        yPoint = nan;
    end
    if xPoint==0 && yPoint==0
        xPoint = nan;
        yPoint = nan;
    end
    
    if plotFlag
        clf
        plot(x.data,y.data,'.','color',[0.8 0.8 0.8])
        hold on
        plot(x0,y0,'k-')
        if ~isempty(xNaN)&~isempty(yNaN)
            plot(xNaN,yNaN,'.b')
        end
        plot(0,0,'gs','markerfacecolor','g')
        if ~isnan(xPoint)&~isnan(yPoint)
            plot(xInterp(idMax),yInterp(idMax),'ro','markerfacecolor','r');
            quiver(xInterp(idMax),yInterp(idMax),xPoint,yPoint);
        end
        axis image
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        set(gca,'xcolor','w')
        set(gca,'ycolor','w')
        hold off
        title(sd.ExpKeys.SSN)
        drawnow
    end
    
    theta(iLap) = atan2(yPoint,xPoint);
    radius(iLap) = sqrt(xPoint.^2+yPoint.^2);
end