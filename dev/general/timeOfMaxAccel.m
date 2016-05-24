function tmax = timeOfMaxAccel(x,y)
% Identifies when acceleration is maximal.

dx = dxdt(x);
dy = dxdt(y);
ddx = dxdt(dx);
ddy = dxdt(dy);

accel = tsd(range(ddx),sqrt(ddx.data.^2+ddy.data.^2));

[Amax,I]=max(accel.data);
t = accel.range;
tmax = t(I);