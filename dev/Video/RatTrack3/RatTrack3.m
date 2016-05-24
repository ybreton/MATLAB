function [RatTrackDataOut] = RatTrack3(fn, varargin)

% RatTrack

% RatTrack(fn)
% varargin
%    nBaselineFrames = 10;
%    frameRange = []; % list of frames to grab
%    timeRange = 4*60+[35 40]; % start and stop times    
%    threshold = 50;
%    useCores = 1; % number of slaves in MATLAB pool
%    nOrientationsB = 16; % number of body orientations,
%    nOrientationsH = 8; % number of head orientations
%
% uses frameRange first, then timeRange, use frameRange=[], timeRange=[]
% for all frames
%
% ADR 2011/Aug
% YAB 2012/Nov
% based on the VideoReader protocol

nBaselineFrames = 10;
frameRange = []; % list of frames to grab
timeRange = []; % start and stop times
threshold = 50;
samplingRate = 30;
brightenFactor = 6;
ratColor = 158;
getOrientation = true;
debug = false;
useCores = true;
nCores = 12;
nOrientationsB = 16;
nOrientationsH = 8;
showProgress = false;
evalin('base','matlabpool close')
process_varargin(varargin);
if useCores
    evalin('base',sprintf('matlabpool open %d',nCores))
end

disableVideo = false;
disableAudio = true;
trySeeking = false;
useFFGRAB = true;

% frameRange first else timeRange
if ~isempty(frameRange), timeRange = []; end

% global parameters
global RatTrackParms
RatTrackParms.debug = debug;
RatTrackParms.showProg = showProgress;
RatTrackParms.getOrientation = getOrientation;
RatTrackParms.nBaselineFrames = nBaselineFrames;
RatTrackParms.threshold = threshold;
RatTrackParms.brightenFactor = brightenFactor;
RatTrackParms.ratColor = ratColor;

% Do this just once rather than for each video frame.
RatTrackParms.nOrientationsB = nOrientationsB;
RatTrackParms.nOrientationsH = nOrientationsH;
RatTrackParms.rB = 20;
RatTrackParms.rH = 12;

RatTrackParms.phiB = linspace(-1,1,nOrientationsB);
RatTrackParms.phiH = linspace(1/2,3/2,nOrientationsH);
% In units of pi.

[ThetaHmat,RatTrackParms.PhiBmat] = meshgrid(RatTrackParms.phiH,RatTrackParms.phiB);
% PhiBmat is a matrix of body-phi values (in units of pi)
% ThetaHmat is a matrix of head-angle values (in units of pi)
RatTrackParms.PhiHmat = RatTrackParms.PhiBmat+ThetaHmat;
% PhiHmat is a matrix of head-phi values, summing body-phi and head-angle
% (in units of pi)


global RatTrackData
RatTrackData.fn = fn;
RatTrackData.meanFrame = [];

assert(exist(fn, 'file')==2, 'File not found.')

