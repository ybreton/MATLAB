function sd = DDinit(fd, varargin)
% sd = DDinit;
% sd = DDinit(pwd);
% sd = DDinit(pwd,'Keys',1,'VT1',0,'VT2',0,'Spikes',0);
%
% DelayDiscounting (DD) task initialization function
% checks and loads keys, video-tracker-1, video-tracker-2, mat file, events file, and spikes
%

%
% ADR 2011-12
% 2012-03-17 AndyP     Added a date flag for FixFeedersFired
% 2012-05    AndyP     Added zone coordinates
% 2012-06-16 AndyP     fixed 'exist' statements
% 2012-06-20 AndyP     fixed extra sd.FeedersFired call
% 2012-07-25 AndyP     function call to FixFeedersFired changed to
% DD6_FixFeedersFired, DDGetWorld changed to DD_getWorld
% 2013-03-04 AndyP sd.fn, sd.fc, and sd.S are all now the same length.  Previously, if a cell had been removed because it didn't have any spikes,the entry in fn and fc was not removed.



Keys = true; %1 = load keys.m, 0 = don't
VT1 = true;  %1 = load VT1, 0 = don't
VT2 = true;  %1 = load VT2, 0 = don't
Spikes = true;  %1 = load spikes, 0 = don't
DD  = true;  %1 = load *DD.mat, 0 = don't
Use__Ts = false; % load ._t cells
Events = false; % load events file
if mod(length(varargin),2)~=0;
	varargin{end+1}=nan;
end

process_varargin(varargin);

if nargin>0 && ~isempty(fd)
	pushdir(fd);
	dirpushed = true;
else
	fd = pwd;
	dirpushed = false;
end

assert(exist(fd, 'dir')==7, 'Cannot find directory %s.', fd);

[~, SSN, ~] = fileparts(fd);
sd.SSN = SSN;
% -----------------------
% KEYS
% -----------------------
if Keys==1;
	keysfn = [strrep(SSN, '-', '_') '_keys'];
	assert(exist(keysfn, 'file')==2, 'Cannot find keys file %s.', keysfn);
	eval(keysfn);
	sd.ExpKeys = ExpKeys;
	sd.ExpKeys.SSN = SSN;
	sd.ExpKeys.fd = fd;
	
	assert(~iscell(ExpKeys.Behavior), 'Multiple Behaviors');
else
	sd.ExpKeys.Behavior='nan';
end
%------------------------
% VIDEO TRACKING
%------------------------
% Video-tracker-1
if VT1==1
	W = warning();
	warning off MATLAB:unknownObjectNowStruct
	vtfn = fullfile(fd, [SSN '-vt.mat']);
	assert(exist(vtfn, 'file')==2, 'Cannot find vt file %s.', vtfn);
	if exist(vtfn, 'file')
		load(vtfn);
		if exist('Vt', 'var'), x = Vt.x; y = Vt.y; end
		if isstruct(x); x = tsd(x); end
		if isstruct(y); y = tsd(y); end
		if Keys==1;
			sd.x = x.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
			sd.y = y.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
		end
	else
		warning('FileNotFound: No VT file found.');
	end
	warning(W);
end
% Video-tracker-2
if VT2==1
	W = warning();
	warning off MATLAB:unknownObjectNowStruct
	vtfn = fullfile(fd, [SSN '-vt2.mat']);
	assert(exist(vtfn, 'file')==2, 'Cannot find vt file %s.', vtfn);
	if exist(vtfn, 'file')
		load(vtfn);
		if exist('Vt', 'var'), x = Vt.x; y = Vt.y; end
		if isstruct(x); x = tsd(x); end
		if isstruct(y); y = tsd(y); end
		if Keys==1;
			sd.x2 = x.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
			sd.y2 = y.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
		end
	else
		warning('FileNotFound: No VT2 file found.');
	end
	warning(W);
end
%-------------------------
% EVENTS
%-------------------------
if Events
	eventsfn = fullfile(fd, [SSN '-events.Nev']); %#ok<UNRCH>
	assert(exist(eventsfn, 'file')==2, 'Cannot find events file %s.', eventsfn);
