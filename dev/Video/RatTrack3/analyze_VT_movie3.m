function analyze_VT_movie3(fn, varargin)
% Analyze videotracking file, 
% Export report of rat tracking,
% Save .mat files of rat tracking.
%
%
%

frameRange = [];
timeRange = [];
useCores = 1;
getOrientation = true;
showProgress = false;
process_varargin(varargin);

[pathname,filename,ext] = fileparts(fn);
if ~isempty(pathname)
    pathname = [pathname '\'];
end
fnVid = [pathname filename ext];
fnSMI = [pathname filename '.smi'];

if strcmpi(ext,'.mpg')
    convert_mpeg2_mp4(fnVid,[pathname filename '.mp4'])
    fnVid = [pathname '\' filename '.mp4'];
end

vObj = VideoReader(fnVid);


assert(exist(fnVid, 'file')==2, 'File not found.')

    RatTrackData = RatTrack3(fnVid,'frameRange',frameRange,'timeRange',timeRange,'useCores',useCores,'getOrientation',getOrientation,'showProgress',showProgress);
    
    if exist(fnSMI,'file')==2
        movieTimes = RatTrackData.timestamp;
        frameNrs = RatTrackData.iFrame;
        movieTS = floor(frameNrs(:)*(1/30)*1000)/1000;
        [nlynxTS,syncTS] = get_smi_ts(fnSMI);
        nlynxTS = nlynxTS.range;
        syncTS = syncTS.range;
%         TS = interp1(syncTS,nlynxTS,movieTimes-min(movieTimes));
%         TS = nlynxTS(1:min(length(movieTS),length(syncTS)));
%         TS = TS(1:min(length(movieTS),length(syncTS)));
%         TS = unique(TS);
        TS = (movieTS-min(movieTS))+min(nlynxTS);
        RatTrackData.timestamp = TS;
        RatTrackData.movieTime = movieTimes;
        RatTrackData.frameTime = movieTS;
        RatTrackData.nlynx = nlynxTS;
        RatTrackData.sync = syncTS;
        offset = min(RatTrackData.movieTime)-min(RatTrackData.frameTime);
        RatTrackData.timestampOffset = TS+offset;
    else
        movieTimes = RatTrackData.timestamp;
        RatTrackData.movieTime = RatTrackData.timestamp;
        RatTrackData.timestamp = RatTrackData.timestamp;
        RatTrackData.movieTime = RatTrackData.timestamp;
        RatTrackData.frameTime = floor((1:length(movieTimes))'*(1/30)*1000)/1000;
        offset = min(RatTrackData.movieTime)-min(RatTrackData.frameTime);
        RatTrackData.timestampOffset = RatTrackData.movieTime+offset;
        RatTrackData.nlynx = nan;
        RatTrackData.sync = nan;
    end
    
    save([pathname filename '-RatTrackData.mat'],'RatTrackData','getOrientation')

%     T = RatTrackData.timestamp;
    T = RatTrackData.timestampOffset;
    x = RatTrackData.LEDx(:);
    y = RatTrackData.LEDy(:);
    id = 1:min(length(T),length(x));
    LEDx = tsd(T(id),x(id));
    id = 1:min(length(T),length(y));
    LEDy = tsd(T(id),y(id));
    LED = tsd(T(id),[x(id) y(id)]);
    phiB = tsd(T(id),RatTrackData.LEDphiB(id));
    phiH = tsd(T(id),RatTrackData.LEDphiH(id));
    
    save([pathname filename '-RatTrackData.mat'],'LEDx','LEDy','LED','phiB','phiH','-append')
    if getOrientation
        Hx = RatTrackData.Hx(:);
        id = 1:min(length(T),length(Hx));
        Hx = tsd(T(:),Hx(id));
        Hy = RatTrackData.Hy(:);
        id = 1:min(length(T),length(Hy));
        Hy = tsd(T(:),Hy(id));
        save([pathname filename '-RatTrackData.mat'],'Hx','Hy','-append')
    end
    if isfield(RatTrackData,'BadFrames')
        if ~isempty(RatTrackData.BadFrames)
            BadFrames = RatTrackData.BadFrames;
            save([pathname filename '-RatTrackData.mat'],'BadFrames','-append')
            fid=fopen([pathname filename '-badframes.txt'],'w');
            for iF = 1 : length(BadFrames)
                fprintf(fid,'%d\n',BadFrames(iF));
            end
            fclose(fid);
        end
    end