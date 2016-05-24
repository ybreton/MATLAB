function [testCircleB,testCircleH] = EZ_trackingTestCircles(rez,phiH,phiB,rh,rb)
% Returns LEDxOffset x LEDyOffset x phiB x phiH
% matrices of testCircleB and testCircleH.
%

maxR = max(rb,rh);
xTmp = floor(-3*maxR):ceil(3*maxR);
yTmp = floor(-3*maxR):ceil(3*maxR);
[X,Y] = meshgrid(xTmp,yTmp);
% tcH.x = cell(length(phiB),length(phiH));
% tcH.y = cell(length(phiB),length(phiH));
% tcB.x = cell(length(phiB),length(phiH));
% tcB.y = cell(length(phiB),length(phiH));
testCircleB = false(6*maxR+1,6*maxR+1,length(phiB),length(phiH));
testCircleH = false(6*maxR+1,6*maxR+1,length(phiB),length(phiH));

for iB = 1 : length(phiB)
    for iH = 1 : length(phiH)
        fBx = 2*rb * cos(phiB(iB));
        fBy = 2*rb * sin(phiB(iB));

        fHx = 2*rh * cos(phiB(iB)+phiH(iH));
        fHy = 2*rh * sin(phiB(iB)+phiH(iH));

        dB = (X-fBx).^2+(Y-fBy).^2;
        dH = (X-fHx).^2+(Y-fHy).^2;
        Ih = dH<=rh.^2;
        Ib = dB<=rb.^2;
%         Xh = X(Ih);
%         Yh = Y(Ih);
%         Xb = X(Ib);
%         Yb = Y(Ib);
%         tcH.x{iB,iH} = Xh;
%         tcH.y{iB,iH} = Yh;
%         tcB.x{iB,iH} = Xb;
%         tcB.y{iB,iH} = Yb;
        testCircleB(:,:,iB,iH) = Ib;
        testCircleH(:,:,iB,iH) = Ih;
    end
end
