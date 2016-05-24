function offset = FPTfindMOVtsOffset(fn,x,y,t,varargin)
% There is an offset between timestamps recorded in MATLAB and the movie's
% internal time stamp (frameNumber/frameRate).
% offset = FPTfindMOVtsOffset(fn,x)
% where         offset      is the offset in seconds calculated as
%                               T(first LED appearance) - t
%
%               fn          filename of mp4
%               x,y,t       known x,y position at time t.
%
% first LED appearance is obtained from by taking the deviation of luminance
% of each pixel in frame against the mean of the first nBLframes
% (default 30), and determining the maximum deviation pixel. If that maximum
% is above threshLED (default 100), the program assumes it has found the
% LED.
%
%

nBLframes = 30;
threshLED = 100;
xlim = [135 595];
ylim = [15 415];
process_varargin(varargin);

disp(['Reading ' fn ' for offset information...'])
vObj = VideoReader(fn);
nFrames = get(vObj,'NumberOfFrames');
dt = 1/get(vObj,'FrameRate');
Height = get(vObj,'Height');
Width = get(vObj,'Width');
T = dt:dt:dt*nFrames;

disp(['Reading first ' num2str(nBLframes) ' baseline frames.'])
frame = nan(Height, Width, nBLframes);
for fr = 1 : nBLframes
    frame0 = read(vObj,fr);
    frame(:,:,fr) = rgb2gray(frame0);
end
BLframe = nanmean(frame,3);
BLsd = nanstd(frame,0,3);
imagesc(BLframe)
BLframe = BLframe - nanmean(BLframe(:));
title(fn,'interpreter','none')
set(gca,'xlim',[0 720])
set(gca,'ylim',[0 480])
set(gca,'xtick',[])
set(gca,'ytick',[])
drawnow

notFound = true;
frame = nBLframes;
X = nan(nFrames,1);
Y = nan(nFrames,1);
Dist = nan(nFrames,1);
while notFound && frame < nFrames
    frame = frame+1;
    F = double(rgb2gray(read(vObj,frame)));
    F = F-nanmean(F(:));
    D = (F - BLframe);
    Z = D./(BLsd+eps);
    [Dmax,LEDx] = max(max(D,[],1),[],2);
    [~,LEDy] = max(max(D,[],2),[],1);
    X(frame) = LEDx;
    Y(frame) = LEDy;
    if Dmax>threshLED & LEDx>xlim(1) & LEDx<xlim(2) & LEDy>ylim(1) & LEDy<ylim(2)
        Dist(frame) = sqrt((x-LEDx).^2+(y-LEDy).^2);
    end
    imagesc(F)
    hold on
    plot(x,y,'w.')
    hold off
    drawnow
end

offset = T(frame) - t;