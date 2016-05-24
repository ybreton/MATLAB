function [] = RR_CreateKeys(varargin)
% 2012-05-10 AndyP
% 2012-07-25 AndyP modified input structure.  Behavioral keys no longer
% have hyperdrive keys inputs. 'nan' inputs are no longer accepted, except
% for the case of TimeOnTrack and TimeOffTrack, which may be entered
% manually after creation of the keys file.  Renamed from CreateDDKeys
% Create a keys.mat file for one behavioral session through a series of
% user-inputs
% CreateDDKeys();
% Variables in Keys File
% ExpKeys.Behavior        string, the behavioral task
% ExpKeys.Protocol        string, 'Behavior' or 'Hyperdrive'
% ExpKeys.Target          3x1 cell array of strings, tetrode target structure (e.g. HC, OFC, vStr)
% ExpKeys.Target2         3x1 cell array of strings, subtarget region (e.g. CA1, medial, right-side)
% ExpKeys.TetrodeDepths   Nx1 double, estimated depth turned of each tetrode in microns
% ExpKeys.TetrodeTargets  Nx1 double, 1 indicates tetrode Target #1, 2 indicates tetrode Target #2, 3 indicates Target #3
% ExpKeys.CSCReference    Nx1 cell array of strings, the reference of the CSC channel (e.g. TT01a, r1, TT13, r2, gnd)
% ExpKeys.TimeOnTrack     1x1 double, time [s] that the behavioral task began
% ExpKeys.TimeOffTrack    1x1 double, time [s] that the behavioral task ended
% ExpKeys.HasHCTheta      1x1 double, indicates auxilliary HC theta electrode
% ExpKeys.PostFeed        1x1 double, the amount of post-feed [grams]
% ExpKeys.PelletRatio
% ExpKeys.Tones           1x1 double, 1 if tone cues used during task
% ExpKeys.Blocks          1x1 double, the number of blocks used
% ExpKeys.Nudges          1x1 double, the number of nudges used
% ExpKeys.Weight          1x1 double, the weight of the rat [grams]
% ExpKeys.Note1           string, experimental note #1  (Note: Do NOT use apostraphes ')
% ExpKeys.Note2
% ExpKeys.Note3
% ExpKeys.RF              1x1 double, the number of the right-hand feeder
% ExpKeys.LF              1x1 double, the number of the left-hand feeder
Manipulation = '';     %behavioral manipulation
Behavior = '';         %the behavioral task
Tones = true;          % tones
Condition = '';        % experimental condition (Saline, drug, etc.)
Dose = [];             % dose for experimental condition (mg/kg)
Virus = '';            % virus used for DREADD transduction
ViralTarget = {''};      % target of viral transduction
Protocol = [];         % behavior, hyperdrive recording, pharmacology, etc
Target = [];           % tetrode target structure (e.g. HC, OFC, vStr)
Target2 = [];          % second tetrode target structure
Target3 = [];          % third tetrode target structure.
Target4 =[];
Target5 = [];
Target6 = [];
TetrodeDepths = [];  % estimated depth turned of each tetrode in microns
UseDepthCSV = [];    % Use a csv containing depths for tetrodes
TetrodeTargets = []; % 0 indicates tetrode Target #1, 1 indicates tetrode Target #2
nCSCs = 28;          % Number of continuous sampling channels (Typically 24 TTs+4 refs)
CSCReference = [];   % Enter 1,2,..,28 for the tetrode which the CSC channel was referenced during recording
TimeOnTrack = [];
TimeOffTrack = [];
HasHCTheta = [];     % 1 indicates an auxilliary HC theta electrode was included.  This affects the patch panel configuration on Cheetah.
ThetaCSC = [];       % Channel on which HC theta was recorded.
PostFeed = [];
nPellets = [2 2 2 2];       % nSubsess x nZones, the number of pellets delivered at each zone
FeederDelayList = 1:30;   % the delay of each zone
FeederProbList = 1;      % the probability of reward in each zone
Blocks = [];
Nudges = [];
Weight = [];         % the weight of the rat in grams
Note1=[];            % document any unusual events, task malfunctions, or unusual behavior (e.g. lost tracking lap 20, feeder misfires lap 20, ghost pixels, rat fell off track lap 20 etc).
Note2=[];
Note3=[];
%----------------
[~,SSN,~]=fileparts(pwd);
process_varargin(varargin);
ok = false;
%----------------
if isempty(Behavior);
		Behavior = input('Enter Behavioral Task [RRow]:            ', 's');
		if isempty(Behavior); Behavior = 'RRow'; end
