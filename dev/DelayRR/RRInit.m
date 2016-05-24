 function sd = RRInit(varargin)
 
% sd = RRInit(fd)
%
% Initializes a single restaurant row session.
% checks and loads keys, video-tracker-1, and spikes
%
% ADR 2011-12
% 
% Optional arguments:
% ******************
% fd = pwd;              % file directory to initialize
% useKeys = true;        % use the _keys.m file
% useEvents = false;     % use the events.nev file
% timeBase = 1e-6;       % multiplier to get .nvt time stamps into seconds
% VTEtime = 3;           % time interval for VTE calculations (sec)
% 
% Behavior = [];         % the behavioral task
% Tones = true;          % tones
% Condition = '';        % experimental condition (Saline, drug, etc.)
% Dose = [];             % dose for experimental condition (mg/kg)
% Protocol = [];         % behavior, hyperdrive recording, pharmacology, etc
% Target = [];           % tetrode target structure (e.g. HC, OFC, vStr)
% Target2 = [];          % second tetrode target structure
% Target3 = [];          % third tetrode target structure
% Target4 =[];           % first target substructure
% Target5=[];            % second target substructure
% Target6=[];            % third target substructure
% TetrodeDepths = [];    % estimated depth turned of each tetrode in microns
% CSCReference = [];     % reference for each CSC
% UseDepthCSV = [];      % Use a csv containing depths for tetrodes
% TetrodeTargets = [];   % Index indicates which target
% nCSCs = 24;            % Number of continuous sampling channels (Typically 24)
% TimeOnTrack = [];      % Time on track
% TimeOffTrack = [];     % Time off track
% nSecGap = 25;          % number of seconds in recording gap to presume session has ended.
% HasHCTheta = [];       % 1 indicates an auxiliary HC theta electrode was included.  This affects the patch panel configuration on Cheetah.
% ThetaCSC = [];         % CSC channel of auxiliary HC theta electrode.
% PostFeed = [];         % Amount post-fed, in grams
% nPellets = [];         % the number of pellets delivered at each zone
% FeederDelayList = 1:30;% the delay of each zone
% FeederProbList = 1;    % the probability of reward in each zone
% Blocks = [];           % Number of times blocked
% Nudges = [];           % Number of times nudged
% Weight = [];           % the weight of the rat in grams
% Note1=[];              % document any unusual events, task malfunctions, or unusual behavior (e.g. lost tracking lap 20, feeder misfires lap 20, ghost pixels, rat fell off track lap 20 etc).
% Note2=[];
% Note3=[];
% addSpikes=true;        % include t files (.t) in sd as sd.S, sd.fc, sd.fn
% addUnderscored=false;  % include underscored t files (._t) in sd as sd.S_t, sd.fc_t, sd.fn_t fields. 
% 
% MODIFIED:
% 2014-10-29    (YAB)    Included field "World" with subfields
%                        FeederLocations, ZoneLocations, and MazeCenter.
% 2015-01-31    (YAB)    Included subfields CPLocations, ArmLocations, and
%                        ZoneExitLocations to World field
% 

fd = pwd;
if nargin==1
    fd = varargin{1};
end
useKeys = true;
useEvents = false;
timeBase = 1e-6;
VTEtime = 3;           % time interval for VTE calculations (sec)

Behavior = [];         % the behavioral task
Tones = true;          % tones
Condition = '';        % experimental condition (Saline, drug, etc.)
Dose = [];             % dose for experimental condition (mg/kg)
Protocol = [];         % behavior, hyperdrive recording, pharmacology, etc
Target = [];           % tetrode target structure (e.g. HC, OFC, vStr)
Target2 = [];          % second tetrode target structure
Target3 = [];          % third tetrode target structure
Target4 =[];
Target5=[];
Target6=[];
TetrodeDepths = [];  % estimated depth turned of each tetrode in microns
CSCReference = [];   % reference for each CSC
UseDepthCSV = [];    % Use a csv containing depths for tetrodes
TetrodeTargets = []; % 0 indicates tetrode Target #1, 1 indicates tetrode Target #2
nCSCs = 24;          % Number of continuous sampling channels (Typically 24 TTs+4 refs)
TimeOnTrack = [];
TimeOffTrack = [];
nSecGap = 25;        % number of seconds in recording gap to presume session has ended.
HasHCTheta = [];     % 1 indicates an auxilliary HC theta electrode was included.  This affects the patch panel configuration on Cheetah.
ThetaCSC = [];
PostFeed = [];
nPellets = [];       % the number of pellets delivered at each zone
FeederDelayList = [1:30];% the delay of each zone
FeederProbList = [1]; % the probability of reward in each zone
Blocks = [];
Nudges = [];
Weight = [];         % the weight of the rat in grams
Note1=[];            % document any unusual events, task malfunctions, or unusual behavior (e.g. lost tracking lap 20, feeder misfires lap 20, ghost pixels, rat fell off track lap 20 etc).
Note2=[];
Note3=[];
addSpikes=true;
addUnderscored=false;
suppressOutput=true;
process_varargin(varargin);
pushdir(fd);

