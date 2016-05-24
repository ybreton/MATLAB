function bool = CheckDirectoryForPromotion(fd)

% bool = DDinit(fd)
%
% Check directory for promotion
% checks keys, video-tracker-1, video-tracker-2, mat file, events file, and spikes
%
% ADR 2011-12

if nargin>0 
	pushdir(fd);
else
	fd = pwd;
end

%------------------------
% SSN structure
%------------------------
assert(exist(fd, 'dir')==7, 'Cannot find directory %s.', fd);

[~, SSN, ~] = fileparts(fd);
assert(SSN(1)=='R', 'SSN error');
assert(isfinite(str2double(SSN(2:4))), 'SSN error');
assert(SSN(5)=='-', 'SSN error');
yr=str2double(SSN(6:9)); assert(yr > 2000 && yr<2100, 'SSN error');
assert(SSN(10)=='-', 'SSN error');
mo=str2double(SSN(11:12)); assert(mo > 0 && mo<13, 'SSN error');
assert(SSN(13)=='-', 'SSN error');
day=str2double(SSN(14:15)); assert(day>0 && day<32, 'SSN error');

%-----------------------
% KEYS
%-----------------------
keysfn = [strrep(SSN, '-', '_') '_keys'];
assert(exist(keysfn, 'file')==2, 'Cannot find keys file %s.', keysfn);

%------------------------
% VIDEO TRACKING
%------------------------
% Video-tracker-1
vtfn1 = fullfile(fd, [SSN '-vt.mat']);
assert(exist(vtfn1, 'file')==2, 'Cannot find vt file %s.', vtfn1);
load(vtfn1);
assert(isstruct(x) || isa(x,'tsd'), 'VT: x is not a tsd.');
assert(isstruct(y) || isa(y, 'tsd'), 'VT: y is not a tsd.');

% Video-tracker-2
vtfn2 = fullfile(fd, [SSN '-vt2.mat']);
if (exist(vtfn2, 'file')==2)
load(vtfn2);
assert(isa(x,'tsd'), 'VT: x is not a tsd.');
assert(isa(y, 'tsd'), 'VT: y is not a tsd.');
end

%-------------------------
% EVENTS
%-------------------------
eventsfn = fullfile(fd, [SSN '-events.Nev']);
assert(exist(eventsfn, 'file')==2, 'Cannot find events file %s.', eventsfn);

%-------------------------
% SPIKES
%-------------------------
fc = FindFiles('*.t', 'CheckSubdirs', 0);
% wv and CluQual
for iC = 1:length(fc)
	[~,fn,~] = fileparts(fc{iC});
	wvfn = [fn '-wv.mat'];
	assert(exist(wvfn,'file')==2, 'Cannot find wv file %s.', wvfn);
	cluqualfn = [fn '-ClusterQual.mat'];
	assert(exist(cluqualfn, 'file')==2, 'Cannot find cluqual file %s.', cluqualfn);
end
S = LoadSpikes(fc);

if nargin > 0 
	popdir;
end
if nargout == 0
	disp('OK');
end

