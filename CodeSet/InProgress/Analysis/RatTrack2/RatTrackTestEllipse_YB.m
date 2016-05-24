function [phiB0,phiH0] = RatTrackTestEllipse_YB(im, x0, y0)

global RatTrackParms

nOrientationsB = RatTrackParms.nOrientationsB;
nOrientationsH = RatTrackParms.nOrientationsH;
rB = RatTrackParms.rB;
rH = RatTrackParms.rH;

phiB = RatTrackParms.phiB;
phiH = RatTrackParms.phiH;
PhiBmat = RatTrackParms.PhiBmat;
PhiHmat = RatTrackParms.PhiHmat;
% In units of pi.

% the only region of the image we care about extends 3*rB away from the LED
% position.
% define lower y, upper y, left x, right x bounds of the image we care
% about.
uy = floor(y0-3*rB);
ly = ceil(y0+3*rB);
lx = floor(x0-3*rB);
rx = ceil(x0+3*rB);
% If bound < 1, stop at 1. Don't search outside the actual image.
uy = max(1,uy);
lx = max(1,lx);
% If bound > total size, stop at size. Don't search outside the actual
% image.
ly = min(size(im,1),ly);
lx = min(size(im,2),lx);
imReduced = im(uy:ly,lx:rx);

x = lx:rx;
y = uy:ly;
[X,Y] = meshgrid(x,y);

% Focus of circle B
fBx = x0 + 2*rB * cos(PhiBmat*pi);
fBy = y0 + 2*rB * sin(PhiBmat*pi);
% Focus of circle H
fHx = x0 + 2*rH * cos(PhiHmat*pi);
fHy = y0 + 2*rH * sin(PhiHmat*pi);

dB = squared_dist(X,Y,fBx,fBy);
dH = squared_dist(X,Y,fHx,fHy);

% Thresholded image
T = (double(imReduced)-RatTrackParms.ratColor);
rat = T>0;
rat4D = repmat(rat,[1 1 nOrientationsB nOrientationsH]);

testCircleB = dB<=(rB.^2);
testCircleH = dH<=(rH.^2);

totalB = sum(sum(testCircleB,1),2);
totalH = sum(sum(testCircleH,1),2);

overlapB = rat4D&testCircleB;
overlapH = rat4D&testCircleH;

pOverlapB = sum(sum(overlapB,1),2);
nonOverlapB = totalB - pOverlapB;
sB = nonOverlapB./totalB;

pOverlapH = sum(sum(overlapH,1),2);
nonOverlapH = totalH - pOverlapH;
sH = nonOverlapH./totalB;

s = sB+sH;

s = squeeze(s);

[~,mPhi] = min(s(:));
nPhi = ceil(mPhi/nOrientationsB);
phiB0_mult = phiB(rem(mPhi, nOrientationsB));
phiH0_mult = phiH(nPhi);
idPhiB = phiB0_mult == phiB;
idPhiH = phiH0_mult == phiH;
phiH0 = (phiB0_mult+phiH0_mult)*pi;
phiB0 = phiB0_mult*pi;

if RatTrackParms.debug
    bw1 = false(size(im));
    bw1(floor(y0-4*rB):ceil(y0+4*rB),floor(x0-4*rB):ceil(x0+4*rB)) = squeeze(testCircleB(:,:,idPhiB,idPhiH));
    
    bw2 = false(size(im));
    bw2(floor(y0-4*rB):ceil(y0+4*rB),floor(x0-4*rB):ceil(x0+4*rB)) = squeeze(testCircleH(:,:,idPhiB,idPhiH));
    ShowRatMask(im, imadd(bw1,bw2), s(mPhi));
end


function ShowRatMask(im, r, s)

figure(1); clf
RGB_label = label2rgb(r, @jet, 'k');
imshow(imadd(repmat(im,[1 1 3]),RGB_label));
hold on;
title(num2str(s));
drawnow
return


