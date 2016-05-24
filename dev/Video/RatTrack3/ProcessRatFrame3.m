function ProcessRatFrame3(data, width, height, frameNr, time)

% processRatFrame
% based on
% processFrame(data,width,height,frameNr)
%
% This is the function prototype to be used by the matlabCommand option of
% mmread.
% INPUT
%   data        the raw captured frame data, the code below will put it
%               into a more usable form
%   width       the width of the image
%   height      the height of the image
%   frameNr     the frame # (counting starts at frame 1)
%   time        the time stamp of the frame (in seconds)
%

global RatTrackParms

global RatTrackData

%-------------
% prepare frame
% f = RatTrackPrepareFrameFromVideo(data, width, height, frameNr, time);
f = data(1).cdata;
clear data

% Check for bad frames.
Sqdev = (rgb2gray(f)*255 - rgb2gray(RatTrackData.lastFrame)*255).^2;
D = sqrt(mean(Sqdev(:)));
if RatTrackParms.showProg
    hold on
    title(num2str(frameNr))
    plot(frameNr/30/60,D,'ko','markerfacecolor','k','markersize',8)
    xlabel('Minutes')
    ylabel('RMS')
    hold off
    drawnow
end
if D>=10;
%     fprintf('\nBad frame issue at frame %d; RMS-255 grayscale difference from last frame is %.1f>=10\n',frameNr,D)
    RatTrackData.BadFrames = [RatTrackData.BadFrames; frameNr];
else

    
% convert to grayscale
red = squeeze(f(:,:,1));
g = rgb2gray(f); 

%-------------
% find the LED
LEDx = nan; LEDy = nan; LEDphi = nan;
bw = im2bw(red);
cc = bwconncomp(bw);
foundRat = cc.NumObjects > 0;
if foundRat
	mCC = maxRegion(cc);
    
	z = regionprops(cc, 'centroid');
	clear cc
    C = z(mCC).Centroid;  LEDx = C(1); LEDy = C(2);
    clear C
	LEDroi = roipoly(g, LEDx + 15*cos(-pi:0.1:pi), LEDy + 15*sin(-pi:0.1:pi));
    clear g
	%-------------
	% find the rat
	if RatTrackParms.getOrientation && D<10
        g0 = rgb2gray(RatTrackData.meanFrame-f)*RatTrackParms.brightenFactor;
		rg0 = imadd(double(LEDroi)*100,g0);
        clear g0 LEDroi
        % Edge detection
        
		% find all ellipses that are of a certain size
% 		[LEDphiB, LEDphiH] = RatTrackTestEllipse(rg0, LEDx, LEDy);
        [LEDphiB, LEDphiH] = RatTrackTestEllipse_YB(rg0, LEDx, LEDy);
    else
        LEDphiB = nan;
        LEDphiH = nan;
    end
else
    LEDphiB = NaN;
    LEDphiH = NaN;
end  % if found rat
	
%-------------
% display and debug
if RatTrackParms.debug
	RatDisplayImage(g0,  2, 'subtracted', time);
% 	RatDisplayImage(g*3, 3, 'gray', time);
	hold on
	plot(LEDx, LEDy, 'ro', 'MarkerFaceColor','r');
	plot(LEDx + [0 25*cos(LEDphiB)], LEDy + [0 25*sin(LEDphiB)], 'r-','LineWidth',2);
	plot(LEDx + [0 25*cos(LEDphiH)], LEDy + [0 25*sin(LEDphiH)], 'g-','LineWidth',2);
	drawnow
end

%-------------
RatTrackData.LEDx(RatTrackData.currentFrameCount) = LEDx;
RatTrackData.LEDy(RatTrackData.currentFrameCount) = LEDy;
if RatTrackParms.getOrientation
    RatTrackData.LEDphiB(RatTrackData.currentFrameCount) = LEDphiB;
    RatTrackData.LEDphiH(RatTrackData.currentFrameCount) = LEDphiH;
    RatTrackData.Hx(RatTrackData.currentFrameCount,1) = LEDx+25*cos(LEDphiH);
    RatTrackData.Hy(RatTrackData.currentFrameCount,1) = LEDy+25*sin(LEDphiH);
else
    RatTrackData.LEDphiB(RatTrackData.currentFrameCount) = nan;
    RatTrackData.LEDphiH(RatTrackData.currentFrameCount) = nan;
    RatTrackData.Hx(RatTrackData.currentFrameCount,1) = nan;
    RatTrackData.Hy(RatTrackData.currentFrameCount,1) = nan;
end
end
RatTrackData.iFrame(RatTrackData.currentFrameCount) = frameNr;
RatTrackData.timestamp(RatTrackData.currentFrameCount) = time;
RatTrackData.currentFrameCount = RatTrackData.currentFrameCount+1;

%==============================
function mCC = maxRegion(cc)
nCC = length(cc.PixelIdxList);
m = zeros(nCC,1);
for iCC = 1:nCC
	m(iCC) = length(cc.PixelIdxList{iCC});
end
[~, mCC] = max(m);
