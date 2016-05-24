function VidObj = LoadVidObj(filename,varargin)
% Loads a video object file
%
%
%

if nargin<1
    error('??? Undefined file name.')
end

ProgressBar = 'none';
startTime = [];
stopTime = [];
process_varargin(varargin);

nfo = mmfileinfo(filename);
mov = mmread(filename,[],[startTime,stopTime]);

% nFrames = length(mov;
Duration = get(mov,'Duration');
FrameRate = get(mov,'FrameRate');
FrameSize = [get(mov,'Width') get(mov,'Height')];

Path = get(mov,'Path');
Filename = get(mov,'Name');
idExt = regexp(filename,'\.');
Extension = Filename(idExt(end)+1:end);

VidObj = struct('Path',Path,'Filename',Filename,'Extension',Extension,...
    'Duration',Duration,'FrameRate',FrameRate,'FrameSize',FrameSize);
timestamps = (0:1/FrameRate:Duration)';
cdata = zeros([nFrames FrameSize 3],'uint8');

if strcmp(ProgressBar,'text')
    fprintf('\n')
end
for frame = 1 : nFrames
    rgbMat = read(mov,frame);
    % rgbMat is W x H x 3.
    cdata(frame,:,:,:) = reshape(rgbMat,[1 FrameSize 3]);
    if strcmp(ProgressBar,'text')
        fprintf('.')
        if mod(frame,100)==0
            fprintf('\n')
        end
    end
end

VidObj.tsd = tsd(timestamps,cdata);