assert(exist(fd, 'dir')==7, 'Cannot find directory %s.', fd);

[~, SSN, ~] = fileparts(fd);

%-----------------------
% DATAFILE
%-----------------------

datafn = FindFiles('RR-*.mat','Checksubdirs',0);
if length(datafn)>1
    for s = 1 : length(datafn)
        disp('Multiple RR data files.')
        sd0 = load(datafn{s});
        nReps = ceil(((sd0.TotalLaps+1)*4)/length(sd0.nPellets));
        nPellets = repmat(sd0.nPellets,1,nReps);
        nPellets = nPellets(1:length(sd0.ZoneIn));
        sd0.nPellets = nPellets;

        FeederList = repmat(sd0.FeederList,1,sd0.TotalLaps+1);
        FeederList = FeederList(1:length(sd0.ZoneIn));
        sd0.FeederList = FeederList;
        sd0.FeederDelay = sd0.FeederDelay(1:length(sd0.ZoneIn));
        sd0.Subsession = s;
        laps = repmat([1:length(sd0.ZoneIn)],4,1);
        laps = laps(:);
        sd0.Laps = laps(1:length(sd0.ZoneIn));
        
        sd(s,1) = sd0;
    end
else
    disp('Single-session restaurant row.')
    sd = load(datafn{1});
    nReps = ceil(((sd.TotalLaps+1)*4)/length(sd.nPellets));
    nPellets = repmat(sd.nPellets,1,nReps);
    nPellets = nPellets(1:length(sd.ZoneIn));
    sd.nPellets = nPellets;
    FeederList = repmat(sd.FeederList,1,sd.TotalLaps+1);
    FeederList = FeederList(1:length(sd.ZoneIn));
    sd.FeederList = FeederList;
    sd.FeederDelay = sd.FeederDelay(1:length(sd.ZoneIn));
    sd.Subsession = 1;
    
    laps = repmat([1:length(sd.ZoneIn)],4,1);
    laps = laps(:)';
    sd.Laps = laps(1:length(sd.ZoneIn));
end

disp(['Multiplying timestamps by ' num2str(timeBase) '...'])
for f = 1 : length(sd)
    sd(f).EnteringZoneTime = sd(f).EnteringZoneTime*timeBase;
    sd(f).ExitZoneTime = sd(f).ExitZoneTime*timeBase;
    sd(f).EnteringCPTime = sd(f).EnteringZoneTime;
    sd(f).ExitingCPTime = sd(f).EnteringZoneTime+VTEtime;
    if isfield(sd(f),'ToneTimes')
        sd(f).ToneTimes = sd(f).ToneTimes*timeBase;
    end
    if isfield(sd(f),'SessionStartTime')
        sd(f).SessionStartTime = sd(f).SessionStartTime*timeBase;
    end
    if isfield(sd(f),'SessionEndTime')
        sd(f).SessionEndTime = sd(f).SessionEndTime*timeBase;
    end
    sd(f).FeederTimes = sd(f).FeederTimes*timeBase;
end

%------------------------
% VIDEO TRACKING
%------------------------
W = warning();
warning off MATLAB:unknownObjectNowStruct
vtfn = fullfile(fd, [SSN '-vt.mat']);
if ~(exist(vtfn, 'file')==2)
    disp('Creating -VT.mat file...')
    nvtfile = FindFiles('*.nvt');
    unzipped = false;
    if isempty(nvtfile)
        zipfile = FindFiles('*.zip');
        filesPre = FindFiles('*.*','CheckSubdirs',false);
        if ~isempty(zipfile)
            unzip(zipfile{1})
            unzipped = true;
        end
        filesPost = FindFiles('*.*','CheckSubdirs',false);
        newFiles = filesPost(~ismember(filesPost,filesPre));

        nvtfile = FindFiles('*.nvt');
    end
    
    [x,y,phi] = LoadVT_lumrg(nvtfile{1});
    save([SSN '-vt.mat'],'x','y','phi')
    disp('-VT.mat file created.')
    if unzipped
        for iF = 1 : length(newFiles)
            delete(newFiles{iF});
        end
    end
