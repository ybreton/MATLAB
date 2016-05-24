function [radius,theta,x,y] = RRlinearPath(sd,varargin)
% Takes xy data from restaurant row and returns a linearized path along the
% octogon.
%
%
%
CoM = [nanmean(sd.x.data(sd.EnteringZoneTime)) nanmean(sd.y.data(sd.EnteringZoneTime))];
trackWidth = 50;
process_varargin(varargin);

t = sd.x.range;
theta0 = atan2(sd.y.data-CoM(2),sd.x.data-CoM(1));
radius0 = tsd(t,sqrt((sd.y.data-CoM(2)).^2+(sd.x.data-CoM(1)).^2));
r = nanmean(radius0.data(sd.EnteringZoneTime));
radius0 = radius0.data;

idTrack = radius0>=r-trackWidth & radius0<=r+trackWidth;
idArm = radius0>r+trackWidth;

theta = nan(length(theta0),1);
radius = nan(length(radius0),1);

theta(idTrack) = theta0(idTrack);
radius(idTrack) = 0;

xy(1,:) = (radius0(idArm)-r-trackWidth)'.*cos(theta0(idArm)');
xy(2,:) = (radius0(idArm)-r-trackWidth)'.*sin(theta0(idArm)');

R = [cos(-pi/4) -sin(-pi/4);
     sin(-pi/4)  cos(-pi/4)];
xyPrime = R*xy;

thetaPrime = atan2(xyPrime(2,:)',xyPrime(1,:)');
radiusPrime = sqrt(xyPrime(2,:)'.^2+xyPrime(1,:)'.^2);

thetaArm = (round((thetaPrime/pi)*2)/2)*pi+pi/4;
radius(idArm) = radiusPrime;
thetaArm(thetaArm<-pi) = pi-(abs(thetaArm(thetaArm<-pi))-pi);
thetaArm(thetaArm>pi) = -pi+(thetaArm(thetaArm>pi)-pi);
theta(idArm) = thetaArm;

x = (radius+r).*cos(theta);
y = (radius+r).*sin(theta);
x = tsd(t,x);
y = tsd(t,y);
theta = tsd(t,theta);
radius = tsd(t,radius);