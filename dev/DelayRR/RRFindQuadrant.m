function sd = RRFindQuadrant(sd)
% Adds fields to sd containing aligned and rotated (x,y) coordinate systems
% in restaurant row.
%

T = sd.x.range;
xD = sd.x.data-sd.World.MazeCenter.x;
yD = sd.y.data-sd.World.MazeCenter.y;

Q1 = xD>=0 & yD >= 0;
Q2 = xD>=0 & yD<0;
Q3 = xD<0 & yD <0;
Q4 = xD<0 & yD>=0;
idnan = isnan(xD)|isnan(yD);

qD = Q1 + 2*Q2 + 3*Q3 + 4*Q4;
qD(idnan) = nan;
sd.quadrant = tsd(T, qD);

xA = nan(size(xD)); yA = xA;
xA(Q1) = xD(Q1);  xA(Q2) = -yD(Q2); xA(Q3) = -xD(Q3); xA(Q4) = yD(Q4);
yA(Q1) = yD(Q1);  yA(Q2) = xD(Q2);  yA(Q3) = -yD(Q3); xA(Q4) = -xD(Q4);

sd.xR = tsd(T,xA);
sd.yR = tsd(T,yA);

sd.xR = cell(4,1); sd.yR = cell(4,1);
sd.xR{1} = tsd(T, xD);  sd.yR{1} = tsd(T, yD);
sd.xR{2} = tsd(T, -yD); sd.yR{2} = tsd(T, xD);
sd.xR{3} = tsd(T, -xD); sd.yR{3} = tsd(T, -yD);
sd.xR{4} = tsd(T, yD);  sd.yR{4} = tsd(T, -xD);
