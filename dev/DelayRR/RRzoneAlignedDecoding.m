function [BAligned,xAligned,yAligned] = RRzoneAlignedDecoding(sd,B,T)
%
%
%
%

sd = RRFindQuadrant(sd);

[X,Y] = TuningCoordSystem(B);
% Each pixel in B.pxs now has an address.

zone = tsd(sd.EnteringZoneTime',sd.ZoneIn');
Quad = nan(4,1);
for iZ=1:4;
    Tf = sd.FeederTimes(sd.FeedersFired==iZ);
    Q = sd.quadrant.data(Tf);
    Quad(iZ) = nanmedian(Q);
end

BAligned = nan([length(T) B.nBin]);
xAligned = nan(length(T),1);
yAligned = xAligned;
for iTrl = 1 : length(T)
    iZ = zone.data(T(iTrl));
    Decoding = squeeze(B.pxs.data(T(iTrl)));
    DecodeRot = rot90(Decoding,-(Quad(iZ)-1));
    BAligned(iTrl,:,:) = reshape(DecodeRot,[1 size(DecodeRot)]);
    xAligned(iTrl) = sd.xR{Quad(iZ)}.data(T(iTrl));
    yAligned(iTrl) = sd.yR{Quad(iZ)}.data(T(iTrl));
end