function RatTrackGetBaseline(data, width, height, frameNr, time)

% RatTrackGetBaseline
% based on
% processFrame(data,width,height,frameNr)
%
% This is the function prototype to be used by the matlabCommand option of
% mmread.
% INPUT
%   data        the raw captured frame data, the code below will put it
%               into a more usable form
%   width       the width of the image
%   height      the height of the image
%   frameNr     the frame # (counting starts at frame 1)
%   time        the time stamp of the frame (in seconds)
%

global RatTrackParms

global RatTrackData

%-------------
% prepare frame
f = RatTrackPrepareFrameFromVideo(data, width, height, frameNr, time);

%-------------
if frameNr == 1
	RatTrackData.meanFrame = double(f);
else
	RatTrackData.meanFrame = RatTrackData.meanFrame+double(f);
end

if frameNr == RatTrackParms.nBaselineFrames
	RatTrackData.meanFrame = uint8(RatTrackData.meanFrame/RatTrackParms.nBaselineFrames);
end
	