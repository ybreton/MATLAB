function [x,y] = CleanAnyMazeXY(x,y)

% [x,y] = CleanAnyMazeXY(x,y)
%
% removes doubletimed xs and ys but checks to make sure that x and y do not
% change when doubletimed

% unpackage
xt = x.range; xd = x.data;
yt = y.range; yd = y.data;

% check
assert(all(xt==yt));
assert(all(xt>=0));

% find and remove doubletimes
keep = find(diff(xt)>0);

% repackage and pad missing end value from diff if last value is unique
if (xt(end)-xt(keep(end)))>0
   x = tsd((vertcat(xt(keep),xt(end))),(vertcat(xd(keep),xd(end))));
   y = tsd((vertcat(yt(keep),yt(end))),(vertcat(yd(keep),yd(end))));
else
    x = tsd(xt(keep),xd(keep));
    y = tsd(yt(keep),yd(keep));


end
