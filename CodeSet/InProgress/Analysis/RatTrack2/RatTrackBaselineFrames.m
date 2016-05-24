function RatTrackBaselineFrames(mmStruct,nBaselineFrames)
% Prepares RatTrackData.meanFrame with average over first nBaselineFrames
% (default 10) of multimedia structure array prepared from vidObj2mmreaderStruct.
% RatTrackBaselineFrames(vidObj,nBaselineFrames)

if nargin<2
    nBaselineFrames = 10;
end

global RatTrackData

mmStructBaseline = addVidFrame(mmStruct,1:nBaselineFrames);
blFrames = zeros(mmStruct.height,mmStruct.width,3,nBaselineFrames);
for blFrame = 1 : nBaselineFrames
    blFrames(:,:,:,blFrame) = mmStructBaseline.frames(blFrame).cdata;
end
RatTrackData.meanFrame = uint8(mean(double(blFrames),4));