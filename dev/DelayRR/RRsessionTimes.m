function [Ton,Toff] = RRsessionTimes(nvt,varargin)
% Infer time on track and time off track.
% 
%
%

minTimeOnTrack = 1;
minRecGap = 10;
minSess = 50*60;
Ton = -inf;
Toff = inf;
process_varargin(varargin);

if isempty(Ton)
    Ton = -inf;
end
if isempty(Toff)
    Toff = inf;
end

[fd,fn,ext]=fileparts(nvt);

if strcmpi(ext,'.zip')
    filesPre = FindFiles('*.*','CheckSubdirs',false);
    disp(['Unzipping ' fn ext])
    unzip(nvt);
    filesPost = FindFiles('*.*','CheckSubdirs',false);
    toDelete = filesPost(~ismember(filesPost,filesPre));
    nvt2 = FindFiles('*.nvt','CheckSubdirs',false);
    
    [fd,fn,ext]=fileparts(nvt2{1});
    disp(['Loading ' fn ext])
    [x,y] = LoadVT_lumrg(nvt2{1});
    disp('Cleaning unzipped files...')
    for iD=1:length(toDelete)
        disp(['Removing ' toDelete{iD}])
        delete(toDelete{iD});
    end
else
    disp(['Loading ' fn ext])
    [x,y] = LoadVT_lumrg(nvt);
end

t = x.range;
d = x.data;

idOK = t>=Ton&t<=Toff;

tOK = t(idOK);
dOK = d(idOK);

tOnTrack = tOK(~isnan(dOK));
tMid = (nanmax(tOnTrack)-nanmin(tOnTrack))/2+nanmin(tOnTrack);

dt = [0; diff(tOK)];
gap = dt>minRecGap;
start = tOK<=tMid-minSess/2;

idON = find(gap&start,1,'last');

if isempty(idON)
    Ton = min(tOK);
else
    Ton = tOK(idON+1);
end

Ton = tOnTrack(find(tOnTrack>=Ton,1,'first'))-x.dt;
% The first time stamp where he's actually on track.

finish = tOK>=tMid+minSess/2;

idOFF = find(gap&finish,1,'first');

if isempty(idOFF)
    Toff = max(tOK);
else
    Toff = tOK(idOFF-1);
end

Toff = tOnTrack(find(tOnTrack<=Toff,1,'last'))+x.dt;
% The last time stamp where he's actually on track.