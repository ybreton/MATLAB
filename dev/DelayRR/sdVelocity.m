function sd = sdVelocity(sd)
% adds dx and dy fields to sd with velocity components along x and y, and v
% field for speed; also adds acceleration fields.

sd.dx = dxdt(sd.x);
sd.dy = dxdt(sd.y);
sd.ddx = dxdt(sd.dx);
sd.ddy = dxdt(sd.dy);
sd.v = tsd(sd.dx.range,sqrt(sd.dx.data.^2+sd.dy.data.^2));
sd.a = tsd(sd.ddx.range,sqrt(sd.ddx.data.^2+sd.ddy.data.^2));