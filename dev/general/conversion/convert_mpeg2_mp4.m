function convert_mpeg2_mp4(mpg,mp4)
% Converts an mpg to mp4 format.
% usage:
%
% convert_mpeg2_mp4(mpg,mp4)
%
% where     mpg is a string specifying the name of the mpg file to convert, and
%           mp4 is a string specifying the name of the mp4 file to be produced.
%
% requires Windows7 or OS X 10.7 or later for MP4.
% 
% Reads each frame of an mpeg video file specified in mpg using the MATLAB
% computer vision package (vision.VideoFileReader) and writes that frame to
% an mp4 using the MATLAB VideoWriter protocol.

if ~(exist(mp4,'file')==2)
    fprintf('\n Converting %s to %s\n',mpg,mp4)
    VFR = vision.VideoFileReader(mpg);

    Vout = VideoWriter(mp4,'MPEG-4');
    Vout.FrameRate = 30;
    open(Vout);
    k = 0;
    t0 = clock;
    fprintf('\n')
    while ~VFR.isDone
        videoFrame = step(VFR);
        writeVideo(Vout,videoFrame);

        k = k+1;

        if mod(k,30*60)==0
            fprintf('.')
        end
        if mod(k,30*60*10)==0
            t1 = clock;
            elapsed = etime(t1,t0);
            fprintf('\n')
            fprintf('10 minutes of video processed. Time elapsed: %.1f',elapsed)
            fprintf('\n')
        end
    end
    fprintf('\n')
    close(Vout);
    clear VFR
end