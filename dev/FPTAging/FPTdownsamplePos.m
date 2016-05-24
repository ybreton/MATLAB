function sd = FPTdownsamplePos(sd,varargin)
% 
%
%
%

FR = 1/30;
debug = false;
process_varargin(varargin);

x = sd.x;
y = sd.y;
StartT = min(x.range);
FinishT = max(x.range);

T = (StartT:FR:FinishT)';
x0 = interp1(x.range,x.data,T);
y0 = interp1(y.range,y.data,T);
T = (StartT:FR:FinishT)';

sd.x = tsd(T,x0);
sd.y = tsd(T,y0);

x = sd.x.data;
y = sd.y.data;
t = sd.x.range;
idnan = isnan(t);
x(idnan) = [];
y(idnan) = [];
t(idnan) = [];
idnan = isnan(x)|isnan(y);
x(idnan) = interp1(t(~idnan),x(~idnan),t(idnan));
y(idnan) = interp1(t(~idnan),y(~idnan),t(idnan));
x = tsd(t,x);
y = tsd(t,y);
xEntry = nan(length(sd.EnteringCPTime),1);
yEntry = nan(length(sd.EnteringCPTime),1);
for l = 1 : length(sd.EnteringCPTime)
    x0 = x.restrict(sd.EnteringCPTime(l)-x.dt,sd.EnteringCPTime(l)+x.dt);
    y0 = y.restrict(sd.EnteringCPTime(l)-y.dt,sd.EnteringCPTime(l)+y.dt);
    xEntry(l) = nanmean(x0.data);
    yEntry(l) = nanmean(y0.data);
end

CP(1) = nanmean(xEntry);
if CP(1)>720/2
    CP(1) = CP(1)+sd.InZoneDistance(2);
else
    CP(1) = CP(1)-sd.InZoneDistance(2);
end
CP(2) = nanmean(yEntry);

% id = sd.FeederTimes<min(sd.EnteringCPTime);
% FeederTimes = sd.FeederTimes(~id);
if min(sd.EnteringCPTime)>min(sd.ExitingCPTime)
    % first entry into CP not recorded.
    sd.EnteringCPTime = [min(x.range) sd.EnteringCPTime];
end
if max(sd.ExitingCPTime)<max(sd.EnteringCPTime)
    % first entry into CP not recorded.
    sd.ExitingCPTime = [sd.ExitingCPTime max(x.range)];
end


EnteringCPTime = sd.EnteringCPTime;
FeederTimes = sd.FeederTimes;
% nL = min(length(EnteringCPTime),length(sd.ZoneIn));
% sd.TotalLaps = nL;



tstart = EnteringCPTime-mean([sd.x.dt sd.y.dt]);
tstart = tstart(:);
tend = ones(length(tstart),1)*max(sd.x.range);
for t = 1 : length(tstart)
    minRid = find(FeederTimes>tstart(t),1,'first');
    if ~isempty(minRid)
        tend(t) = FeederTimes(minRid);
    else
        tend(t) = max(sd.x.range);
    end
end

upperY = CP(2)+sd.InZoneDistance(2);
lowerY = CP(2)-sd.InZoneDistance(2);
leftX = CP(1)-sd.InZoneDistance(2);
rightX = CP(1)+sd.InZoneDistance(2);
for l = 1 : length(tstart)
    y0 = sd.y.restrict(tstart(l),tend(l));
    x0 = sd.x.restrict(tstart(l),tend(l));
    yT = y0.range;
    yD = y0.data;
    xD = x0.data;
    dt = y0.dt;
    rids = 1:length(yT);

    idnan = isnan(yD)|isnan(xD);
    n = length(unique(round(xD(~idnan))));
    if n>10
        xD(idnan) = interp1(yT(~idnan),xD(~idnan),yT(idnan));
        yD(idnan) = interp1(yT(~idnan),yD(~idnan),yT(idnan));
%             rInZone = sqrt((xD-CP(1)).^2+(yD-CP(2)).^2)<=sd.InZoneDistance(2);
        yInZone = yD>=lowerY&yD<=upperY;
        FirstxInZone = find(xD<=rightX&xD>=leftX&yD<=upperY&yD>=lowerY,1,'first');
        
        if ~isempty(FirstxInZone)
            tstart(l) = yT(FirstxInZone)-dt;
        else
            tstart(l) = nan;
        end
        
        if any(yInZone)
            rOutZone = rids(~(yInZone));
            rOutZone(rOutZone<min(rids(yInZone))) = [];
        else
            rOutZone = [];
            tstart(l) = nan;
            tend(l) = nan;
        end
    else
        rOutZone = [];
        tstart(l) = nan;
        tend(l) = nan;
    end

    if ~isempty(rOutZone)&~isnan(tend(l))&~isnan(tstart(l))
        lastTime = min(rOutZone); % first time y leaves zone.
        tend(l) = yT(lastTime);
    elseif isempty(rOutZone)&~isnan(tend(l))&~isnan(tstart(l))
        lastTime = max(rids(yInZone));
        tend(l) = yT(lastTime);
    end
    if debug
        clf
        x1 = x.restrict(tstart(l),tend(l));
        y1 = y.restrict(tstart(l),tend(l));
        hold on
        plot(x0.data,y0.data,'-','color',[0.8 0.8 0.8],'linewidth',1)
        plot(x1.data,y1.data,'b-','linewidth',2)
        hold off
        set(gca,'xlim',[0 720])
        set(gca,'ylim',[0 480])
        drawnow
    end
end

sd.EnteringCPTime_fix = tstart;
sd.ExitingCPTime_fix = tend;