end
   
if exist(vtfn, 'file')
	load(vtfn);
	if exist('Vt', 'var'), x = Vt.x; y = Vt.y; end
	if isstruct(x), x = tsd(x); end
	if isstruct(y), y = tsd(y); end
	if exist('phi', 'var') && isstruct(phi), phi = tsd(phi); end
    if exist('phi', 'var'), phi = tsd(sort(phi.range),phi.data);end
    for f = 1 : length(sd)
        sd(f).x = x;
        sd(f).y = y;
    end
end
warning(W);
for iSubsess=1:length(sd(:))
    sd(iSubsess).x = tsd(sort(sd(iSubsess).x.range),sd(iSubsess).x.data);
    sd(iSubsess).y = tsd(sort(sd(iSubsess).y.range),sd(iSubsess).y.data);
end

%-----------------------
% KEYS
%-----------------------
if useKeys
    keysfn = [strrep(SSN, '-', '_') '_keys'];
    keysfnOld = [strrep(SSN, '-', '_') '_RR_keys'];
    if ~(exist(keysfn, 'file')==2)&&~(exist(keysfnOld, 'file')==2)
        
        %GET TIME ON TRACK, OFF TRACK
        disp('Obtaining TimeOnTrack, TimeOffTrack information... ')
        tracking = load([SSN '-vt.mat']);
        if isfield(tracking,'x')&&isfield(tracking,'y')
            x = tracking.x;
            y = tracking.y;
        else
            x = tsd(tracking.Vt.x.t,tracking.Vt.x.data);
            y = tsd(tracking.Vt.y.t,tracking.Vt.y.data);
        end
        x = tsd(sort(x.range),x.data);
        y = tsd(sort(y.range),y.data);
        
        if isfield(sd,'SessionStartTime')
            SessionStartTime = nan(length(sd),1);
            for iS=1:length(sd)
                SessionStartTime(iS) = sd(iS).SessionStartTime;
            end
            TimeOnTrack = min(SessionStartTime);
        else
            TimeOnTrack = min(x.range);
        end
        
        if strncmpi(Protocol,'Hyp',3)
            disp(['Inferring session end time from last >' num2str(nSecGap) 's gap in recording...']);
            TimeOffTrack = findRRendTime(vtfn,'startTime',TimeOnTrack,'nSec',nSecGap);
        else
            TimeOffTrack = max(x.range);
        end
        
        disp(sprintf('No keys file. Generating %s.',keysfn))
        RR_CreateKeys('Behavior', Behavior,...
            'Tones',Tones,...
            'Condition',Condition,...
            'Dose',Dose,...
            'Protocol',Protocol,...
            'Target',Target,...
            'Target2',Target2,...
            'Target3',Target3,...
            'Target4',Target4,...
            'Target5',Target5,...
            'Target6',Target6,...
            'TetrodeDepths',TetrodeDepths,...
            'UseDepthCSV',UseDepthCSV,...
            'TetrodeTargets',TetrodeTargets,...
            'nCSCs',nCSCs,...
            'CSCReference',CSCReference,...
            'TimeOnTrack',TimeOnTrack,...
            'TimeOffTrack',TimeOffTrack,...
            'HasHCTheta',HasHCTheta,...
            'ThetaCSC',ThetaCSC,...
            'PostFeed',PostFeed,...
            'nPellets',nPellets,...
            'FeederDelayList',FeederDelayList,...
            'FeederProbList',FeederProbList,...
            'Blocks',Blocks,...
            'Nudges',Nudges,...
            'Weight',Weight,...
            'Note1',Note1,...
            'Note2',Note2,...
            'Note3',Note3);
    end
    assert(exist([keysfn '.m'], 'file')==2|exist([keysfnOld '.m'], 'file')==2, 'Cannot find keys file %s.', keysfn);
    if exist([keysfn '.m'], 'file')==2
        eval(keysfn)
    else
        eval(keysfnOld)
    end
    disp('Experiment keys...')
%     for f = 1 : length(sd)
%         sd(f).ExpKeys = ExpKeys;
%         sd(f).ExpKeys.SSN = SSN;
%         sd(f).ExpKeys.fd = fd;
%     end
    if suppressOutput
        eval('ExpKeys;');
    else
        eval('ExpKeys');
    end
    for s = 1 : length(sd)
        sd(s).ExpKeys = ExpKeys;
        sd(s).ExpKeys.SSN = SSN;
        sd(s).ExpKeys.fd = fd;
        sd(s).NextZoneTime = [sd(s).EnteringZoneTime(2:end) sd(s).ExpKeys.TimeOffTrack]-sd(s).x.dt;
    end
    
    assert(~iscell(ExpKeys.Behavior), 'Multiple Behaviors');
