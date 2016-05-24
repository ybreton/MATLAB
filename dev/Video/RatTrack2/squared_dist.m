function Dsq = squared_dist(X,Y,Fx,Fy)
% Finds squared distance from (Fx,Fy) to (X4D,Y4D).
m = size(X,1);
n = size(Y,2);
p = size(Fx,1);
q = size(Fy,2);

X = reshape(X,[m n 1 1]);
Fx = reshape(Fx,[1 1 p q]);
Y = reshape(Y,[m n 1 1]);
Fy = reshape(Fy,[1 1 p q]);

X = repmat(X,[1 1 p q]);
Y = repmat(Y,[1 1 p q]);
Fx = repmat(Fx,[m n 1 1]);
Fy = repmat(Fy,[m n 1 1]);

DevX = X-Fx;
DevY = Y-Fy;

% Dsq = square_sum_mex(DevX(:),DevY(:));
Dsq = DevX(:).^2+DevY(:).^2;
Dsq = reshape(Dsq,[m n p q]);