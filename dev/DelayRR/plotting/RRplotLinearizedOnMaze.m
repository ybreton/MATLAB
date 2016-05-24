function RRplotLinearizedOnMaze(sd)
%
%
%
%

[x,y] = RRcentreMaze(sd);
plot(x.data,y.data,'.','markerfacecolor',[0.8 0.8 0.8],'markeredgecolor',[0.8 0.8 0.8]);
hold on; 
plot(sd.landmarks.ZoneEntry.X,sd.landmarks.ZoneEntry.Y,'go'); 
plot(sd.landmarks.ChoicePoint.X,sd.landmarks.ChoicePoint.Y,'rx'); 
plot(sd.landmarks.Feeder.X,sd.landmarks.Feeder.Y,'ks');

for iZ=1:length(sd.landmarks.ZoneEntry.X)
    linPos = sd.landmarks.ZoneEntry.LinPos(iZ);
    str = sprintf('Z%d=%d',iZ,linPos);
    th=text(sd.landmarks.ZoneEntry.X(iZ),sd.landmarks.ZoneEntry.Y(iZ),str);
    set(th,'verticalalignment','top')
    set(th,'horizontalalignment','center')
    
    linPos1 = sd.landmarks.ChoicePoint.LinPos(iZ);
    linPos2 = sd.landmarks.ArmExit.LinPos(iZ);
    str = sprintf('CP_{in}%d=%d\nCP_{out}%d=%d',iZ,linPos1,iZ,linPos2);
    th=text(sd.landmarks.ChoicePoint.X(iZ),sd.landmarks.ChoicePoint.Y(iZ),str);
    set(th,'verticalalignment','top')
    set(th,'horizontalalignment','center')
    
    linPos = sd.landmarks.Feeder.LinPos(iZ);
    str = sprintf('F%d=%d',iZ,linPos);
    th=text(sd.landmarks.Feeder.X(iZ),sd.landmarks.Feeder.Y(iZ),str);
    set(th,'verticalalignment','top')
    set(th,'horizontalalignment','center')
    
end

hold off