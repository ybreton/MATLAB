 function sd = TaskInit(fd)
 
% sd = TaskInit(fd)
%
% Generic task initialization function
% checks and loads keys, video-tracker-1, and spikes
%
% ADR 2011-12

if nargin>0
    pushdir(fd);
else
    fd = pwd;
end

assert(exist(fd, 'dir')==7, 'Cannot find directory %s.', fd);

[~, SSN, ~] = fileparts(fd);

%-----------------------
% KEYS
%-----------------------
keysfn = [strrep(SSN, '-', '_') '_keys'];
assert(exist(keysfn, 'file')==2, 'Cannot find keys file %s.', keysfn);
eval(keysfn);
sd.ExpKeys = ExpKeys;
sd.ExpKeys.SSN = SSN;
sd.ExpKeys.fd = fd;

assert(~iscell(ExpKeys.Behavior), 'Multiple Behaviors');

%------------------------
% VIDEO TRACKING
%------------------------
W = warning();
warning off MATLAB:unknownObjectNowStruct
vtfn = fullfile(fd, [SSN '-vt.mat']);
assert(exist(vtfn, 'file')==2, 'Cannot find vt file %s.', vtfn);
if exist(vtfn, 'file')
	load(vtfn);
	if exist('Vt', 'var'), x = Vt.x; y = Vt.y; end
	if isstruct(x), x = tsd(x); end
	if isstruct(y), y = tsd(y); end
	if exist('phi', 'var') && isstruct(phi), phi = tsd(phi); end
	sd.x = x.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
	sd.y = y.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
else
	warning('FileNotFound: No VT file found.');
end
warning(W);

%-------------------------
% EVENTS
%-------------------------
eventsfn = fullfile(fd, [SSN '-events.Nev']);
%assert(exist(eventsfn, 'file')==2, 'Cannot find events file %s.', eventsfn);

%-------------------------
% SPIKES
%-------------------------
fc = FindFiles('*.t', 'CheckSubdirs', 0);
S = LoadSpikes(fc);
for iC = 1:length(S)
    S{iC} = S{iC}.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
end
sd.S = S;
sd.fc = fc;
for iC = 1:length(fc)
	[~, sd.fn{iC}] = fileparts(sd.fc{iC});
	sd.fn{iC} = strrep(sd.fn{iC}, '_', '-');
end

if nargin > 0
    popdir;
end

