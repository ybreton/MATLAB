function [theta,r] = RRpolar(x,y,varargin)
% Returns x and y tsd's as polar coordinates.
% [theta,r] = RRpolar(x,y)
% where         theta       is a tsd or numeric of the angle,
%               r           is a tsd or numeric of the radius,
%
%               x           is a tsd or numeric of x position,
%               y           is a tsd or numeric of y position.
%
% OPTIONAL ARGUMENTS:
% ******************
% CoM       (default mean x,y)   x,y coordinates of Center of Maze
% SoMangle  (default -pi/2)      theta corresponding to Start of Maze
%
SoMangle = -pi/2;
process_varargin(varargin);

if isa(x,'tsd')
    CoM = [nanmean(x.data) nanmean(y.data)];
    process_varargin(varargin);
    assert(isa(y,'tsd'),'X and Y must both be tsd''s or both be numeric.')
    assert(all(x.range==y.range),'Time stamps must match.')
    
    x0 = x.data-CoM(1);
    y0 = y.data-CoM(2);
    t0 = x.range;
end

if isa(x,'numeric')
    CoM = [nanmean(x) nanmean(y)];
    process_varargin(varargin);
    
    assert(length(size(x))==length(size(y)),'X and Y must have identical dimensionality.');
    assert(all(size(x)==size(y)),'X and Y must have identical size if numeric.')
    
    x0 = x-CoM(1);
    y0 = y-CoM(2);
end

theta0 = atan2(y0,x0);
theta1 = theta0-SoMangle;
theta1(theta1<0) = 2*pi+theta1(theta1<0);
r1 = (x0.^2+y0.^2).^(0.5);

if isa(x,'tsd')
    theta = tsd(t0,theta1);
    r = tsd(t0,r1);
end
if isa(x,'numeric')
    theta = theta1;
    r = r1;
end