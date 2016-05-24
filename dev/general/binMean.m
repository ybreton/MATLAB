function yb = binMean(x,y,xb,varargin)
%
%
%
%

for ix = 1 : length(xb)-1
    id = x>=xb(ix)&x<xb(ix+1);
    yb(ix) = nanmean(y(id));
end
yb(length(xb)) = nanmean(y(x>=xb(end)));
