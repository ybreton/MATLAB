function [Xprime,Yprime] = RRrotateCoordSystem(theta, center, X, Y)
% Given a set of matrices, X and Y, with x and y values as their respective
% elements, RRrotateCoordSystem rotates the coordinate system by angle
% theta through the user-defined center.
% [Xprime,Yprime] = RRrotateCoordSystem(theta, center, Xc, Yc)
%
%
% for example,
% X = [1 2;1 2];
% Y = [1 1;2 2];
% [Xprime,Yprime] = RRrotateCoordSystem(-pi/2, [0 0], X, Y)
%
% Xprime =
% 
%     1.0000    1.0000
%     2.0000    2.0000
% 
% 
% Yprime =
% 
%    -1.0000   -2.0000
%    -1.0000   -2.0000
%
% Xprime and Yprime are X and Y when rotated by -pi/2 radians about point
% [0 0].
%
if isempty(center)
    center = [0 0];
end

assert(all(size(X)==size(Y)),'X and Y must have identical size.')

rotMat = [cos(theta) -sin(theta); sin(theta) cos(theta)];

sz = size(X);

Xc = X(:)-center(1);
Yc = Y(:)-center(2);

XYc = rotMat*[Xc';Yc'];
Xprime = XYc(1,:);
Yprime = XYc(2,:);
Xprime = Xprime+center(1);
Yprime = Yprime+center(2);

Xprime = reshape(Xprime,sz);
Yprime = reshape(Yprime,sz);