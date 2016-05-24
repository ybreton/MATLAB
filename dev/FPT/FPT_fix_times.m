function sd = FPT_fix_times(sd,varargin)

debug=false;
SoM = [sd.Coord.SoM_x sd.Coord.SoM_y];
CP = [sd.Coord.CP_x sd.Coord.CP_y];
LF = [sd.Coord.LF_x sd.Coord.LF_y];
RF = [sd.Coord.RF_x sd.Coord.RF_y];
InZoneDistance = sd.InZoneDistance*1.5;
process_varargin(varargin);

zone(1,:) = SoM;
zone(2,:) = CP;
zone(3,:) = LF;
zone(4,:) = RF;
S = [1 1 0 0];
Z = 1:4;

EnteringSoMTime = [];
EnteringCPTime = [];
FeederTimes = [];
ExitingCPTime = [];
ExitingSoMTime = [];

time = sd.x.range;
x = sd.x.data;
y = sd.y.data;
lap = 0;
DelayFix = [];
ChoiceFix = [];
for t = 1 : length(x)
    x0 = x(t);
    y0 = y(t);
    if debug
        xDbg = sd.x.restrict(time(t)-1,time(t)+1);
        yDbg = sd.y.restrict(time(t)-1,time(t)+1);
        clf
        hold on
        circle(CP,InZoneDistance(2),100,'k-');
        circle(LF,InZoneDistance(3),100,'k-');
        circle(RF,InZoneDistance(4),100,'k-');
        circle(SoM,InZoneDistance(1),100,'k-');
        scatterplotc(xDbg.data,yDbg.data,xDbg.range,'solid_face',true)
        plot(x0,y0,'ro')
        set(gca,'xlim',[0 720])
        set(gca,'ylim',[0 480])
        hold off
        pause(0.01)
    end
%     if ~isnan(x0)&~isnan(y0)
%         plot3(x0,y0,time(t),'.')
%     end
    D = sqrt((x0-zone(:,1)).^2+(y0-zone(:,2)).^2);
    I = D<=InZoneDistance(:);
    z0 = Z(I);
    if isempty(z0)
        z0 = nan;
    end
    if ~isnan(z0)
        if S(z0)==1
            switch z0
                case 1
                    EnteringSoMTime(end+1) = time(t);
                    S = [2 1 0 0];
                    lap = lap+1;
                case 2
                    EnteringCPTime(end+1) = time(t);
                    S = [0 2 1 1];
                    if S(1)==1
                        lap = lap+1;
                    end
                case 3
                    FeederTimes(end+1) = time(t);
                    if length(sd.ZoneDelay)>=lap
                        DelayFix(end+1) = sd.ZoneDelay(lap);
                    else
                        DelayFix(end+1) = nan;
                    end
                    if sd.DelayZone==3
                        ChoiceFix(end+1) = 1;
                    else
                        ChoiceFix(end+1) = 0;
                    end
                    S = [1 0 2 0];
                case 4
                    FeederTimes(end+1) = time(t);
                    if length(sd.ZoneDelay)>=lap
                        DelayFix(end+1) = sd.ZoneDelay(lap);
                    else
                        DelayFix(end+1) = nan;
                    end
                    S = [1 0 0 2];
                    if sd.DelayZone==4
                        ChoiceFix(end+1) = 1;
                    else
                        ChoiceFix(end+1) = 0;
                    end
            end
        end
    end
    if any(S==2) & z0~=Z(S==2)
        switch Z(S==2)
            case 2
                ExitingCPTime(end+1) = time(t);
            case 1
                ExitingSoMTime(end+1) = time(t);
        end
        S(S==2)=0;
    end
end
sd.DelayFix = DelayFix;
sd.ChoiceFix = ChoiceFix;
sd.EnteringSoMTime = EnteringSoMTime;
sd.ExitingSoMTime = ExitingSoMTime;
sd.EnteringCPTime = EnteringCPTime;
sd.FeederFireTimes = sd.FeederTimes;
sd.FeederTimes = FeederTimes;
sd.ExitingCPTime = ExitingCPTime;
sd.TotalLaps = min([length(sd.EnteringSoMTime), length(sd.ExitingSoMTime), length(sd.EnteringCPTime), length(sd.FeederTimes), length(sd.ExitingCPTime)]);


if debug
    cmap = hsv(length(EnteringCPTime));
    clf
    hold on
    for lap = 1 : length(EnteringCPTime)
        x0 = sd.x.restrict(EnteringCPTime(lap),ExitingCPTime(lap));
        y0 = sd.y.restrict(EnteringCPTime(lap),ExitingCPTime(lap));
        plot3(x0.data,y0.data,x0.range,'-','color',cmap(lap,:))
        view(-45,30)
    end
    hold off
    set(gca,'xlim',[0 720])
    set(gca,'ylim',[0 480])
    set(gca,'zlim',[min(sd.x.range) max(sd.x.range)])
    drawnow
end