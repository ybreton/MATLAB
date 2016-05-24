function RatTrack(fn, varargin)

% RatTrack

% RatTrack(fn)
% varargin
%    nBaselineFrames = 10;
%    frameRange = []; % list of frames to grab
%    timeRange = 4*60+[35 40]; % start and stop times    
%    threshold = 50;
%
% uses frameRange first, then timeRange, use frameRange=[], timeRange=[]
% for all frames
%
% ADR 2011/Aug
% based on the mmread protocol

nBaselineFrames = 10;
frameRange = []; % list of frames to grab
timeRange = []; % start and stop times
threshold = 50;
samplingRate = 30;
brightenFactor = 6;
ratColor = 158;
getOrientation = true;
debug = false;
extract_varargin;

disableVideo = false;
disableAudio = true;
trySeeking = false;
useFFGRAB = false;

% frameRange first else timeRange
if ~isempty(frameRange), timeRange = []; end

% gobal parameters
global RatTrackParms
RatTrackParms.debug = debug;
RatTrackParms.getOrientation = getOrientation;
RatTrackParms.nBaselineFrames = nBaselineFrames;
RatTrackParms.threshold = threshold;
RatTrackParms.brightenFactor = brightenFactor;
RatTrackParms.ratColor = ratColor;

global RatTrackData
RatTrackData.fn = fn;
RatTrackData.meanFrame = [];

if ~isempty(frameRange)
	nFrames = length(frameRange)+1;
elseif ~isempty(timeRange)
	nFrames = diff(timeRange)*samplingRate+1;
else
	v0 = mmread(fn, 1:10, [], disableVideo, disableAudio, '', trySeeking, useFFGRAB);
	nFrames = ceil(v0.totalDuration*samplingRate)+1;
end

% step 1: get mean baseline
disp('Processing mean baseline from first frames...');
mmread(fn, 1:nBaselineFrames, [], disableVideo, disableAudio, 'RatTrackGetBaseline', trySeeking, useFFGRAB);

% step 2: process each frame
disp('Processing frames...');
RatTrackData.currentFrameCount = 1;
RatTrackData.iFrame = nan(nFrames,1);
RatTrackData.timestamp = nan(nFrames,1);
RatTrackData.LEDx = nan(nFrames,1);
RatTrackData.LEDy = nan(nFrames,1);
RatTrackData.LEDphi = nan(nFrames,1);

mmread(fn, frameRange, timeRange, disableVideo, disableAudio, 'ProcessRatFrame', trySeeking, useFFGRAB);
	
	