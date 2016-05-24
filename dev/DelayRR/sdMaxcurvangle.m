function sd = sdMaxcurvangle(sd)
% adds maxcurvangle field to sd with angle of velocity components at the
% point of maximum curvature

theta = tsd(sd.dx.range,atan2(sd.dy.data,sd.dx.data));
sd.maxcurvangle = theta.data(sd.curvtime);