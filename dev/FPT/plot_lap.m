function plot_lap(sd,lap)

if nargin<2
    lap = 1:sd.TotalLaps;
end

SOM = [sd.Coord.SoM_x sd.Coord.SoM_y];
CP = [sd.Coord.CP_x sd.Coord.CP_y];
LF = [sd.Coord.LF_x sd.Coord.LF_y];
RF = [sd.Coord.RF_x sd.Coord.RF_y];

Z = [SOM; CP; LF; RF];
r = sd.InZoneDistance;

for l = 1 : length(lap)
    L = lap(l);
    x0 = sd.x.restrict(sd.EnteringSoMTime(L),sd.ExitingSoMTime(L));
    y0 = sd.y.restrict(sd.EnteringSoMTime(L),sd.ExitingSoMTime(L));

    x1 = sd.x.restrict(sd.EnteringCPTime(L),sd.ExitingCPTime(L));
    y1 = sd.y.restrict(sd.EnteringCPTime(L),sd.ExitingCPTime(L));

    x2 = sd.x.restrict(sd.EnteringZoneTime(L),sd.ExitZoneTime(L));
    y2 = sd.y.restrict(sd.EnteringZoneTime(L),sd.ExitZoneTime(L));
    
    clf
    set(gca,'xlim',[0 720])
    set(gca,'ylim',[0 480])
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    title(sprintf('Lap %d',L));
    hold on
    circle(Z(1,:),r(1),1000,':g');
    circle(Z(2,:),r(2),1000,':y');
    circle(Z(3,:),r(3),1000,':r');
    circle(Z(4,:),r(4),1000,':r');
    plot(x0.data,y0.data,'c-','linewidth',2)
    plot(x1.data,y1.data,'b-','linewidth',2)
    plot(x2.data,y2.data,'m-','linewidth',2)
    if L<length(sd.EnteringSoMTime)
        x3 = sd.x.restrict(sd.EnteringSoMTime(L),sd.EnteringSoMTime(L+1));
        y3 = sd.y.restrict(sd.EnteringSoMTime(L),sd.EnteringSoMTime(L+1));
        plot(x3.data,y3.data,'k-')
    end
    axis image
    hold off
    pause;
end