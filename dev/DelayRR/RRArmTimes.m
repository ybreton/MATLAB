function sd = RRArmTimes(sd,varargin)
% 30cm radius from feeder
%
%
%
radiuscm = 30;
debug = false;
process_varargin(varargin);

cm2px = 1./(RRpx2cm(sd,1));
radiuspx = radiuscm*cm2px;

x = sd.x.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);
y = sd.y.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);
t = x.range;
x = x.data;
y = y.data;
idnan = isnan(x)&isnan(y);
t = t(~idnan);
x = x(~idnan);
y = y(~idnan);

Zx = sd.World.FeederLocations.x(:)';
Zy = sd.World.FeederLocations.y(:)';
d = nan(length(x),length(Zx));
for iZ=1:length(Zx)
    d(:,iZ) = sqrt((x-Zx(iZ)).^2+(y-Zy(iZ)).^2);
end

tin = [];
tout = [];
S = [1 0 0 0];
lastZone = nan;
nextZone = [2:length(Zx) 1];
for iT=1:length(t)
    t0 = t(iT);
    x0 = x(iT);
    y0 = y(iT);
    d0 = d(iT,:);
    if debug
        plot(x,y,'k.')
        hold on
        plot(x0,y0,'ro','markerfacecolor','r')
        for iZ=1:4
            plot(Zx(iZ)+cos(linspace(0,2*pi))*radiuspx,Zy(iZ)+sin(linspace(0,2*pi))*radiuspx,'g-')
        end
        hold off
        drawnow
    end
    if any(d0<=radiuspx)
        zoneIn = find(d0<=radiuspx);
    else
        zoneIn = nan;
    end
    
    if ~isnan(lastZone)
        if zoneIn~=lastZone
            if S(lastZone)==2 % if the last zone was active,
                tout = [tout t0]; % set exit from choice point
                S(lastZone) = 0; % deactivate last zone
            end
        end
    end
    
    if ~isnan(zoneIn)
        if S(zoneIn)==1 % if zone is primed,
            S = [0 0 0 0];
            S(zoneIn)=2;% activate it
            S(nextZone(zoneIn))=1; % prime the next one
            tin = [tin t0]; % set entry into choice point
        end
    end
    
    lastZone=zoneIn;
end
sd.ArmIn = tin;
sd.ArmOut = tout;