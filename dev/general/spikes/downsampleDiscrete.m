function xds=downsampleDiscrete(x,nx)
% Downsamples x tsd data to discrete nx bins.
%
%

[f,xbin] = hist(x.data,nx);
xlo = xbin-nanmean(diff(xbin));
xhi = xbin+nanmean(diff(xbin));
d = x.data;
t = x.range;
Xlo = repmat(xlo(:)',[length(d) 1]);
Xhi = repmat(xhi(:)',[length(d) 1]);
Xdat = repmat(d(:),[1 length(xbin)]);
I = Xdat>=Xlo & Xdat<Xhi;

x0 = nan(length(d),1);
for iB=length(xbin):-1:1
    x0(I(:,iB)) = xbin(iB);
end
xds = tsd(t,x0);