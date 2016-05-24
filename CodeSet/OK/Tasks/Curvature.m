function C = Curvature(x,y)

% function C = Curvature(x,y)
% calculates the following parameters and adds them to sd
% (removes nans first, otherwise nans propogate with differentiation
% operations)
%
% dx, dy: velocity
% ddx, ddy: acceleration
% C: curvature, as defined by Hart 1999 (Int J Med Informatics) 
% C(t) = (dx(t) * ddy(t) + dy(t) * ddx(t))*(dx(t)^2+dy(t)^2)^-3/2
%
% ADR 2012 Nov
% YAB 2015 Jan:     changed to x,y arguments for arbitrary x,y positions.

x = x.removeNaNs;
y = y.removeNaNs;
T = x.range;

dx = dxdt(x); dx = tsd(T, dx.data(T, 'extrapolate', nan));
dy = dxdt(y); dy = tsd(T, dy.data(T, 'extrapolate', nan));
ddx = dxdt(dx); ddx = tsd(T, ddx.data(T, 'extrapolate', nan));
ddy = dxdt(dy); ddy = tsd(T, ddy.data(T, 'extrapolate', nan));

N = (dx.data .* ddy.data + dy.data .* ddx.data);
D = (dx.data.^2 + dy.data.^2).^(1.5);

C = tsd(T, N./D);
