function VIDEOTRACKING = EZ_VIDEOTRACKER(fn,varargin)
%
%
%
%
global RatTrackParms

getOrientation = true;
inferLocation = false;
useCores = true;
nCores = 12;
brigtenFactor = 6;
threshold = 100;
debug = false;
nOrientationsB = 16;
nOrientationsH = 8;
process_varargin(varargin);
if useCores
    try
        evalin('base',sprintf('matlabpool open local %d',nCores))
    catch exception
        if ~isempty(regexp(exception.cause{1}.identifier,'distcomp:interactive:OpenConnection'))
            disp('matlabpool already open.')
        else
            disp('Cannot open matlabpool.')
        end
    end
end

[pathname,filename,ext] = fileparts(fn);
if ~isempty(pathname)
    pushdir(pathname);
else
    pathname = cd;
end

if ~isempty(regexpi(ext,'mpg'));
    mp4 = [pathname '\' filename '.mp4'];
    convert_mpeg2_mp4(fn,mp4);
    fn = mp4;
end
disp(['Reading ' fn ' ...']);
t1 = clock;
vObj = VideoReader(fn);
t2 = clock;
e = etime(t2,t1);
disp(['Video took ' num2str(e) ' sec to load.'])
% Each frame of the movie has time stamp MOVts.
MOVts = (1:vObj.NumberOfFrames).*(1./(vObj.FrameRate));
MOVts = MOVts(:);

NVTfn = FindFiles(['*.nvt'],'CheckSubdirs',0);
if isempty(NVTfn)
    FPT = FindFiles('FPT-tracking*.txt','CheckSubdirs',0);
    T = [];
    X = [];
    Y = [];
    for f = 1 : length(FPT)
        [x0,y0] = LoadFPT_tracking(FPT);
        t0 = x0.range;
        x0 = x0.data;
        y0 = y0.data;
        T = cat(1,T,t0);
        X = cat(1,X,x0);
        Y = cat(1,Y,y0);
    end
    if isempty(FPT)
        % Neither an NVT nor FPT-tracking file.
        T = nan(length(MOVts),1);
        X = nan(length(MOVts),1);
        Y = nan(length(MOVts),1);
        inferLocation = true;
    else
        [T,id] = sort(T);
        X = X(id);
        Y = Y(id);
        id = [true; diff(T)>0];
        T = T(id);
        X = X(id);
        Y = Y(id);
        x = tsd(T,X);
        y = tsd(T,Y);
    end
else
    T = [];
    X = [];
    Y = [];
    for f = 1 : length(NVTfn)
        [x0,y0] = LoadVT_lumrg(NVTfn{f});
        t0 = x0.range;
        x0 = x0.data;
        y0 = y0.data;
        T = cat(1,T,t0);
        X = cat(1,X,x0);
        Y = cat(1,Y,y0);
    end
    [T,id] = sort(T);
    X = X(id);
    Y = Y(id);
    id = [true; diff(T)>0];
    T = T(id);
    X = X(id);
    Y = Y(id);
    x = tsd(T,X);
    y = tsd(T,Y);
end

SMIfn = FindFiles([filename '.smi'],'CheckSubdirs',0);
if isempty(SMIfn)
    T = MOVts;
    
    LED.x.T = x.range;
    LED.x.D = x.data;
    LED.y.T = y.range;
    LED.y.D = y.data;
    idnan = false(length(T),1);
else
    [nlynxTS,syncTS]=get_smi_ts(SMIfn{1});
    nlynxTS = sort(nlynxTS.range);
    syncTS = sort(syncTS.range);
    idmax = max(length(nlynxTS),length(syncTS));
    nlynxTS = nlynxTS(1:idmax);
    syncTS = syncTS(1:idmax);
    include = all([diff(nlynxTS)>0 diff(syncTS)>0],2);
    id = [true; include];
    nlynxTS = nlynxTS(id);
    syncTS = syncTS(id);
    T = interp1(syncTS,nlynxTS,MOVts);
    idnan = isnan(T); 
    T = T(~idnan);
    % T contains the true time stamped value. We can now find the LED location.
    LED.x.T = T;
    LED.x.D = interp1(x.range,x.data,T);
    LED.y.T = T;
    LED.y.D = interp1(y.range,y.data,T);
end
frames = 1:length(MOVts);
firstFrame = min(frames(~idnan));
lastFrame = max(frames(~idnan));

Hx = nan(length(frames(~idnan)),1);
Hy = nan(length(frames(~idnan)),1);
frame = nan(vObj.Height, vObj.Width, 3, 10);
for fr = 1 : 10
    frame(:,:,:,fr) = read(vObj,fr);
end
meanFrame = nanmean(frame,4);

if getOrientation || inferLocation
    RatTrackParms.nOrientationsB = 16;
    RatTrackParms.nOrientationsH = 8;
    RatTrackParms.rB = 20;
    RatTrackParms.rH = 12;
    RatTrackParms.phiB = linspace(-1,1,nOrientationsB);
    RatTrackParms.phiH = linspace(1/2,3/2,nOrientationsH);
    [ThetaHmat,RatTrackParms.PhiBmat] = meshgrid(RatTrackParms.phiH,RatTrackParms.phiB);
    RatTrackParms.PhiHmat = RatTrackParms.PhiBmat+ThetaHmat;
    RatTrackParms.ratColor = 158;
    
    greyBL = rgb2gray(uint8(meanFrame));
    onePercent = ceil(0.01*vObj.NumberOfFrames);
    tenPercent = ceil(0.1*vObj.NumberOfFrames);
    fprintf('\nEach dot represents %d frames (%.1fs).\n',onePercent,onePercent*(1/vObj.FrameRate));
    t1 = clock;
    for fr = firstFrame : lastFrame
        frame = read(vObj,fr);
        greyscale = rgb2gray(frame);
%         LEDx = LED.x.D(fr);
%         LEDy = LED.y.D(fr);
        
%         LEDroi = roipoly(greyscale, LEDx + 15*cos(-pi:0.1:pi), LEDy + 15*sin(-pi:0.1:pi));
        thresh = (greyscale-greyBL)>=threshold;
        tImg = greyscale;
        tImg(~thresh) = 0;
        [maxThresh,LEDx] = max(max(tImg,[],1));
        [~,LEDy] = max(max(tImg,[],2));
        if maxThresh>0 && inferLocation
            LED.x.T(fr) = fr*(1/vObj.FrameRate);
            LED.y.T(fr) = fr*(1/vObj.FrameRate);
            LED.x.D(fr) = LEDx;
            LED.y.D(fr) = LEDy;
        end
        clear greyscale
        if maxThresh>0 && getOrientation
            g0 = rgb2gray(uint8(meanFrame)-frame)*brightenFactor;
%             rg0 = imadd(double(LEDroi)*100,g0);
%             clear g0 LEDroi
%             rg0 = rg0(yRange(1):yRange(2),xRange(1):xRange(2));

            [~, LEDphiH] = RatTrackTestEllipse_YB(g0, LEDx, LEDy);

            Hx(fr,1) = LEDx+25*cos(LEDphiH);
            Hy(fr,1) = LEDy+25*sin(LEDphiH);
        end
        if mod(fr,onePercent)==0
            fprintf('.')
        end
        if mod(fr,tenPercent)==0
            fprintf('\n')
            prct = (fr/vObj.NumberOfFrames)*100;
            t2 = clock;
            elapsed = etime(t2,t1);
            fprintf('%.0f%% complete. %.1fs elapsed.',prct,elapsed)
            fprintf('\n')
        end
    end
    id = isnan(LED.x.T)|isnan(LED.y.T);
    LED.x.T(id) = [];
    LED.x.D(id) = [];
    LED.y.T(id) = [];
    LED.y.D(id) = [];
    
end
VIDEOTRACKING.meanFrame = meanFrame;
VIDEOTRACKING.LED.x = tsd(LED.x.T,LED.x.D);
VIDEOTRACKING.LED.y = tsd(LED.y.T,LED.y.D);
VIDEOTRACKING.Head.x = tsd(T,Hx);
VIDEOTRACKING.Head.y = tsd(T,Hy);


if ~isempty(pathname)
    popdir;
end