end
if isempty(Manipulation);
        Manipulation = input('Enter Behavioral Manipulation [NONE]:         ', 's');
        if isempty(Manipulation); Manipulation = 'NONE';end
end
if strcmpi(Manipulation,'DREADD') && isempty(Virus)
        Virus=input('Specify infused virus [pAAV8-GFAP-h4MDi-mCherry]:          ', 's');
        if isempty(Virus); Virus = 'pAAV8-GFAP-h4MDi-mCherry';end
end
if ~isempty(Virus) && isempty(ViralTarget)
        ViralTarget=input('Enter virual target [NONE]:        ', 's');
        if isempty(ViralTarget); ViralTarget = {}; end
end
if ischar(ViralTarget)
    ViralTarget = {ViralTarget};
end

if isempty(Condition) && ~isempty(Manipulation)
    Condition = input('Experimental condition (e.g., CNO/Saline) [NONE]:       ','s');
    if isempty(Condition); Condition = 'NONE'; end
elseif isempty(Manipulation)
    Condition = 'NONE';
end

if ~isempty(Condition) && isempty(Dose)
    Dose = input('Condition Dose, mg/kg [0]:       ');
    if isempty(Dose); Dose = 0; end
end
if isempty(Condition) && isempty(Dose)
    Dose = nan;
end
Dose = [num2str(Dose) ' mg/kg'];

if isempty(Protocol);
	while ~ok
		Protocol = input('Enter [H]yperdrive or [B]ehavior:     ', 's');
		if isempty(Protocol) || ~strncmpi(Protocol,'B',1) && ~strncmpi(Protocol,'H',1); ok=0; fprintf('invalid input \n');  else ok=1; end
	end
	ok = false;
end

%%%%%%%%%%%%%%%%%%%
% behavioral keys %
%%%%%%%%%%%%%%%%%%%
% if isempty(nPellets);
% 	Pellets = input('Pellets delivered zone 1 [2]:      ');
% 	if isempty(Pellets); Pellets = 2; end;
%     nPellets(1) = Pellets;
%     Pellets = input('Pellets delivered zone 2 [2]:      ');
% 	if isempty(Pellets); Pellets = 2; end;
%     nPellets(2) = Pellets;
%     Pellets = input('Pellets delivered zone 3 [2]:      ');
% 	if isempty(Pellets); Pellets = 2; end;
%     nPellets(3) = Pellets;
%     Pellets = input('Pellets delivered zone 4 [2]:      ');
% 	if isempty(Pellets); Pellets = 2; end;
%     nPellets(4) = Pellets;
% end
% if isempty(FeederDelayList);
% 	Delays = input('Delays zone 1 [2]:      ');
% 	if isempty(Delays); Delays = 1; end;
%     FeederDelayList(1,:) = Delays;
%     Delays = input('Delays zone 2 [2]:      ');
% 	if isempty(Delays); Delays = 1; end;
%     FeederDelayList(2,:) = Delays;
%     Delays = input('Delays zone 3 [2]:      ');
% 	if isempty(Delays); Delays = 1; end;
%     FeederDelayList(3,:) = Delays;
%     Delays = input('Delays zone 4 [2]:      ');
% 	if isempty(Delays); Delays = 1; end;
%     FeederDelayList(4,:) = Delays;
% end
% if isempty(FeederProbList);
% 	Probs = input('Probability of reward zone 1 [2]:      ');
% 	if isempty(Probs); Probs = 1; end;
%     FeederProbList(1,:) = Probs;
%     Delays = input('Probability of reward  zone 2 [2]:      ');
% 	if isempty(Probs); Probs = 1; end;
%     FeederProbList(2,:) = Probs;
%     Delays = input('Probability of reward  zone 3 [2]:      ');
% 	if isempty(Probs); Probs = 1; end;
%     FeederProbList(3,:) = Probs;
%     Probs = input('Probability of reward  zone 4 [2]:      ');
% 	if isempty(Probs); Probs = 1; end;
%     FeederProbList(4,:) = Probs;
% end
%----------------
if isempty(Weight);
	while ~ok
		Weight = input('Weight:    ');
		if isempty(Weight) || isnan(Weight); ok=0; fprintf('invalid input \n');  else ok=1; end
	end
	ok = false;
