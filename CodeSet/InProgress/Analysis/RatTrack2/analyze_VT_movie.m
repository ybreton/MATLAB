function [LEDxy, phiB, phiH] = analyze_VT_movie(fn, varargin)
% Analyze videotracking file, 
% Produce tsds of rat position, body angle, and head angle,
% Export report of rat tracking,
% Save .mat files of position, body angle, and head angle.
%
%
%

frameRange = [];
timeRange = [];
useCores = 1;
process_varargin(varargin)

assert(exist(fn, 'file')==2, 'File not found.')

try
    eval('!ffmpeg -version &')
    ffmpeg = true;
catch
    disp('FFMPEG not installed or not in PATH.')
    ffmpeg = false;
end

try
    vidObj = VideoReader(fn);
    fn2 = fn;
    converted = true;
catch exception
    if strcmp(exception.identifier,'MATLAB:audiovideo:VideoReader:CodecNotFound')
        idCodec = regexp(exception.message,':');
        codec = exception.message(idCodec+1:end);
        idExt = max(regexp(fn,'\.'));
        fn2 = [fn(1:idExt-1) '_mpeg1.mpg'];
        if ffmpeg
            try
                fprintf('\n Converting %s to %s\n', fn, fn2)
                eval(sprintf('!ffmpeg -i %s -vcodec mpeg1video -y %s &',fn,fn2))
                converted = true;
            catch
                disp('Conversion failed.')
            end
        end
    end
end
clear vidObj

if converted
    RatTrackDataOut = RatTrack2(fn2,'frameRange',frameRange,'timeRange',timeRange,'useCores',useCores);
    [LED0,phiB0,phiH0] = make_RatTrack_tsds(RatTrackDataOut,'produceRpt',true,'savedTsd',true);

    if nargout>0
        LEDxy = LED0;
        phiB = phiB0;
        phiH = phiH0;
    end
else
    error('File format must first be converted from %s.',codec)
end