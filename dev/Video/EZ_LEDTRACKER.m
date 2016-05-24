function LED = EZ_LEDTRACKER(fn,varargin)
% Returns head position from mp4 file fn.
% LED = EZ_LEDTRACKER(fn)
% where     LED        is a structure array with fields
%               .x
%               .y
%                       that are tsd's of the x,y positions of the LED or
%                       COM,
%               .BLlum.mean
%               .BLlum.std
%                       mean and sd of luminance throughout the baseline
%                       frame
%               .BLframe
%                       baseline frame, taken as mean luminance of each
%                       valid pixel across the first nBLframes frames.
%               .BLsd
%                       standard deviation of luminance values of each
%                       valid pixel across the first nBLframes frames.
%                       Large values may be indicative of video camera
%                       malfunctions and glitches.
%
%           fn          is a string specifying the file name
%
% Each frame pixel is Z-scored to the frame's overall luminance and SD, and
% that Z-scored pixel is then compared to the baseline (taken over the
% first nBLframes) Z-scored to the overall luminance of the baseline.
%
% Using the LED method, the LED is identified as the weighted centroid of
% the thresholded deviation of frame luminance (Z-scored to overall frame)
% from the baseline luminance (Z-scored to overall baseline). The LED is in
% frame when the maximum deviation of Z-scored frame luminance from
% Z-scored baseline luminance, is greater than threshLED (5). When this is
% true, the LED is at the centroid of the largest contiguous region for
% which the LED-driven luminance increase is larger than threshold.
%
% Using the Center-Of-Mass COM method, the COM is identified as the
% weighted centroid mass of the thresholded deviation of the Z-scored
% baseline luminance from the Z-scored frame's luminance. The COM is in
% frame when the deviation of the Z-scored baseline from the Z-score frame
% luminance, in units of pixel sd's during baseline, is greater than
% threshLED (1.64). When this is true, the COM is at the centroid of the
% largest contiguous region for which the rat-driven luminance decrease is
% larger than threshold. 
%
% OPTIONAL ARGUMENTS:
% ******************
% method            (default 'LED')     method to use to find rat center,
%                                           valid values are 'LED' and
%                                           'COM' for center of mass,
% nBLframes         (default 90)        number of baseline frames for
%                                           subtraction,
% threshLED         (default 5    if LED; 
%                            1.64 if COM)        
%                                       threshold Z score of deviation from
%                                           baseline frame for (bright)
%                                           LED, or (dark) COM
% xlim              (default [135 650]) limit of frame along x-axis;
%                                           excludes pixels outside of
%                                           frame,
% ylim              (default [15 465])  limit of frame along y-axis;
%                                           excludes pixels outside of
%                                           frame,
% excludeXY         (default [])        top left XY, bottom right XY list of
%                                           rectangles to exclude from
%                                           tracking. Default excludes
%                                           nothing. 
% t                 (default all)      list of time stamps to include in
%                                           video tracking, 
% debug             (default false)     produce debugging plots,
% progressBar       (default true)      display tracking progress.
%

nBLframes = 90;
xlim = [0 720];
ylim = [0 480];
excludeXY = [];
t = [];
debug = false;
progressBar = true;
method = 'LED';
process_varargin(varargin);
assert(strcmpi(method,'LED')||strcmpi(method,'COM'),'method must be either ''LED'' for LED-based tracking or ''COM'' for center-of-mass based tracking.')
if strcmpi(method,'LED')
    threshLED = 5;
else
    threshLED = 1.64;
end
process_varargin(varargin);

disp(['Reading ' fn ' for ' method ' tracking.'])
t0 = clock;
vObj = VideoReader(fn);
nFrames = vObj.NumberOfFrames;
FrameRate = vObj.FrameRate;
dt = 1/FrameRate;
Height = vObj.Height;
Width = vObj.Width;
elapsed = etime(clock,t0);
disp(['Took ' num2str(elapsed) ' secs to load.'])
disp([fn ' is ' num2str(nFrames) ' frames of ' num2str(Width) 'x' num2str(Height) ' video at ' num2str(FrameRate) 'frames/sec.'])

MOVts = dt:dt:dt*nFrames;
MOVts = ts(MOVts(:));

disp(['Reading first ' num2str(nBLframes) ' baseline frames.'])

[BLframe,BLsd] = videoBLframe(vObj,nBLframes);
LED.BLframe = BLframe;
LED.BLsd = BLsd;

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

LED.BLlum.mean = nanmean(BLframe(:));
LED.BLlum.std = nanstd(BLframe(:));

BLframe = (BLframe - LED.BLlum.mean)/(eps+LED.BLlum.std);

if debug
    subplot(2,2,3)
    imagesc(BLframe)
    colormap bone
    title(fn,'interpreter','none')
    set(gca,'xlim',[0 720])
    set(gca,'ylim',[0 480])
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    drawnow
end
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

Lx = nan(length(frameList),1);
Ly = Lx;

xmin = xlim(1);
xmax = xlim(2);
ymin = ylim(1);
ymax = ylim(2);
onePercent = ceil(length(frameList)/100);
tenPercent = ceil(length(frameList)/10);

disp('Tracking.')
t0 = clock;

for fr = 1:length(frameList)
    frGrab = frameList(fr);
    frame = double(rgb2gray(read(vObj,frGrab)));
    frame([1:ymin ymax:end],:) = nan;
    frame(:,[1:xmin xmax:end]) = nan;
    frame = (frame - nanmean(frame(:)))/nanstd(frame(:));
    
    if strcmpi(method,'LED')
        D = (frame - BLframe);
    elseif strcmpi(method,'COM')
        D = (BLframe - frame);
    end
    maxD = max(D(:));
        
    if debug
        subplot(2,2,1)
        cla
        hold on
        imagesc(frame);
        axis xy
        colormap bone
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
        axis xy
        colormap bone
        caxis([-1.64 5])
        title('ZFrame-ZBLframe')
        hold off
        set(gca,'xlim',[0 720])
        set(gca,'ylim',[0 480])
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        
        drawnow
    end
    
    if maxD>threshLED
        I = D>threshLED;
        labeledImage = bwconncomp(I);
        measurements = regionprops(labeledImage, D, 'Area', 'WeightedCentroid');
        A = arrayfun(@(x) x.Area, measurements);
        [~,idSort] = sort(A,'descend');
        measurements = measurements(idSort);
        centerOfMass = measurements(1).WeightedCentroid;
        x = centerOfMass(1);
        y = centerOfMass(2);
        
        if debug
            subplot(2,2,1)
            hold on
            plot(x,y,'go')
            hold off
            subplot(2,2,2)
            hold on
            plot(x,y,'go')
            hold off
            
            subplot(2,2,4)
            cla
            hold on
            imagesc(I);
            axis xy
            colormap bone
            plot(x,y,'go')
            title(['Thresholded to ' num2str(threshLED)])
            hold off
            set(gca,'xlim',[0 720])
            set(gca,'ylim',[0 480])
            set(gca,'xtick',[])
            set(gca,'ytick',[])
        
            drawnow
        end
        
        inFrame = x>=xlim(1) & x<=xlim(2) & y>=ylim(1) & y<=ylim(2);
        
        if inFrame
            Lx(fr) = x;
            Ly(fr) = y;
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
        end
        if fr==length(frameList)
            fprintf('\nProcessed %.0f frames in %.0fs seconds.\n',length(frameList),etime(clock,t0));
        end
    end
end

LED.x = tsd(timeList,Lx);
LED.y = tsd(timeList,Ly);


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