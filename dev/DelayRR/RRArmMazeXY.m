function sd = RRArmMazeXY(sd,varargin)
% 35cm radius from feeder

radiuscm = 35;
debug = false;
process_varargin(varargin);

radiuspx = (1./(RRpx2cm(sd,1)))*radiuscm;

t = sd.x.range;
x = sd.x.data;
y = sd.y.data;

d = nan(length(x),length(sd.World.FeederLocations.x));
for iZ=1:length(sd.World.FeederLocations.x)
    d(:,iZ) = sqrt((x-sd.World.FeederLocations.x(iZ)).^2+(y-sd.World.FeederLocations.y(iZ)).^2);
end

inArm = any(d<=radiuspx,2);
onMaze = all(d>radiuspx,2);

sd.xArm = tsd(t(inArm),x(inArm));
sd.yArm = tsd(t(inArm),y(inArm));
sd.xMaze = tsd(t(onMaze),x(onMaze));
sd.yMaze = tsd(t(onMaze),y(onMaze));
sd.tArm = ts(t(inArm));
sd.tMaze = ts(t(onMaze));

if debug
    plot(x,y,'k.');
    hold on
    plot(x(inArm),y(inArm),'ro')
    plot(x(onMaze),y(onMaze),'go')
    hold off
end