else
    ExpKeys.TimeOnTrack = 0;
    ExpKeys.TimeOffTrack = inf;
end


if length(sd)>1
    if isfield(sd,'SessionStartTime')
        disp('Setting subsession-specific on/off track times')
        for iSubsess = 1 : length(sd)-1
            StartTime(iSubsess) = sd(iSubsess).SessionStartTime;
            EndTime(iSubsess) = sd(iSubsess+1).SessionStartTime;
        end
        StartTime(length(sd)) = sd(length(sd)).SessionStartTime;
        EndTime(length(sd)) = sd(length(sd)).ExpKeys.TimeOffTrack;

        for iSubsess = 1 : length(sd)
            sd(iSubsess).SubsessOnTrack = StartTime(iSubsess);
            sd(iSubsess).SubsessOffTrack = EndTime(iSubsess);
        end
    else
        for iSubsess = 1 : length(sd)
            sd(iSubsess).SubsessOnTrack = nan;
            sd(iSubsess).SubsessOffTrack = nan;
        end
    end
else
    sd.SubsessOnTrack = sd.ExpKeys.TimeOnTrack;
    sd.SubsessOffTrack = sd.ExpKeys.TimeOffTrack;
end

for iSubsess=1:length(sd)
    stayGo = nan(1,length(sd(iSubsess).EnteringZoneTime));
    stayGo(1:length(sd(iSubsess).ExitZoneTime)) = ismember(sd(iSubsess).ExitZoneTime,sd(iSubsess).FeederTimes);
    sd(iSubsess).stayGo = stayGo;
    ExitZoneTime = nan(1,length(sd(iSubsess).EnteringZoneTime));
    ExitZoneTime(1:length(sd(iSubsess).ExitZoneTime)) = sd(iSubsess).ExitZoneTime;
    ExitZoneTime = min(ExitZoneTime,sd(iSubsess).SubsessOffTrack);
    sd(iSubsess).ExitZoneTime = ExitZoneTime;
end

% Create world.
disp('Building world...')
disp('Feeder locations...')
uniqueFs = unique(sd(1).FeedersFired);
World.FeederLocations.x = nan(1,max(uniqueFs));
World.FeederLocations.y = nan(1,max(uniqueFs));
for iF=1:length(uniqueFs)
    World.FeederLocations.x(uniqueFs(iF)) = nanmedian(sd(1).x.data(sd(1).FeederTimes(sd(1).FeedersFired==uniqueFs(iF))));
    World.FeederLocations.y(uniqueFs(iF)) = nanmedian(sd(1).y.data(sd(1).FeederTimes(sd(1).FeedersFired==uniqueFs(iF))));
end
disp('Zone boundary locations...')
uniqueZones = unique(sd(1).ZoneIn);
World.ZoneLocations.x = nan(1,max(uniqueZones));
World.ZoneLocations.y = nan(1,max(uniqueZones));
for iZ=1:length(uniqueZones)
    World.ZoneLocations.x(uniqueZones(iZ)) = nanmedian(sd(1).x.data(sd(1).EnteringZoneTime(sd(1).ZoneIn==uniqueZones(iZ))));
    World.ZoneLocations.y(uniqueZones(iZ)) = nanmedian(sd(1).y.data(sd(1).EnteringZoneTime(sd(1).ZoneIn==uniqueZones(iZ))));
end
for iZ=1:length(uniqueZones)
    World.ZoneExitLocations.x(uniqueZones(iZ)) = nanmedian(sd(1).x.data(sd(1).ExitZoneTime(sd(1).ZoneIn==uniqueZones(iZ)&sd(1).stayGo==0)));
    World.ZoneExitLocations.y(uniqueZones(iZ)) = nanmedian(sd(1).y.data(sd(1).ExitZoneTime(sd(1).ZoneIn==uniqueZones(iZ)&sd(1).stayGo==0)));
end

disp('Maze center locations...')
World.MazeCenter.x = nanmedian(World.ZoneLocations.x);
World.MazeCenter.y = nanmedian(World.ZoneLocations.y);

