function mmStruct = vidObj2mmreaderStruct(vidObj)
% Produces a multimedia structure array based on a VideoReader object with
% UserData set to the video's full path and file name.
% mmStruct = vidObj2mmreaderStruct(vidObj)
% where     mmStruct is a structure array with fields
%           .filename, the full path and file name of the multimedia object,
%           .vidObj, the VideoReader object that points to the file in .filename,
%           .width, the number of pixels along X,
%           .height, the number of pixels along Y,
%           .frames, a structure array of added frames in chronological order with fields
%               .cdata, a 3D (H x W x RGB) double array of each video frame,
%               .colormap,
%           .nrFramesTotal, the total number of frames in the video,
%           .rate, the frame rate in frames/sec
%           .totalDuration, the total duration of the video,
%           .times, the time stamps of the frames in .frames,
%           .skippedFrames, frames skipped in a non-sequential .frames structure
%           .frameList, the frames included in the .frames structure, and
%           vidObj is an object produced by VideoReader with UserData set to the file name of the multimedia file.
%


% mmread produces video struct with fields
% .width
% .height
% .nrFramesTotal
% .frames
% .rate
% .totalDuration
% .times
% .skippedFrames

% VideoReader produces object with properties
% .BitsPerPixel
% .Duration
% .FrameRate
% .Height
% .Name
% .NumberOfFrames
% .Path
% .Tag {User-defined}
% .Type
% .UserData {User-defined}
% .VideoFormat
% .Width
% 
% and has methods
% get, getFileFormats, isPlatformSupported, read, set

mmStruct.filename = get(vidObj,'UserData');
mmStruct.vidObj = vidObj;
mmStruct.width = get(vidObj,'Width');
mmStruct.height = get(vidObj,'Height');
mmStruct.frames = struct('cdata',[],'colormap',[]); % update as video is read.
mmStruct.nrFramesTotal = get(vidObj,'FrameRate')*get(vidObj,'Duration');
mmStruct.rate = get(vidObj,'FrameRate');
mmStruct.totalDuration = get(vidObj,'Duration');
mmStruct.times = []; % update as video is read.
mmStruct.skippedFrames = []; % update as video is read.
mmStruct.frameList = []; % update as video is read.