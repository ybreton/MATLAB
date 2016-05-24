function analyze_VT_movie(fn, varargin)
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
process_varargin(varargin)

idExt = regexpi(fn,'\.');
if isempty(idExt)
    idExt = length(fn)+1;
end
fnVid = fn;
fnSMI = [fn(1:idExt) 'smi'];

assert(exist(fnVid, 'file')==2, 'File not found.')
% assert(exist(fnSMI, 'file')==2, 'SAMI not found.')

try
    eval('!ffmpeg -version')
    ffmpeg = true;
catch
    disp('FFMPEG not installed or not in PATH.')
    ffmpeg = false;
end

try
    vidObj = VideoReader(fn);
    fn2 = fn;
    smi2 = fnSMI;
    converted = true;
catch exception
    conversionBegin = false;
    converted = false;
%     if strcmp(exception.identifier,'MATLAB:audiovideo:VideoReader:CodecNotFound') | strcmp(exception.identifier,'MATLAB:audiovideo:VideoReader:UnknownCodec')
        idCodec = regexp(exception.message,':');
        codec = exception.message(idCodec+1:end);
        idExt = max(regexp(fn,'\.'));
        fn2 = [fn(1:idExt-1) '_mpeg1.mpg'];
        if ffmpeg
            try
                conversionBegin = true;
                fprintf('\n Converting %s to %s\n', fn, fn2)
                eval(sprintf('!ffmpeg -i %s -c:v mpeg1video -c:a copy -y %s',fn,fn2))
%                 eval(sprintf('!"C:\\Program Files (x86)\\VideoLAN\\VLC\\vlc.exe" "%s" :sout=''#transcode{vcodec=mp2v,vb=4096,acodec=mp2a,ab=192,scale=1,channels=2,deinterlace,audio-sync}:std{access=file, mux=ps,dst="%s"}'' ',fn2,fn))
                converted = true;
            catch exception
                disp('Conversion failed.')
            end
        end
%     end
end
clear vidObj

if converted
    RatTrackData = RatTrack2(fn2,'frameRange',frameRange,'timeRange',timeRange,'useCores',useCores,'getOrientation',getOrientation);
    save([fnVid(1:idExt-1) '-RatTrackData.mat'],'RatTrackData')
else
    error('File format must first be converted from %s.',codec)
end