% delim = regexpi(SSN,'-');
% sessDate(1) = str2double(SSN(delim(1)+1:delim(2)-1));
% sessDate(2) = str2double(SSN(delim(2)+1:delim(3)-1));
% sessDate(3) = str2double(SSN(delim(3)+1:end));
% sessDateNum=datenum(sessDate);
% comp1 = datenum([2013, 08, 11]);
% comp2 = datenum([2013, 12, 02]);
% comp3 = datenum([2014, 02, 14]);
% if sessDateNum<=comp1
%     wave=1;
% end
% if sessDateNum>comp1&sessDateNum<comp2
%     wave=2;
% end
% if sessDateNum>=comp2
%     wave=3;
% end
% 
% disp('CP locations...')
% % pre 2013-08-11: [360,130], [400,255], [245,295], [210,160]
% % 2013-09-29--2014-02-14: [373,120], [400,260], [240,280], [215,140]
% % post 2014-02-14: [480,115], [550,310], [350,330], [310,150]
% switch wave
%     case 1
%         World.CPLocations.x = [355, 400, 250, 210];
%         World.CPLocations.y = [130, 255, 300, 170];
%     case 2
%         World.CPLocations.x = [375, 400, 240, 215];
%         World.CPLocations.y = [120, 260, 280, 140];
%     case 3
%         World.CPLocations.x = [480, 550, 380, 305];
%         World.CPLocations.y = [115, 280, 340, 170];
% end
% 
% disp('Arm locations...')
% % pre 2013-08-11: [400,130], [390,300], [220,300], [210,120]
% % 2013-09-29--2014-02-14: [410,113], [395,295], [200,280], [215,110]
% % post 2014-02-14: [560,120], [550,340], [310,330], [310,120]
% switch wave
%     case 1
%         World.ArmLocations.x = [405, 400, 210, 210];
%         World.ArmLocations.y = [125, 305, 305, 115];
%     case 2
%         World.ArmLocations.x = [410, 410, 200, 205];
%         World.ArmLocations.y = [113, 310, 285, 90];
%     case 3
%         World.ArmLocations.x = [540, 535, 320, 315];
%         World.ArmLocations.y = [125, 335, 345, 130];
% end
% disp('Zone exit...')
% % pre 2013-08-11: [390,170], [360,290], [220,265], [250,135]
% % 2013-09-29--2014-02-14: [400,145], [365,290], [210,255], [245,115]
% % post 2014-02-14: [550,155], [500,340], [310,300], [355,120]
% switch wave
%     case 1
%         World.ZoneExitLocations.x = [390, 355, 220, 255];
%         World.ZoneExitLocations.y = [175, 290, 260, 135];
%     case 2
%         World.ZoneExitLocations.x = [400, 360, 210, 250];
%         World.ZoneExitLocations.y = [160, 290, 250, 115];
%     case 3
%         World.ZoneExitLocations.x = [550, 505, 310, 360];
%         World.ZoneExitLocations.y = [180, 330, 275, 125];
% end
for iSubSess=1:length(sd)
    sd(iSubSess).World = World;
end

%-------------------------
% EVENTS
%-------------------------
if useEvents
    disp('Processing events... ')
    eventsfn = fullfile(fd, [SSN '-events.Nev']);
    assert(exist(eventsfn, 'file')==2, 'Cannot find events file %s.', eventsfn);
end
%-------------------------
% SPIKES
%-------------------------
if addSpikes
    disp('Adding spike train information... ')
    fc = FindFiles('*.t', 'CheckSubdirs', 0);
    S = LoadSpikes(fc);
    for iC = 1:length(S)
        D = S{iC}.data;
        S{iC} = ts(sort(D));
    end

    for f = 1 : length(sd)
        sd(f).S = S;
        sd(f).fc = fc;
        sd(f).fn = cell(1,length(fc));
        for iC = 1:length(fc)
            [~, sd(f).fn{iC}] = fileparts(sd(f).fc{iC});
            sd(f).fn{iC} = strrep(sd(f).fn{iC}, '_', '-');
        end
    end
end

if addUnderscored
    disp('Adding underscore-t files...')
    fc0 = FindFiles('*._t','CheckSubdirs',0);
    S0 = LoadUnderscoredSpikes(fc0);
    
    for f0=1:length(sd)
        sd(f0).S_t = S0;
        sd(f0).fc_t = fc0;
        sd(f0).fn_t = cell(1,length(fc0));
        for iC = 1 : length(fc0)
            [~, fn_t] = fileparts(fc0{iC});
            sd(f0).fn_t{iC} = strrep(fn_t,'_','-');
        end
    end
end

if nargout<1
    save([SSN '-sd.mat'],'sd');
    disp(sprintf('sd saved to %s.',[fd '\' SSN '-sd.mat']))
end

popdir;