end
%-------------------------
% SPIKES
%-------------------------
if Spikes ==1
	fc = FindFiles('*.t', 'CheckSubdirs', 0);
	if Use__Ts; fc = cat(1, fc, FindFiles('*._t', 'CheckSubdirs',0));  end %#ok<UNRCH>
	S = LoadSpikes(fc);
	L = zeros(length(S),1);
	for iC = 1:length(S)
		S{iC} = S{iC}.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
		L(iC) = length(S{iC}.data);
	end
	keep = L>0;
	sd.S = S(keep);       % 2013-03-04 AndyP
	sd.fc = fc(keep);     % 2013-03-04 AndyP, sd.fc, sd.fn and sd.S are now all the same length
	sd.fn = {};
	for iC = 1:length(sd.fc)
		[~,sd.fn{iC}] = fileparts(sd.fc{iC});
		sd.fn{iC} = strrep(sd.fn{iC}, '_', '-');
	end
	sd.fn = sd.fn';
end
%-----------------------
% DD.mat File
%-----------------------
if DD==1
	DD = fullfile(fd, [SSN '-DD.mat']);
	assert(exist(DD, 'file')==2, 'Cannot find *DD.mat file %s.', DD);
	if exist(DD, 'file')
		load(DD); % process *DD.mat file
		if ~strcmp(sd.ExpKeys.Behavior,'FPT Delay Discounting');
			[FeedersFired, FeederTimes] = DD6_FixFeedersFired(FeederTimes, FeedersFired, ZoneIn, TotalLaps); %#ok<NODEF>
			if datenum(SSN(6:end),'yyyy-mm-dd')<datenum('2011-09-05','yyyy-mm-dd')
				%fix bug in feeders fired and feeder times 2012-03-17 AndyP
				sd.Coord.SoM_x = 280; % Start of Maze <x,y>
				sd.Coord.SoM_y = 209;
				sd.Coord.CP_x = 141;  % Choice point <x,y>
				sd.Coord.CP_y = 209;
				sd.Coord.LF_x = 141;  % Left feeder <x,y>
				sd.Coord.LF_y = 337;
				sd.Coord.RF_x = 141;  % Right Feeder <x,y>
				sd.Coord.RF_y = 81;
				sd.InZoneDistance = [77 77 77 77]; %radius of zone [1 2 3 4] (# pixels)
			elseif datenum(SSN(6:end),'yyyy-mm-dd')>datenum('2011-09-05','yyyy-mm-dd')
				sd.Coord.SoM_x = 280; % Start of Maze <x,y>
				sd.Coord.SoM_y = 209;
				sd.Coord.CP_x = 141;  % Choice point <x,y>
				sd.Coord.CP_y = 209;
				sd.Coord.LF_x = 141;  % Left feeder <x,y>
				sd.Coord.LF_y = 337;
				sd.Coord.RF_x = 141;  % Right Feeder <x,y>
				sd.Coord.RF_y = 81;
				sd.InZoneDistance = [60 60 60 60]; %radius of zone [1 2 3 4] (# pixels)
			end
		else
		end
		%--------------
		[sd.DelayZone, ~,~] = DD_getWorld(World);
		sd.ZoneDelay = ZoneDelay;
		sd.ZoneIn = ZoneIn;
		sd.World = World;
		sd.TotalLaps = TotalLaps;	
		%--------------
		if exist('EnteringZoneTime','var'); sd.EnteringZoneTime = EnteringZoneTime*(10^-6); end 
		if exist('ExitZoneTime','var'); sd.ExitZoneTime = ExitZoneTime*(10^-6); end    
		if exist('FeedersFired','var'); sd.FeedersFired=FeedersFired; end
		if exist('FeederTimes','var'); sd.FeederTimes = FeederTimes*(10^-6); end 
		if exist('BackwardsTimes','var'); sd.BackwardsTimes=BackwardsTimes*(10^-6); end  
		if exist('EnteringSoMTime','var'); sd.EnteringSoMTime=EnteringSoMTime*(10^-6); end 
		if exist('ExitingSoMTime','var'); sd.ExitingSoMTime=ExitingSoMTime*(10^-6); end 
		if exist('EnteringCPTime','var'); sd.EnteringCPTime=EnteringCPTime.*(10^-6); end
		if exist('ExitingCPTime','var'); sd.ExitingCPTime=ExitingCPTime.*(10^-6); end
		
		if exist('FeederSkip','var'); sd.FeederSkip=FeederSkip; end
		if exist('SwitchLap','var'); sd.SwitchLap=SwitchLap; end
		
	else
		warning('FileNotFound: No *DD.mat file found.');
	end
end
%--------------
if dirpushed
	popdir;
end

