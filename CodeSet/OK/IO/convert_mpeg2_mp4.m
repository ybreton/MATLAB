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
% an mp4 using the MATLAB VideoWriter protocol. Provides the user with
% progress in the command window by adding a dot every 1% of the number of
% frames as estimated by VideoFileReader and informs the user of the time
% remaining for conversion every 10% of the number of frames.
%

VFR = vision.VideoFileReader(mpg);
try
    VP = VideoPlayer(mpg);
    NumFrames = VP.NumFrames;
    clear VP
catch
    NumFrames = inf;
end
Vout = VideoWriter(mp4,'MPEG-4');
Vout.FrameRate = 30;
open(Vout);
k = 0;
onePercent = round(NumFrames*0.01);
tenPercent = round(NumFrames*0.10);
t0 = clock;
fprintf('\n')
while ~VFR.isDone
    videoFrame = step(VFR);
    writeVideo(Vout,videoFrame);
    k = k+1;
    if mod(k,onePercent)==0
        fprintf('.')
    end
    if mod(k,tenPercent)==0
        fprintf('\n')
        t1 = clock;
        elapsed = etime(t1,t0);
        tPer = elapsed/k;
        remaining = tPer*(NumFrames-k);
        fprintf('%d%% complete, %.1fs remain for conversion.',k/tenPercent*10,remaining)
        fprintf('\n')
    end
end
fprintf('\n')
close(Vout);
clear VFR