function RatTrackRunFrames(mmStruct,frameRange)
% Processes RatTrackData in frames defined in frameRange, using video data
% included in multimedia structure array mmStruct produced by vidObj2mmreaderStruct.
% RatTrackRunFrames(mmStruct,frameRange)
%

if nargin<2
    nFrames = ceil(get(mmStruct.vidObj,'Duration')*ceil(get(mmStruct.vidObj,'FrameRate')))+1;
    frameRange = 1:nFrames;
end
fprintf('\n')
tenPercent = floor(length(frameRange)*0.1);
onePercent = floor(length(frameRange)*0.01);
t0 = clock;
nIter = 0;
for f = frameRange
    mmStructRat = addVidFrame(mmStruct,f);
    ProcessRatFrame(mmStructRat.frames, mmStructRat.width, mmStructRat.height, mmStructRat.frameList, mmStructRat.times)
    nIter = nIter+1;
    if nIter==1
        t1 = clock;
        elapsed=etime(t1,t0);
        remaining = elapsed*(length(frameRange)-nIter);
        fprintf('\nRat tracking %s\n',mmStruct.filename)
        fprintf('Approximately %.1fs remain.\n',remaining)
        fprintf('Estimated finish time\n(DD/MM/YYYY HH:MM:SS)\n')
        F = clock_end_time(t1,remaining);
        str = sprintf('%02d/',F([3 2]));
        str = [str sprintf('%04d',F(1))];
        str = [str ' ' sprintf('%02d:',F([4 5]))];
        str = [str sprintf('%02.0f',F(6))];
        fprintf(' %s\n',str)
    end
    if mod(nIter,onePercent)==0
        fprintf('.')
    end
    if mod(nIter,tenPercent)==0
        fprintf('\n')
        t1 = clock;
        elapsed=etime(t1,t0);
        tPer = elapsed/nIter;
        remaining = tPer*(length(frameRange)-nIter);
        fprintf('%.0f%% complete, %.1fs elapsed, %.1fs remain\n',nIter/length(frameRange)*100,elapsed,remaining)
        F = clock_end_time(t1,remaining);
        str = sprintf('%02d/',F([3 2]));
        str = [str sprintf('%04d',F(1))];
        str = [str ' ' sprintf('%02d:',F([4 5]))];
        str = [str sprintf('%02.0f',F(6))];
        fprintf('Endtime Approx %s\n',str)
        
    end
end