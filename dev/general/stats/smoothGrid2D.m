function R = smoothGrid2D(G,F)
% Smooths a grid G of values in a block of size F by averaging the values.

xmax = size(G,2);
ymax = size(G,1);

xbins = 1:size(G,2);
ybins = 1:size(G,1);

R = nan(ymax,xmax);
for ix=1:length(xbins)
    xlo = floor(max(1,xbins(ix)-F/2));
    xhi = ceil(min(xmax,xbins(ix)+F/2));
    for iy=1:length(ybins)
        ylo = floor(max(1,ybins(iy)-F/2));
        yhi = ceil(min(ymax,ybins(iy)+F/2));
        
        idx = [xlo:xhi];
        idy = [ylo:yhi];
        G0 = G(idy,idx);
        s = nansum(G0(isOK(G0)));
        n = numel(G0(isOK(G0)));
        R(iy,ix) = s/n;
    end
end