end

%----------------
if isempty(Blocks);
	Blocks = input('Enter # of Blocks [0]:    '); Blocks = str2double(Blocks);
	if isempty(Blocks) || isnan(Blocks); Blocks=0; end
end

%----------------
if isempty(Nudges);
    Nudges = input('Enter # of Nudges [0]:    ');
	if isempty(Nudges) || isnan(Nudges); Nudges=0; end
end

%----------------
if isempty(PostFeed);
    PostFeed = input('Enter PostFeed (g) [0]:    ');
	if isempty(PostFeed) || isnan(PostFeed); PostFeed = 0; end
end

%----------------

if isempty(TimeOnTrack); TimeOnTrack = input('Enter TimeOnTrack (s)         ','s');
	TimeOnTrack = floor(str2double(TimeOnTrack));
	if isempty(TimeOnTrack) || isnan(TimeOnTrack); TimeOnTrack = NaN; warning('TimeOnTrack not entered'); end
end
%----------------
if isempty(TimeOffTrack); TimeOffTrack = input('Enter TimeOffTrack (s)         ','s');
	TimeOffTrack = ceil(str2double(TimeOffTrack));
	if isempty(TimeOffTrack) || isnan(TimeOffTrack); TimeOffTrack = NaN; warning('TimeOnTrack not entered'); end
end
%----------------

% generate notes.
if isempty(Note1);
	Note1 = input('Any additional Notes about this session? (skip if none)    ', 's');
	if isempty(Note1)
		Note1= '';
		Note2='';
		Note3='';
	end
end
if ~isempty(Note1);
	if isempty(Note2);   %if note 1, ask for note 2.
		Note2 = input('Second Note:    ', 's');
		if isempty(Note2)
			Note2= '';
			Note3='';
		end
	end
end
if ~isempty(Note2); % if note 2, ask for final note.
	if isempty(Note3);
		Note3 = input('Final Note:    ', 's');
		if isempty(Note3)
			Note3= '';
		end
	end
