function [BadFrames,idRemove] = CheckBadFrames(vidObj)

tenPercent = ceil((vidObj.NumberOfFrames)/10);
fprintf('\n Checking for bad frames... \n')
t0 = clock;
D = zeros(1,vidObj.NumberOfFrames);
for frame = 2 : vidObj.NumberOfFrames
    f3d1 = read(vidObj,frame-1);
    f2d1 = rgb2gray(f3d1)*255;
    f3d2 = read(vidObj,frame);
    f2d2 = rgb2gray(f3d2)*255;
    
    df = double(f2d2(:)-f2d1(:))'*double(f2d2(:)-f2d1(:));
    D(frame) = sqrt(mean(df));
end

frameList = 1:vidObj.NumberOfFrames;
idRemove = D>=10;
BadFrames = frameList(idRemove);


if D>=10;
%     fprintf('\nBad frame issue at frame %d; RMS-255 grayscale difference from last frame is %.1f>=10\n',frameNr,D)
    BadFrames = [RatTrackData.BadFrames; frameNr];
end