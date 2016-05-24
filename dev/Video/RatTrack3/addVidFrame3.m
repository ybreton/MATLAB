function mmStruct_out = addVidFrame3(mmStruct_in,frameList)
% adds frames of video to mmStruct_in.
% mmStruct_out = addVidFrame(mmStruct_in,frameList)
% where     mmStruct_in is produced from vidObj2mmreaderStruct, and
%           frameList provides the list of frames to add.
%           (default/empty frameList is entire video file.)
%

Rate = 30;
timebase = 1/Rate;

if nargin < 2 || isempty(frameList)
    frameList = 1 : mmStruct.nrFramesTotal;
end

H = mmStruct_in.height;
W = mmStruct_in.width;
Fin = length(mmStruct_in.frames);

% Are you trying to add something that's already there?
includedFrames = mmStruct_in.frameList;
includedFrames = repmat(includedFrames(:),1,length(frameList));
addedFrames = repmat(frameList(:)',size(includedFrames,1),1);
idMatch = includedFrames == addedFrames;
idDuplicate = any(idMatch,1);
frameList(idDuplicate) = [];
clear includedFrames addedFrames idMatch idDuplicate % cleanup garbage.

F = length(frameList);
T = floor(timebase*(frameList-1)*1000)/1000;
% rounded in milliseconds.

frames(1:length(frameList)) = struct('cdata',uint8(zeros(H,W,3)),'colormap',[]);
timestamps = nan(length(frameList),1);
videoTimes = nan(length(frameList),1);
for f = 1 : F
    try
        vidObj = mmStruct_in.vidObj;
        frames(f).cdata = (vidObj.getFrameAtNum(frameList(f)));
        videoTimes(f) = mmStruct_in.vidObj.getTime;
        timestamps(f) = T(f);
    catch exception
        disp(exception.message)
    end
end

mmStruct_out = mmStruct_in;

mmStruct_out.frameList = [mmStruct_in.frameList frameList];
if ~isempty(mmStruct_in.frames(1).cdata)
    mmStruct_out.frames(Fin+1:Fin+F) = frames;
else
    mmStruct_out.frames(1:F) = frames;
end
mmStruct_out.times = timestamps;
mmStruct_out.videoTimes = videoTimes;
PossibleFrames = min(mmStruct_out.frameList):max(mmStruct_out.frameList);
allPossibleFrames = repmat(PossibleFrames(:),1,length(mmStruct_out.frameList));
allIncludedFrames = repmat(mmStruct_out.frameList,size(allPossibleFrames,1),1);
idMatch = allPossibleFrames == allIncludedFrames;
idSkip = all(~idMatch,2);
mmStruct_out.skippedFrames = PossibleFrames(idSkip);
clear PossibleFrames allPossibleFrames allIncludedFrames idMatch idSkip % cleanup garbage

% Sort output into chronological order.
[mmStruct_out.frameList,idSort] = sort(mmStruct_out.frameList);
mmStruct_out.frames = mmStruct_out.frames(idSort);
mmStruct_out.times = mmStruct_out.times(idSort);
