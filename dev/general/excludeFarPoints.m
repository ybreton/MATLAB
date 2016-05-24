function idEx = excludeFarPoints(A,B,Zx,Zy,threshPx)
% Excludes points that are farther than threshPx away from the straight
% line path from A to B.
idEx = false(length(Zx),1);
V = B-A;
N = norm(V);
xyA = [Zx-A(1) Zy-A(2)];
theta = atan2(V(2),V(1));
rotMat = [cos(-theta) -sin(-theta); sin(-theta) cos(-theta)];
xyR = (rotMat*xyA')';
idIn= xyR(:,1)>0&xyR(:,1)<N;
idLo= xyR(:,1)<=0;
idHi= xyR(:,1)>=N;
idEx(idIn) = abs(xyR(idIn,2))>threshPx;
idEx(idLo) = sqrt((xyR(idLo,1).^2+xyR(idLo,2).^2))>threshPx;
idEx(idHi) = sqrt(((xyR(idHi,1)-V(1)).^2+(xyR(idHi,2)-V(2)).^2))>threshPx;
