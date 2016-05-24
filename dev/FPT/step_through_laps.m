function step_through_laps(sd,Entering,Exiting,Zone)

if nargin<1
    Exiting = Entering+1;
end
% if length(Exiting)<length(Entering)
%     Exiting(length(Exiting)+1:end) = Entering(length(Entering)+1:end)+1;
% end
% if length(Entering)<length(Exiting)
%     Entering(length(Entering)+1:end) = Exiting(length(Exiting)+1:end)-1;
% end
x = sd.x;
y = sd.y;
for iLap = 1 : length(Entering)
    xLap = x.restrict(Entering(iLap)*1e6,Exiting(iLap)*1e6);
    yLap = y.restrict(Entering(iLap)*1e6,Exiting(iLap)*1e6);
    
    cla
    hold on
    plot(xLap.data,yLap.data,'k-')
    circle(Zone,60,1000,'r-')
    hold off
    axis equal
    set(gca,'xlim',[0 720])
    set(gca,'ylim',[0 480])
    
    pause;
    
end