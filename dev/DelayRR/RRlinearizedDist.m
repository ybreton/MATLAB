function D = RRlinearizedDist(sd, t1, x1, y1, t2, x2, y2)
% Converts x1, y1 to linear coordinate L1, and
% x2, y2 to linear coordinate L2, and
% computes the distance between them.

L1 = RRlinearizedVal(sd,t1,x1,y1);
L2 = RRlinearizedVal(sd,t2,x2,y2);

% Now that we have our two linear coordinates, we take the distance to get
% their distance
D = distance(L1,L2);

function delta = distance(L1,L2)
d1 = (L2+4)-L1;
d2 = L2-L1;
d = [d1 d2];
[~,I] = min(abs(d));
delta = d(I);