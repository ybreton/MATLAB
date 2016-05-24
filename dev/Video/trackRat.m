function [Hx,Hy,Bx,By] = trackRat(x,y,I,testCircleH,testCircleB,phiH,phiB,rb,rh,xlim,ylim)
%was trackRat(x,y,I,,phiHmat,phiBmat,rb,rh)
xmin = xlim(1);
xmax = xlim(2);
ymin = ylim(1);
ymax = ylim(2);
xPos = floor(x-3*rb):ceil(x+3*rb);
idX = xPos>xmin & xPos<xmax;
yPos = floor(y-3*rb):ceil(y+3*rb);
idY = yPos>ymin & yPos<ymax;
imReduced = nan(length(yPos),length(xPos));
imReduced(idY,idX) = I(yPos(idY),xPos(idX));
im4D = repmat(imReduced,[1 1 size(testCircleB,3) size(testCircleH,4)]);
% 
% testCircleB = testCircleUnpack(tcB,x,y);
% testCircleH = testCircleUnpack(tcH,x,y);
% testCircleB0 = testCircleB(yPos(idY),xPos(idX),:,:);
% testCircleH0 = testCircleH(yPos(idY),xPos(idX),:,:);

OverlapB = testCircleB(:,:,:,1) & (im4D(:,:,:,1)==1);

pOverlapB = squeeze((nansum(nansum(OverlapB,1),2))./((nansum(nansum(testCircleB(:,:,:,1),1),2))));
[~,idB] = max(pOverlapB,[],1);
% which body position covers the largest amount of rat?

OverlapH = testCircleH(:,:,idB,:) & (im4D(:,:,idB,:)==1);

pOverlapH = squeeze(((nansum(nansum(OverlapH,1),2)))./(nansum(nansum(testCircleH(:,:,idB,:),1),2)));
[~,idH] = max(pOverlapH);
% given that body position, which head position covers it?

% pOverlap = pOverlapB+pOverlapH;
% sH = nansum(nansum(OverlapB,1),2);
% sB = nansum(nansum(OverlapH,1),2);
% tH = nansum(nansum(testCircleH,1),2);
% tB = nansum(nansum(testCircleB,1),2);
% pOverlap = squeeze((sH+sB)./(tH+tB));
% [~,idH] = max(max(pOverlap,[],2));
% [~,idB] = max(max(pOverlap,[],1));

LEDphiH = phiH(idH)+phiB(idB);
LEDphiB = phiB(idB);

Hx = x+2*rh*cos(LEDphiH);
Hy = y+2*rh*sin(LEDphiH);
Bx = x+2*rb*cos(LEDphiB);
By = y+2*rb*sin(LEDphiB);