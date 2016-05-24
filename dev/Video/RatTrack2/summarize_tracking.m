function fh = summarize_tracking(fn,sd)

if nargin < 1
    fn = 'VT1_mpeg1';
end

vObj = VideoReader([fn '.mpg']);
fr = read(vObj,1);
CP(1) = sd.Coord.CP_x;
CP(2) = sd.Coord.CP_y;
SoM(1) = sd.Coord.SoM_x;
SoM(2) = sd.Coord.SoM_y;
LF(1) = sd.Coord.LF_x;
LF(2) = sd.Coord.LF_y;
RF(1) = sd.Coord.RF_x;
RF(2) = sd.Coord.RF_y;
r = 60;

clf
fh = gcf;
cla
imshow(fr)
hold on
patch([CP(1)-r CP(1)-r CP(1)+r CP(1)+r],[CP(2)-r CP(2)+r CP(2)+r CP(2)-r],[1 1 1 1],'facealpha',0.2,'facecolor','y','edgecolor','none')
patch([SoM(1)-r SoM(1)-r SoM(1)+r SoM(1)+r],[SoM(2)-r SoM(2)+r SoM(2)+r SoM(2)-r],[1 1 1 1],'facealpha',0.2,'facecolor','g','edgecolor','none')
patch([LF(1)-r LF(1)-r LF(1)+r LF(1)+r], [LF(2)-r LF(2)+r LF(2)+r LF(2)-r],[1 1 1 1],'facealpha',0.2,'facecolor','r','edgecolor','none')
patch([RF(1)-r RF(1)-r RF(1)+r RF(1)+r], [RF(2)-r RF(2)+r RF(2)+r RF(2)-r],[1 1 1 1],'facealpha',0.2,'facecolor','r','edgecolor','none')
ch(1)=circle(CP,60,377);
ch(2)=circle(SoM,60,377);
ch(3)=circle(LF,60,377);
ch(4)=circle(RF,60,377);
set(ch,'LineWidth',3)
set(ch,'Color','k')
scatter(sd.x.D,sd.y.D,4,sd.x.T)
th(1)=text(CP(1),CP(2),'CP','color','w');
th(2)=text(SoM(1),SoM(2),'Start','color','w');
th(3)=text(RF(1),RF(2),'Right Feeder','color','w');
th(4)=text(LF(1),LF(2),'Left Feeder','color','w');
set(th,'verticalalignment','middle')
set(th,'horizontalalignment','center')
cbh = colorbar;
clim = get(cbh,'ylim');
set(cbh,'ytick',[0:300:max(clim)])
set(cbh,'yticklabel',mat2can([0:300:max(clim)]))
yh = get(cbh,'ylabel');
set(yh,'string','Seconds since session start')

axis image
hold off

saveas(fh,[fn '.fig'])
saveas(fh,[fn '.eps'],'epsc')