function [m,bins] = RRavgDecodeAngle(B,x,y,t,window,varargin)
% 
% B, x, y, t, window
% nBins

nBins = 64;
exclTimes = [];
process_varargin(varargin);

% Get the x,y coordinates of tuning curve matrices.
xBins = linspace(B.min(1),B.max(1),B.nBin(1));
yBins = linspace(B.min(2),B.max(2),B.nBin(2));
xCentre = mean(xBins);
yCentre = mean(yBins);
[Xtc,Ytc] = meshgrid(xBins,yBins);

% Remove the centre.
Xc = Xtc-xCentre;
Yc = Ytc-yCentre;

% Find the rat as he enters zone.
xRat = x.data(t);
yRat = y.data(t);

% Remove the centre.
Xr = xRat - xCentre;
Yr = yRat - yCentre;

% Find the angular difference.
angDist = angularDistance([Xr;Yr],Xc,Yc);

% Find decoding.
pxs = B.pxs;
pxs = pxs.restrict(t,t+window);
Pxy = pxs.data;
txy = pxs.range;

if ~isempty(exclTimes)
    idxExcl = false(length(txy),length(exclTimes));
    for iExcl = 1:length(exclTimes)
        idxExcl(:,iExcl) = txy==exclTimes(iExcl);
    end
    idxExcl=any(idxExcl,2);
    Pxy = Pxy(~idxExcl,:,:);
end

binw = 2*pi/nBins;
bins = -pi+binw/2:binw:pi-binw/2;

LB = bins-binw/2;
UB = bins+binw/2;
m = nan(length(bins),1);
decoding = nan(size(Pxy,1),length(bins));
for iT=1:size(Pxy,1)
    for iBin = 1 : length(bins)
        idx = angDist>LB(iBin) & angDist<=UB(iBin);
        PxyT = squeeze(Pxy(iT,:,:));
        decoding(iT,iBin) = nanmean(PxyT(idx));
    end
end

m = nanmean(decoding,1);