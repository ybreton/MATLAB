function cm=RRpx2cm(sd,px)
% Converts pixels to centimeters in restaurant row.

% the maze is 26 inches from center to center.
% That's 26*2.54 centimeters.
width = 26*2.54;

% the difference in y position of zone locations 1 and 3 gives the
% top-to-bottom distance.
dy = abs(sd.World.ZoneLocations.y(1)-sd.World.ZoneLocations.y(3));

% the distance in x position of zone locations 2 and 4 gives the
% right-to-left distance.
dx = abs(sd.World.ZoneLocations.x(2)-sd.World.ZoneLocations.x(4));

% cm per pixel top/bottom
cmy = width./dy;
% cm per pixel right/left
cmx = width./dx;

cmPerPx = nanmean([cmy;cmx]);
% cm is pixel*cm/pixel
cm = px.*cmPerPx;