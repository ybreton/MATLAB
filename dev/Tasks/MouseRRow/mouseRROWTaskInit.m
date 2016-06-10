 function sd = mouseRROWTaskInit(varargin)
 
% sd = TaskInit(fd)
%
% Generic task initialization function
% checks and loads keys, video-tracker-1, and spikes
%
% ADR 2011-12

fd = pwd;
if nargin==1
    fd = varargin{1};
end
process_varargin(varargin);

if nargin==0
    fd = pwd;
end

assert(exist(fd, 'dir')==7, 'Cannot find directory %s.', fd);

[~, SSN, ~] = fileparts(fd);

%------------------------
% events
%------------------------
taskEventsfn = fullfile(fd, [SSN '-taskEvents.mat']);
assert(exist(taskEventsfn, 'file')==2, 'Cannot find events file %s.', taskEventsfn);
events = load(taskEventsfn);
sd = events.taskEvents;
sd.EnteringZoneTime = sd.OfferTimeStamp;
idEnter = ~isnan(sd.EnterTimeStamp);
idEarn = ~isnan(sd.EarnTimeStamp);
idQuit = ~isnan(sd.QuitTimeStamp);
idSkip = ~isnan(sd.SkipTimeStamp);

sd.ExitZoneTime = nan(length(sd.EnteringZoneTime),1);
sd.ExitZoneTime(idEarn) = sd.EarnTimeStamp(idEarn);
sd.ExitZoneTime(idQuit) = sd.QuitTimeStamp(idQuit);
sd.ExitZoneTime(idSkip) = sd.SkipTimeStamp(idSkip);

sd.EnteringCPTime = sd.EnteringZoneTime;
sd.ExitingCPTime = nan(length(sd.EnteringZoneTime),1);
sd.ExitingCPTime(idSkip) = sd.SkipTimeStamp(idSkip);
sd.ExitingCPTime(idEnter) = sd.EnterTimeStamp(idEnter);

sd.earned = idEarn;
sd.quit = idQuit;
sd.skipped = idSkip;
sd.entered = idEnter;

%-----------------------
% KEYS
%-----------------------
fn = strrep(SSN,'-','_');
keysfn = fullfile(fd, [fn,'_keys.m']);
assert(exist(keysfn, 'file')==2, 'Cannot find keys file %s.', keysfn);
[~,fn] = fileparts(keysfn);
eval(fn);
%load(keysfn);
sd.ExpKeys = ExpKeys;

%-------------------------
% Add RedishLab fields
%-------------------------
sd.ZoneDelay = sd.Offer;
sd.ZoneIn = sd.Flavor;
idOK = ~isnan(sd.ZoneIn);
sd.nPellets = nan(length(sd.ZoneIn),1);
sd.nPellets(idOK) = sd.ExpKeys.PelletNumber(sd.ZoneIn(idOK));
sd.pelletsDelivered = sd.nPellets .* double(sd.earned);

%-------------------------
% Calculate thresholds
%------------------------
% sd.Thresholds = RROW_FindThresholds(taskEvents);
% sd.OfferValue = nan(size(sd.taskEvents.Offer));
% for iF = 1:4
%     isFlavor = sd.taskEvents.Flavors==iF;
%     sd.OfferValue(isFlavor) = sd.taskEvents.Offer(isFlavor) - sd.Thresholds(iF);
% end    

%-------------------------
% VT
%-------------------------
vtfn = fullfile(fd, [SSN '-vt.mat']);
assert(exist(vtfn, 'file')==2, 'Cannot find events file %s.', vtfn);
load(vtfn);
sd.x = x;
sd.y = y;
[sd.x,sd.y] = CleanAnyMazeXY(sd.x, sd.y);


