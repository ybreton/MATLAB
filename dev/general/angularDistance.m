function [angDist,r] = angularDistance(A,Bx,By)
% Finds the angular distance from A = [x,y] and all points in (Bx,By).
% angDist = angularDistance(A,Bx,By)
% where     angDist     is the angular distance from A to B in radians,
%
%           A           is a 2-element vector with x,y for A,
%           Bx          is a matrix of x positions for B,
%           By          is a matrix of y positions for B.
%
% [angDist,r] = angularDistance(A,Bx,By)
% where     r           is the difference in radial distance from A to B.

A = A(:);
assert(all(size(Bx)==size(By)),'Size of Bx must match size of By.');
assert(numel(A)==2,'A must be a 2-element vector with x and y coordinate.')
sz = size(Bx);

Bx = Bx(:);
By = By(:);
theta = atan2(A(2),A(1));
rotMat = [cos(-theta) -sin(-theta); sin(-theta) cos(-theta)];
rotA = rotMat*A;
radial = sqrt(rotA(:)'*rotA(:));
angDist = nan(length(Bx),1);
if nargout>1
    r = nan(length(Bx),1);
end
for iPt = 1 : length(Bx)
    xyPrime = rotMat*[Bx(iPt);By(iPt)];
    angDist(iPt) = atan2(xyPrime(2),xyPrime(1));
    if nargout>1
        r(iPt) = sqrt(xyPrime(:)'*xyPrime(:)) - radial;
    end
end
angDist = reshape(angDist,sz);
if nargout>1
    r = reshape(r,sz);
end