if isempty(regexp(fn,'/','once'))&isempty(regexp(fn,'\','once'))
    d = cd;
    if isempty(regexp(d,'\','once')) % mac/UNIX
        fnFull = sprintf('%s/%s',d,fn);
    end
    if isempty(regexp(d,'/','once')) % windows/DOS
        fnFull = sprintf('%s\\%s',d,fn);
    end
else
    fnFull = fn;
end
vidObj = VideoReader(fnFull);
RatTrackData.FullFilename = fnFull;

lastFrame = vidObj.NumberOfFrames;
nFrames = vidObj.NumberOfFrames;
% if isinf(lastFrame)
%     lastFrame = ceil(get(vidObj,'Duration')*ceil(get(vidObj,'FrameRate')))+1;
% end
% if ~isempty(frameRange)
%     nFrames = length(frameRange);
% elseif ~isempty(timeRange)
%     startFrame = floor(min(timeRange)*ceil(get(vidObj,'FrameRate')));
%     endFrame = ceil(max(timeRange)*ceil(get(vidObj,'FrameRate')));
%     nFrames = endFrame - startFrame + 1;
%     frameRange = startFrame:endFrame;
% else
%     nFrames = lastFrame+1;
%     frameRange = 1:nFrames-1;
% end
% No matter what the user puts in, make sure the frame range to analyze is
% within the bounds of the movie.
% frameRange = max(min(frameRange,ones(size(frameRange))*lastFrame),ones(size(frameRange)));
% frameRange = unique(frameRange);
frameRange = 1:lastFrame;

% step 1: get mean baseline
fprintf('\nProcessing mean baseline from first %d frames...\n',nBaselineFrames);
% mmread(fn, 1:nBaselineFrames, [], disableVideo, disableAudio, 'RatTrackGetBaseline', trySeeking, useFFGRAB);
% mmStruct = vpObj2mmreaderStruct(vidObj);
mmStruct.filename = vidObj.Name;
mmStruct.vidObj = vidObj;
mmStruct.width = vidObj.Width;
mmStruct.height = vidObj.Height;
mmStruct.frames = struct('cdata',[],'colormap',[]); % update as video is read.
mmStruct.nrFramesTotal = vidObj.NumberOfFrames;
mmStruct.rate = vidObj.FrameRate;
mmStruct.totalDuration = vidObj.NumberOfFrames*1./(vidObj.FrameRate);
mmStruct.times = []; % update as video is read.
mmStruct.videoTimes = []; % update as video is read.
mmStruct.skippedFrames = []; % update as video is read.
mmStruct.frameList = []; % update as video is read.

RatTrackBaselineFrames3(mmStruct,nBaselineFrames)
RatTrackData.lastFrame = RatTrackData.meanFrame;
clear vidObj;
%vidObj = VideoPlayer(fnFull);
vidObj = VideoReader(fnFull);

%mmStruct = vpObj2mmreaderStruct(vidObj);
mmStruct.filename = vidObj.Name;
mmStruct.vidObj = vidObj;
mmStruct.width = vidObj.Width;
mmStruct.height = vidObj.Height;
mmStruct.frames = struct('cdata',[],'colormap',[]); % update as video is read.
mmStruct.nrFramesTotal = vidObj.NumberOfFrames;
mmStruct.rate = vidObj.FrameRate;
mmStruct.totalDuration = vidObj.NumberOfFrames*1./(vidObj.FrameRate);
mmStruct.times = []; % update as video is read.
mmStruct.videoTimes = []; % update as video is read.
mmStruct.skippedFrames = []; % update as video is read.
mmStruct.frameList = []; % update as video is read.

% step 2: process each frame
disp('Processing frames...');
RatTrackData.BadFrames = [];
RatTrackData.currentFrameCount = 1;
RatTrackData.iFrame = nan(nFrames-1,1);
RatTrackData.timestamp = nan(nFrames-1,1);
RatTrackData.LEDx = nan(nFrames-1,1);
RatTrackData.LEDy = nan(nFrames-1,1);
RatTrackData.LEDphiB = nan(nFrames-1,1);
RatTrackData.LEDphiH = nan(nFrames-1,1);
RatTrackData.Hx = nan(nFrames-1,1);
RatTrackData.Hy = nan(nFrames-1,1);

% mmread(fn, frameRange, timeRange, disableVideo, disableAudio, 'ProcessRatFrame', trySeeking, useFFGRAB);
RatTrackRunFrames3(mmStruct,frameRange)
clear vidObj
% % step 3: identify when the rat's positioning LED is visible.
% RatVisibility

% step 4, still to do: add a history.
% RatTrackData.History = ...

if nargout > 0
    RatTrackDataOut = RatTrackData;
    clear global 
    clear RatTrackData
end
clear global
clear RatTrackData
clear RatTrackParms

if useCores>1
    evalin('base','matlabpool close')
end