end
%%%%%%%%%%%%%%%%%%%
% hyperdrive keys %
%%%%%%%%%%%%%%%%%%%
if strcmp(Protocol,'Hyperdrive');
	if isempty(Target);
        k = 0;
        ok = 0;
		while ~ok
            k = k+1;
			Target{k} = input(sprintf('Recording Target #%d (Enter to stop): ',k), 's');
			if isempty(Target{k}); ok=1; Target=Target(1:k-1); end
		end
		ok = false;
	end
	%----------------
	if isempty(Target2); 
        Target2 = cell(1,length(Target));
        for k=1:length(Target2)
            Target2{k} = input(sprintf('Recording Sub-target #%d : ',k), 's');
        end
	end
	%----------------
	
	%----------------
	if  isempty(TetrodeTargets);
		while ~ok
			if strcmp(Target2, 'nan')==1 && strcmp(Target3, 'nan')==1; TetrodeTargets = '1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1';
			else TetrodeTargets = input('For each TT, input "1" for Target#1, "2" for Target#2, "3" for Target#3. \n  Separate with spaces:  ', 's');
			end
			if isempty(TetrodeTargets); ok=0; fprintf('invalid input \n'); else ok=1; end
		end
		ok = false;
    end
	if isnumeric(TetrodeTargets)
        TetrodeTargets = sprintf('%d ',TetrodeTargets);
        TetrodeTargets = TetrodeTargets(1:end-1);
    end
    
	%----------------
	if isempty(CSCReference);
		while ~ok
			CSCReference = input('Input Reference TT for each CSC (usually 12 CSCs referenced to TT13 or TT14). \n  Separate with spaces:   ', 's');
			if isempty(CSCReference); ok=0; fprintf('invalid input \n');  else ok=1; end
		end
		ok = false;
	end
	
	%----------------
	if isempty(HasHCTheta);
		while ~ok
			HasHCTheta = input('Was there a HC Theta Reference?   ', 's');
			HasHCTheta = str2double(HasHCTheta);
			if HasHCTheta~=0 && HasHCTheta~=1; ok=0; fprintf('invalid input \n'); else ok=1; end
		end
		ok = false;  %#ok<NASGU>
	end
	
	%----------------
    if ~isempty(UseDepthCSV)
        csv = csvread(UseDepthCSV);
        Depth = csv(:,end);
        TetrodeDepths = sprintf('%d ', Depth);
        TetrodeDepths = TetrodeDepths(1:end-1);
    end
    
	if isempty(TetrodeDepths);
		TetrodeDepths= input('Input depth in um for each TT (28 shuttles for 24TT drive) \n  Separate with spaces:  ', 's');
		if isempty(TetrodeDepths); TetrodeDepths= sprintf('%s ', nan(nCSCs,1)); TetrodeDepths = TetrodeDepths(1:end-1); end
    end
    if isnumeric(CSCReference)
        CSCReference = sprintf('%d ', CSCReference);
    end
	% parse CSC input
	space = regexp(CSCReference, '\s');
    space = [1 space length(CSCReference)];
    CSC = cell(length(space)-1,1);
    for c = 1 : length(space)-1
        CSC{c} = CSCReference(space(c):space(c+1)-1);
    end
    
        
