function Head = TRACK_HEAD_FROM_LED(fn,LED,varargin)
% Returns head position from mp4 file fn.
% Head = EZ_HEADTRACKER(fn)
% where     Head        is a structure array with fields
%               .x
%               .y
%                       that are tsd's of the x,y positions of the head,
%               .lum    is the mean luminance at basline.
%
%
%           fn          is a string specifying the file name
%           LED         is a structure with x and y tsd's with the LED
%                           location at each time point required.
%
% Each frame pixel is Z-scored to the frame's overall luminance and SD, and
% that Z-scored pixel is then compared to the mean frame-Z-scored over the
% first nBLframes (90), in units of standard deviation for that pixel over
% the first nBLframes.
%
% When the LED is in frame, the rat is identified as the pixels for which
% the deviation of Z-scored frame luminance, in units of pixel sd's during
% baseline, from baseline Z-scored luminance, is below threshZ (-1.64). 
%
% The algorithm then finds head position by sweeping a body circle of
% radius rb (20) pixels, with center at 2*rb, fully around the LED
% position, and a head circle of radius rh (12) pixels, with center at
% 2*rb, in the semicircle pointing away from the body. Body and head are
% inferred as the positions of the circles that maximize coverage of rat
% pixels, defined as above.
%
% OPTIONAL ARGUMENTS:
% ******************
% nOrientationsB    (default 16)        number of body orientations,
% nOrientationsH    (default 24)        number of head orientations,
% rb                (default 20)        body circle radius,
% rh                (default 10)        head circle radius,
% nBLframes         (default 90)        number of baseline frames for
%                                           subtraction,
% threshZ           (default -1.64)    threshold Z score of deviation from
%                                           baseline frame for (dark) rat,
% xlim              (default [135 650]) limit of frame along x-axis;
%                                           excludes pixels outside of
%                                           frame,
% ylim              (default [15 465])  limit of frame along y-axis;
%                                           excludes pixels outside of
%                                           frame,
% excludeXY         (default [])
%                                      top left XY, bottom right XY list of
%                                           rectangles to exclude from
%                                           tracking. Default excludes
%                                           nothing. 
%
% t                 (default all)      list of time stamps to include in
%                                           video tracking, 
% debug             (default false)     produce debugging plots,
% progressBar       (default true)      display tracking progress.
% rez               (default [720,480]) resolution of tracking video.
%
%

nOrientationsB = 16;
nOrientationsH = 24;
rb = 20;
rh = 10;
nBLframes = 90;
threshZ = -1.64;
xlim = [135 650];
ylim = [15 465];
excludeXY = [];
t = [];
debug = false;
progressBar = true;
process_varargin(varargin);

disp(['Reading ' fn ' for head tracking.'])
t0 = clock;
vObj = VideoReader(fn);
nFrames = vObj.NumberOfFrames;
FrameRate = vObj.FrameRate;
dt = 1/FrameRate;
Height = vObj.Height;
Width = vObj.Width;
rez = [Width Height];
elapsed = etime(clock,t0);
disp(['Took ' num2str(elapsed) ' secs to load.'])
disp([fn ' is ' num2str(nFrames) ' frames of ' num2str(Width) 'x' num2str(Height) ' video at ' num2str(FrameRate) 'frames/sec.'])

phiB = linspace(-1,1,nOrientationsB+1)*pi;
phiB = phiB(2:end);
phiH = linspace(1/2,3/2,nOrientationsH)*pi;
% [phiBmat,thetaMat] = meshgrid(phiB,phiH);
% phiHmat = phiBmat+thetaMat;

MOVts = dt:dt:dt*nFrames;
MOVts = ts(MOVts(:));

disp(['Reading first ' num2str(nBLframes) ' baseline frames.'])

[BLframe,BLsd] = videoBLframe(vObj,nBLframes);
Head.BLframe = BLframe;
Head.BLsd = BLsd;

BLframe([1:ylim(1) ylim(2):end],:) = nan;
BLframe(:,[1:xlim(1) xlim(2):end]) = nan;
BLsd([1:ylim(1) ylim(2):end],:) = nan;
BLsd(:,[1:xlim(1) xlim(2):end]) = nan;

if ~isempty(excludeXY)
    for iRect = 1 : size(excludeXY,1)
        xLo = excludeXY(iRect,1);
        yLo = excludeXY(iRect,2);
        xHi = excludeXY(iRect,3);
        yHi = excludeXY(iRect,4);
        BLframe(yLo:yHi,xLo:xHi) = nan;
        BLsd(yLo:yHi,xLo:xHi) = nan;
    end
end

Head.BLlum.mean = nanmean(BLframe(:));
Head.BLlum.std = nanstd(BLframe(:));

BLframe = (BLframe - Head.BLlum.mean)/Head.BLlum.std;

imagesc(BLframe)
colormap bone
title(fn,'interpreter','none')
set(gca,'xlim',[0 720])
set(gca,'ylim',[0 480])
set(gca,'xtick',[])
set(gca,'ytick',[])
drawnow
% baseline frame.
clear frame frame0

frames = 1:nFrames;
MOVframes = tsd(MOVts(:),frames(:));
if ~isempty(t)
    disp('Excluding times...')
    timestamps = MOVts.data(t);
else
    timestamps = MOVts.data;
end

frameList = MOVframes.data(timestamps);
timeList = MOVts.data(timestamps);
doublets = find(diff(timeList)<=0);
frameList(doublets) = [];
timeList(doublets) = [];
nanTimes = isnan(timeList);
timeList(nanTimes) = [];
frameList(nanTimes) = [];
disp(['Processing ' num2str(length(frameList)) ' frames in file.'])

