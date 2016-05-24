function RRowPromote(varargin)
%
%
%
%

Behaviour = '';
Condition = '';
Protocol = 'Behavior';
PostFeed = [];
Blocks = 0;
Nudges = 0;
Notes = '';
Dose = nan;
CopyToADRLAB15 = true;
process_varargin(varargin);

SSN = GetSSN('SingleSession');
id = min(regexpi(SSN,'R*-'));
ratStr = SSN(1:id-1);
dateStr = SSN(id+1:end);

%% Events
EventsFile = FindFiles('Events.nev','CheckSubdirs',0);
if ~isempty(EventsFile)
    for f = 1 : length(EventsFile)
        [pn,fn,ext] = fileparts(EventsFile{f});
        movefile([fn ext],[SSN '-' fn ext])
    end
end

%% CSC
ncsfn = FindFiles('CSC*.ncs','CheckSubdirs',0);
if strcmpi(Protocol,'Behavior') && ~isempty(ncsfn)
    % ncs is USV
    for f = 1 : length(ncsfn)
        [pn,fn,ext]=fileparts(ncsfn{f});
        idNum = regexpi(fn,'[0-9]*');
        fNew = sprintf('CSC%02d', str2num(fn(idNum:end)));
        movefile([fn ext],[SSN '-' fNew 'usv' ext])
    end
end

if ~strcmpi(Protocol,'Behavior')&&~isempty(ncsfn)
    for f = 1 : length(ncsfn)
        fprintf(['\n' ncsfn{f} '\n'])
        [pn,fn,ext]=fileparts(ncsfn{f});
        idNum = regexpi(fn,'[0-9]*');
        fNew = sprintf('CSC%02d', str2double(fn(idNum:end)));
        TT = input('Tetrode channel: ', 's');
        TT = lower(TT);
        movefile([fn ext],[SSN '-' fNew TT ext])
    end
end

%% VT1
VT1FileName = [SSN '-vt.mat']; %remove trailing 1 from file name for backwards compatibility
fn = FindFiles(VT1FileName,'CheckSubdirs',0);
if isempty(fn)
    nvt2mat;
end
zipfile = FindFiles('*.zip','CheckSubdirs',0);
for f = 1 : length(zipfile)
    unzip(zipfile{f})
    vt1 = FindFiles('VT*.nvt','CheckSubdirs',0);
    for vtf = 1 : length(vt1)
        [pn,fn,ext] = fileparts(vt1{vtf});
        movefile([fn ext],[SSN '-' fn ext])
    end
end

VT1 = load(VT1FileName);
TimeOnTrack = min(VT1.x.range);
TimeOffTrack = max(VT1.x.range);

keysfn = FindFiles('*_keys.m','CheckSubdirs',0);

if isempty(keysfn)
    %% Datafile
    DatFileName = FindFiles('RR-*.mat','CheckSubdirs',0);
    Weight = [];
    for f = 1 : length(DatFileName)
        Data(f).DATA = load(DatFileName{f});
        if isfield(Data(f).DATA,'Weight')
            if ~isempty(Data(f).DATA.Weight)
                Weight = Data(f).DATA.Weight;
            end
        end
        nZones = length(unique(Data(f).DATA.ZoneIn));
        FeederDelayList = nan(nZones,length(unique(Data(f).DATA.FeederDelay(:))));
        for z = 1 : size(Data(f).DATA.FeederDelay)
            uniqueD = unique(Data(f).DATA.FeederDelay(z,:));
            n = length(uniqueD);
            FeederDelayList(z,1:n) = uniqueD;
        end
        if isfield(Data(f).DATA,'nPelletsPerDrop')
            nPellets = Data(f).DATA.nPelletsPerDrop;
        elseif isfield(Data(f).DATA,'nPellets')
            nPellets(1:nZones) = Data(f).DATA.nPellets;
        end
        if isfield(Data(f).DATA,'ZoneProbability')
            FeederProbList(1:nZones,:) = unique(Data(f).DATA.ZoneProbability);
        else
            FeederProbList(1:nZones) = 1;
        end
    end
    if length(DatFileName)>1
        % multiple data workspaces per directory implies 4x20
        nSubSess = length(DatFileName);
        for f = 1 : length(DatFileName)
            dSubSess(f) = Data(f).DATA.maxTimeToRun;
        end
        dSubSess = round(mean(dSubSess)/60);
        Behaviour = [num2str(nSubSess) 'x' num2str(dSubSess) ' RR'];
    end
    while isempty(Weight)
        Weight = input(sprintf('Weight for session %s (g):\t',SSN));
    end

    %% Task specifics
    if isempty(Behaviour)
        if all(FeederProbList==1)
            Behaviour = ['STABLE RR'];
        else
            Behaviour = ['STABLE ProbRR'];
        end
    end
    if isempty(PostFeed)
        PostFeed = input(sprintf('Post-fed session %s (g) [0]:\t',SSN));
        if isempty(PostFeed);PostFeed = 0;end
    end

    %% Keys File
    RR_CreateKeys('Behavior',Behaviour,'Condition',Condition,'Dose',Dose,'Protocol',Protocol,'TimeOnTrack',TimeOnTrack,'TimeOffTrack',TimeOffTrack,'PostFeed',PostFeed,'nPellets',nPellets,'FeederDelayList',FeederDelayList,'FeederProbList',FeederProbList,'Weight',Weight,'Blocks',Blocks,'Nudges',Nudges,'Note1',Notes)
end
%% Task init
sd=ProbRRInit;
sdfn = [SSN '-sd.mat'];
save(sdfn,'sd')

%% Move to db

if CopyToADRLAB15
    disp('Copying files to inprogress...')

    % Copy 
    % R*-vt.mat
    % R*-Events.nev
    % R*-sd.mat
    % R*_keys.m
    % R*-VT1.nvt
    % R*-CSC*.ncs
    % to \\adrlab15\datainprocess\ratname\ssn
    
    destination = ['\\adrlab15\db\datainprocess\' ratStr '\' SSN];
    try
        if ~isdir(['\\adrlab15\db\datainprocess\',ratStr])
            mkdir('\\adrlab15\db\datainprocess\',ratStr);
        end
        try
            mkdir(['\\adrlab15\db\datainprocess\' ratStr '\'], SSN);
        catch exception
            disp(['Cannot create directory \\adrlab15\db\datainprocess\' ratStr '\' SSN '.'])
        end
    catch exception
        disp('Error making directory for promotion.')
    end
    source{1} = FindFile('R*-vt.mat');
    source{2} = FindFile('R*-Events.nev');
    source{3} = FindFile('R*-sd.mat');
    source{4} = FindFile('R*_keys.m');

    source{5} = FindFile('R*-VT1.nvt');
    if ~isempty(source{5})
        zipfn = source{5};
        zipfn(end-3:end) = '.zip';
        try
            zip(zipfn,source{5});
            source{5} = zipfn;
        catch exception
            disp(['Could not unzip ' zipfn])
        end
    end

    fprintf('\n')
    try
        for f = 1 : length(source)
            fprintf('Copying %s\n',source{f})
            copyfile(source{f},destination)
        end
        CSCs = FindFiles('R*-CSC*.ncs');
        for f = 1 : length(CSCs)
            fprintf('Copying %s\n',CSCs{f})
            copyfile(CSCs{f},destination)
        end
    catch exception
        disp(exception.message)
        disp('Could not upload promotion-ready files in')
        disp(SSN)
    end
end