% 	if length(space)==24;
%         
% 		CSC01 = CSCReference(1:space(1));
% 		CSC02 = CSCReference(space(1):space(2));
% 		CSC03 = CSCReference(space(2):space(3));
% 		CSC04 = CSCReference(space(3):space(4));
% 		CSC05 = CSCReference(space(4):space(5));
% 		CSC06 = CSCReference(space(5):space(6));
% 		CSC07 = CSCReference(space(6):space(7));
% 		CSC08 = CSCReference(space(7):space(8));
% 		CSC09 = CSCReference(space(8):space(9));
% 		CSC10 = CSCReference(space(9):space(10));
% 		CSC11 = CSCReference(space(10):space(11));
% 		CSC12 = CSCReference(space(11):space(12));
% 		CSC13 = CSCReference(space(12):space(13));
% 		CSC14 = CSCReference(space(13):space(14));
% 		CSC15 = CSCReference(space(14):space(15));
% 		CSC16 = CSCReference(space(15):end);
% 	else
% 		warning('unknown number of CSC channels, CSC reference in keys file may not be valid');
% 	end
end
%%%%%%%%%%%%%%%%%%%
% generate keys.m %
%%%%%%%%%%%%%%%%%%%
fout = cat(2,SSN,'_keys.m');
fout = regexprep(fout,'-','_');
fid = fopen(fout,'w');
%populate keys.m
fprintf(fid,'ExpKeys.Behavior = ''%s'';\n',Behavior);
if strcmp(Manipulation,'DREADD')
    fprintf(fid,'ExpKeys.Manipulation = ''%s'';\n',Manipulation);
    fprintf(fid,'ExpKeys.Virus = ''%s'';\n',Virus);

    vtargStr='';
    for targ=1:length(ViralTarget)
        vtargStr = [vtargStr sprintf('''%s'', ',ViralTarget{targ})];
    end
    vtargStr = vtargStr(1:end-2);

    fprintf(fid,'ExpKeys.ViralTarget = {%s};\n',vtargStr);
end
fprintf(fid,'ExpKeys.Condition = ''%s'';\n',Condition);
fprintf(fid,'ExpKeys.Dose = ''%s'';\n',Dose);
fprintf(fid,'ExpKeys.Protocol = ''%s'';\n',Protocol);
% fprintf(fid,'ExpKeys.PelletRatio = %d;\n',PelletRatio);

if size(nPellets,1)>1
    for z=1:size(nPellets,2)
        nStr = sprintf('%d, ',nPellets(:,z));
        nStr = nStr(1:end-2);
        fprintf(fid,'ExpKeys.PelletRatio(%d,:) = [%s];\n',z,nStr);
    end
elseif size(nPellets,1)==1
    for z=1:size(nPellets,2)
        fprintf(fid,'ExpKeys.PelletRatio(%d) = %d;\n',z,nPellets(z));
    end
end

FDLstr = sprintf('%.1f, ',FeederDelayList);
FDLstr = FDLstr(1:end-2);
FDLstr = ['[' FDLstr ']'];
fprintf(fid,'ExpKeys.FeederDelayList = %s;\n',FDLstr);
FPLstr = sprintf('%.2f, ',FeederProbList);
FPLstr = FPLstr(1:end-2);
FPLstr = ['[' FPLstr ']'];
fprintf(fid,'ExpKeys.FeederProbList = %s;\n',FPLstr);
fprintf(fid,'ExpKeys.Tones = %d;\n',Tones);
fprintf(fid,'ExpKeys.Weight = %0.1f;\n',Weight);
fprintf(fid,'ExpKeys.Blocks = %d;\n', Blocks);
fprintf(fid,'ExpKeys.Nudges = %d;\n', Nudges);
fprintf(fid,'ExpKeys.PostFeed = %0.1f;\n', PostFeed);

if strcmp(Protocol,'Hyperdrive');
    TargetStr = '';
    for k=1:length(Target)
        TargetStr = [TargetStr sprintf('''%s'',',Target{k})];
    end
    TargetStr = TargetStr(1:end-1);
    fprintf(fid,'ExpKeys.Target = {%s};\n',TargetStr);
    
    TargetStr = '';
    for k=1:length(Target2)
        TargetStr = [TargetStr sprintf('''%s'',',Target2{k})];
    end
    TargetStr = TargetStr(1:end-1);
	fprintf(fid,'ExpKeys.Target2 = {%s};\n',TargetStr);
	
    fprintf(fid,'ExpKeys.TetrodeTargets = [%s];\n',TetrodeTargets);
	fprintf(fid,'ExpKeys.TetrodeDepths = [%s]; \n',sprintf('%s', TetrodeDepths));
	fprintf(fid,'ExpKeys.HasHCTheta = %d;\n',HasHCTheta);
    if HasHCTheta==1
        fprintf(fid,'ExpKeys.ThetaCSC = %d;\n',ThetaCSC);
    else
        fprintf(fid,'ExpKeys.ThetaCSC = nan;\n');
    end
    str = ['ExpKeys.CSCReference = {'];
    for c = 1 : length(CSC)
        str = [str sprintf('''%s '',',CSC{c})];
    end
    str = str(1:end-1); % remove trailing comma
    str = [str '}'];
% 	fprintf(fid,'ExpKeys.CSCReference = {''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s''};\n', CSC01,CSC02,CSC03,CSC04,CSC05,CSC06,CSC07,CSC08,CSC09,CSC10,CSC11,CSC12,CSC13,CSC14,CSC15,CSC16);
end
if length(TimeOnTrack)==1
    fprintf(fid,'ExpKeys.TimeOnTrack = %d;\n',TimeOnTrack);
else
    for subsess = 1 : length(TimeOnTrack)
        fprintf(fid,'ExpKeys.TimeOnTrack(%d) = %d;\n',subsess,TimeOnTrack);
    end
end
if length(TimeOffTrack)==1
    fprintf(fid,'ExpKeys.TimeOffTrack = %d;\n',TimeOffTrack);
else
    for subsess = 1 : length(TimeOffTrack)
        fprintf(fid,'ExpKeys.TimeOffTrack(%d) = %d;\n',TimeOffTrack);
    end
end
fprintf(fid,'ExpKeys.Note1 = ''%s'';\n',Note1);
fprintf(fid,'ExpKeys.Note2 = ''%s'';\n',Note2);
fprintf(fid,'ExpKeys.Note3 = ''%s'';\n',Note3);
%----------------
fprintf('Keys file generated. \n');

fclose('all');