Hx = nan(length(frameList),1);
Hy = Hx;
xmin = xlim(1);
xmax = xlim(2);
ymin = ylim(1);
ymax = ylim(2);
onePercent = ceil(length(frameList)/100);
tenPercent = ceil(length(frameList)/10);

disp('Calculating indices of body/head circles to test...')
[tcB,tcH] = EZ_trackingTestCircles(rez,phiH,phiB,rh,rb);

disp('Tracking.')
t0 = clock;
for fr = 1:length(frameList)
    frGrab = frameList(fr);
    frame = double(rgb2gray(read(vObj,frGrab)));
    frame([1:ymin ymax:end],:) = nan;
    frame(:,[1:xmin xmax:end]) = nan;
    frame = (frame - nanmean(frame(:)))/nanstd(frame(:));
    
    D = (frame - BLframe);

    x = LED.x.data(timeList(fr));
    y = LED.y.data(timeList(fr));
    
    Bx = nan;
    By = nan;
    
    if debug
        subplot(2,2,1)
        cla
        hold on
        imagesc(frame);
        colormap bone
        plot(x,y,'wo')
        title(['Frame ' num2str(frGrab)])
        hold off
        set(gca,'xlim',[0 720])
        set(gca,'ylim',[0 480])
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        
        subplot(2,2,2)
        cla
        hold on
        imagesc(D);
        colormap bone
        caxis([-1.64 5])
        plot(x,y,'wo')
        title('ZFrame-ZBLframe')
        hold off
        set(gca,'xlim',[0 720])
        set(gca,'ylim',[0 480])
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        
        drawnow
    end
    inFrame = x>=xlim(1) & x<=xlim(2) & y>=ylim(1) & y<=ylim(2);
    onTrack = ~isnan(x)&&~isnan(y);
    if onTrack
        outFrame = isnan(BLframe(y,x));
    else
        outFrame = true;
    end
    if onTrack && inFrame && ~outFrame;
        I = D<=threshZ;
        if debug
            subplot(2,2,3)
            cla
            hold on
            imagesc(I);
            colormap bone
            plot(x,y,'wo')
            title(['Thresholded to ' num2str(threshZ)])
            hold off
            set(gca,'xlim',[0 720])
            set(gca,'ylim',[0 480])
            set(gca,'xtick',[])
            set(gca,'ytick',[])
        end

        [Hx(fr),Hy(fr),Bx,By] = trackRat(x,y,I,tcH,tcB,phiH,phiB,rb,rh,xlim,ylim);
        
        if debug
            subplot(2,2,4)
            cla
            hold on
            imagesc(frame)
            colormap bone
            caxis([-1.64 5])
            if maxD>threshLED
            	plot(x,y,'wo')
                plot(Hx(fr),Hy(fr),'gx')
                plot(Bx,By,'rx')
            end
            title('LED, body & head')
            hold off
            set(gca,'xlim',[0 720])
            set(gca,'ylim',[0 480])
            set(gca,'xtick',[])
            set(gca,'ytick',[])
            drawnow
        end
    end
    
    if progressBar
        if fr==1
            elapsed = etime(clock,t0);
            tPerIter = elapsed;
            remain = tPerIter*(length(frameList)-1);
            stopTime = datevec(datenum(clock+remain*[0 0 0 0 0 1]));
            fprintf('\n')
            fprintf('Each dot (1%%) is %.0f frames; %.0fs of movie time.\n', onePercent, onePercent/FrameRate)
            fprintf('Begun on %04.0f-%02.0f-%02.0f %02.0f:%02.0f:%02.0f.\n',t0)
            fprintf('Will complete in %.0fs, at %04.0f-%02.0f-%02.0f %02.0f:%02.0f:%02.0f\n',remain,stopTime);
            fprintf('***************************************************\n');
        end
        if mod(fr,onePercent)==0
            fprintf('.')
        end
        if mod(fr,tenPercent)==0
            elapsed = etime(clock,t0);
            tPerIter = elapsed/fr;
            remain = tPerIter*(length(frameList)-fr);
            fprintf('\n')
            fprintf('%.0f%% complete. %.0fs elapsed. %.0fs remain.',fr/length(frameList)*100,elapsed,remain)
            fprintf('\n')
            
            clf
            imagesc(D);caxis([-1.64 5]);
            colorbar;
            hold on
            plot(Hx(fr),Hy(fr),'gx')
            plot(Bx,By,'rx')
            plot(x,y,'wo')
            hold off
            set(gca,'xlim',[0 720])
            set(gca,'ylim',[0 480])
            set(gca,'xtick',[])
            set(gca,'ytick',[])
            title(fn,'interpreter','none')
            drawnow
        end
        if fr==length(frameList)
            fprintf('\nProcessed %.0f frames in %.0fs seconds.\n',length(frameList),etime(clock,t0));
        end
    end
end

Head.x = tsd(timeList,Hx);
Head.y = tsd(timeList,Hy);

function [BLframe,BLsd] = videoBLframe(vObj,nBLframes)
Height = vObj.Height;
Width = vObj.Width;
nBLframes = min(nBLframes,vObj.NumberOfFrames);

frame = nan(Height, Width, nBLframes);
for fr = 1 : nBLframes
    frame0 = read(vObj,fr);
    frame(:,:,fr) = rgb2gray(frame0);
end
BLframe = nanmean(frame,3);
BLsd = nanstd(BLframe,0,3);