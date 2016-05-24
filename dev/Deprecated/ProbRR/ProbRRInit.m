 function sd = ProbRRInit(varargin)
 
% sd = TaskInit(fd)
%
% Generic task initialization function
% checks and loads keys, video-tracker-1, and spikes
%
% ADR 2011-12

fd = pwd;
useKeys = true;
useEvents = true;
timeBase = 1e-6;

Behavior = [];         %the behavioral task
Tones = true;          % tones
Condition = '';        % experimental condition (Saline, drug, etc.)
Dose = [];             % dose for experimental condition (mg/kg)
Protocol = [];         % behavior, hyperdrive recording, pharmacology, etc
Target = [];           % tetrode target structure (e.g. HC, OFC, vStr)
Target2 = [];          % second tetrode target structure
Target3 = [];
Target4 =[];
TetrodeDepths = [];  % estimated depth turned of each tetrode in microns
UseDepthCSV = [];    % Use a csv containing depths for tetrodes
TetrodeTargets = []; % 0 indicates tetrode Target #1, 1 indicates tetrode Target #2
nCSCs = 28;          % Number of continuous sampling channels (Typically 24 TTs+4 refs)
CSCReference = [];   % Enter 1,2,..,14 for the tetrode which the CSC channel was referenced during recording
TimeOnTrack = [];
TimeOffTrack = [];
HasHCTheta = [];     % 1 indicates an auxilliary HC theta electrode was included.  This affects the patch panel configuration on Cheetah.
PostFeed = [];
nPellets = [];       % the number of pellets delivered at each zone
FeederDelayList = [];% the delay of each zone
FeederProbList = []; % the probability of reward in each zone
Blocks = [];
Nudges = [];
Weight = [];         % the weight of the rat in grams
Note1=[];            % document any unusual events, task malfunctions, or unusual behavior (e.g. lost tracking lap 20, feeder misfires lap 20, ghost pixels, rat fell off track lap 20 etc).
Note2=[];
Note3=[];
process_varargin(varargin);
pushdir(fd);

assert(exist(fd, 'dir')==7, 'Cannot find directory %s.', fd);

[~, SSN, ~] = fileparts(fd);

%-----------------------
% DATAFILE
%-----------------------

datafn = FindFiles('RR-*.mat','Checksubdirs',0);
if length(datafn)>1
    disp('Multiple RR data files.')
    for iF = 1 : length(datafn)
        sd(iF) = load(datafn{iF});
    end
    
else
    disp('Single-session restaurant row.')
    sd = load(datafn{1});
end

%-----------------------
% KEYS
%-----------------------
if useKeys
    keysfn = [strrep(SSN, '-', '_') '_keys'];
    if ~(exist(keysfn, 'file')==2)
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
            'TetrodeDepths',TetrodeDepths,...
            'UseDepthCSV',UseDepthCSV,...
            'TetrodeTargets',TetrodeTargets,...
            'nCSCs',nCSCs,...
            'CSCReference',CSCReference,...
            'TimeOnTrack',TimeOnTrack,...
            'TimeOffTrack',TimeOffTrack,...
            'HasHCTheta',HasHCTheta,...
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
    assert(exist(keysfn, 'file')==2, 'Cannot find keys file %s.', keysfn);
    eval(keysfn);
    for f = 1 : length(sd)
        sd(f).ExpKeys = ExpKeys;
        sd(f).ExpKeys.SSN = SSN;
        sd(f).ExpKeys.fd = fd;
    end

    assert(~iscell(ExpKeys.Behavior), 'Multiple Behaviors');
else
    ExpKeys.TimeOnTrack = 0;
    ExpKeys.TimeOffTrack = inf;
end
%------------------------
% VIDEO TRACKING
%------------------------
W = warning();
warning off MATLAB:unknownObjectNowStruct
vtfn = fullfile(fd, [SSN '-vt.mat']);
if ~(exist(vtfn, 'file')==2)
    zipfile = FindFiles('*.zip');
    if ~isempty(zipfile)
        unzip(zipfile{1})
    end
    
    nvtfile = FindFiles('*.nvt');
    if ~isempty(nvtfile)
        for iNVT = 1 : length(nvtfile)
            [pathname,filename,ext] = fileparts(nvtfile{iNVT});
            [x,y,phi] = LoadVT_lumrg(nvtfile{1});
            if iNVT>1
                save(sprintf('%s-vt%d.mat',SSN,iNVT),'x','y','phi')
                eval(sprintf('sd.x%d = x.restrict(ExpKeys.TimeOnTrack,ExpKeys.TimeOffTrack);',iNVT))
                eval(sprintf('sd.y%d = y.restrict(ExpKeys.TimeOnTrack,ExpKeys.TimeOffTrack);',iNVT))
            else
                save(sprintf('%s-vt.mat',SSN),'x','y','phi')
                sd.x = x.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
                sd.y = y.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
            end
            destination = sprintf('%s-%s.nvt',SSN,filename);
            eval(sprintf('!rename %s %s',[filename ext],destination));
        end
    end
end
if exist(vtfn, 'file')
	load(vtfn);
	if exist('Vt', 'var'), x = Vt.x; y = Vt.y; end
	if isstruct(x), x = tsd(x); end
	if isstruct(y), y = tsd(y); end
	if exist('phi', 'var') && isstruct(phi), phi = tsd(phi); end
    for f = 1 : length(sd)
        sd(f).x = x.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
        sd(f).y = y.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
    end
end
warning(W);


x0 = sd(1).x.restrict(sd(1).EnteringZoneTime(1),sd(1).ExitZoneTime(1));
if isempty(x0.data)
    for f = 1 : length(sd)
        sd(f).EnteringZoneTime = sd(f).EnteringZoneTime*timeBase;
        sd(f).ExitZoneTime = sd(f).ExitZoneTime*timeBase;
    end
end
x0 = sd(1).x.restrict(sd(1).FeederTimes(1),sd(1).FeederTimes(1)+1);
if isempty(x0.data)
    for f = 1 : length(sd)
        sd(f).FeederTimes = sd(f).FeederTimes*timeBase;
    end
end

%-------------------------
% EVENTS
%-------------------------
if useEvents
    eventsfn = fullfile(fd, [SSN '-events.Nev']);
    assert(exist(eventsfn, 'file')==2, 'Cannot find events file %s.', eventsfn);
end
%-------------------------
% SPIKES
%-------------------------
fc = FindFiles('*.t', 'CheckSubdirs', 0);
S = LoadSpikes(fc);
for iC = 1:length(S)
    S{iC} = S{iC}.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
end

for f = 1 : length(sd)

    sd(f).S = S;
    sd(f).fc = fc;
    for iC = 1:length(fc)
        [~, sd(f).fn{iC}] = fileparts(sd(f).fc{iC});
        sd(f).fn{iC} = strrep(sd(f).fn{iC}, '_', '-');
    end
end

popdir;

