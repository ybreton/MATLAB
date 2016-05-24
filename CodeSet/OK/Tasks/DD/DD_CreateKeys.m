function [] = DD_CreateKeys(varargin)
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
% ExpKeys.Target          2x1 cell array of strings, tetrode target structure (e.g. HC, OFC, vStr)
% ExpKeys.Target2         2x1 cell array of strings, subtarget region (e.g. CA1, medial, right-side)
% ExpKeys.TetrodeDepths   Nx1 double, estimated depth turned of each tetrode in microns
% ExpKeys.TetrodeTargets  Nx1 double, 0 indicates tetrode Target #1, 1 indicates tetrode Target #2
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
Behavior = [];         %the behavioral task
Protocol = [];         % behavior, hyperdrive recording, pharmacology, etc
Target = [];           % tetrode target structure (e.g. HC, OFC, vStr)
Target2 = [];          % second tetrode target structure
Target3 = [];
Target4 =[];
TetrodeDepths = [];  % estimated depth turned of each tetrode in microns
TetrodeTargets = []; % 0 indicates tetrode Target #1, 1 indicates tetrode Target #2
CSCReference = [];   % Enter 1,2,..,14 for the tetrode which the CSC channel was referenced during recording
TimeOnTrack = [];
TimeOffTrack = [];
HasHCTheta = [];     % 1 indicates an auxilliary HC theta electrode was included.  This affects the patch panel configuration on Cheetah.
PostFeed = [];
PelletRatio = [];   % Delay discounting has two different sized pellet-rewards. Default procedure is 3 pellets :1 pellet.
Tones =  [];         % 1 indicates an audible musical scale 'countdown' accompanied the delays
Blocks = [];
Nudges = [];
Weight = [];         % the weight of the rat in grams
Note1=[];            % document any unusual events, task malfunctions, or unusual behavior (e.g. lost tracking lap 20, feeder misfires lap 20, ghost pixels, rat fell off track lap 20 etc).
Note2=[];
Note3=[];
RF = [];
LF = [];
%----------------
[~,SSN,~]=fileparts(pwd);
process_varargin(varargin);
ok = false;
%----------------
if isempty(Behavior);
	while ~ok
		Behavior = input('Enter Behavioral Task            ', 's');
		if isempty(Behavior); ok=0; fprintf('invalid input \n'); else ok=1; end
	end
	ok = false;
end


if isempty(Protocol);
	while ~ok
		Protocol = input('Enter Hyperdrive or Behavior     ', 's');
		if isempty(Protocol) || ~strcmp(Protocol,'Behavior') && ~strcmp(Protocol,'Hyperdrive'); ok=0; fprintf('invalid input \n');  else ok=1; end
	end
	ok = false;
end

%%%%%%%%%%%%%%%%%%%
% behavioral keys %
%%%%%%%%%%%%%%%%%%%
if isempty(PelletRatio);
	while ~ok
		PelletRatio = input('Pellets delivered on delayed side:      ','s');
		if isempty(PelletRatio); ok=0; fprintf('invalid input \n');
		else PelletRatio=str2double(PelletRatio);
			ok=1;
		end
	end
	ok = false;
end
%----------------
if isempty(Weight);
	while ~ok
		Weight = input('Weight    ', 's'); Weight = str2double(Weight);
		if isempty(Weight) || isnan(Weight); ok=0; fprintf('invalid input \n');  else ok=1; end
	end
	ok = false;
end
%----------------
if isempty(Tones);
	while ~ok
		Tones = input('Were there tones? ("1"=yes, "0"=no):    ', 's'); Tones=str2double(Tones);
		if Tones~=0 && Tones~=1; ok=0; fprintf('invalid input \n');  else ok=1; end
	end
	ok = false;
end

%----------------
if isempty(Blocks);
	while ~ok
		Blocks = input('Enter # of Blocks    ', 's'); Blocks = str2double(Blocks);
		if isempty(Blocks) || isnan(Blocks); ok=0; fprintf('invalid input \n'); else ok=1; end
	end
	ok = false;
end

%----------------
if isempty(Nudges);
	while ~ok
		Nudges = input('Enter # of Nudges    ', 's'); Nudges = str2double(Nudges);
		if isempty(Nudges) || isnan(Nudges); ok=0; fprintf('invalid input \n'); else ok=1; end
	end
	ok = false;
end

%----------------
if isempty(PostFeed);
	while ~ok
		PostFeed = input('Enter PostFeed (g):    ', 's'); PostFeed = str2double(PostFeed);
		if isempty(PostFeed) || isnan(PostFeed); ok=0; fprintf('invalid input \n'); else ok=1; end
	end
	ok = false;
end

%----------------

if isempty(TimeOnTrack); TimeOnTrack = input('Enter TimeOnTrack (s)         ','s');
	TimeOnTrack = floor(str2double(TimeOnTrack));
	if isempty(TimeOnTrack) || isnan(TimeOnTrack); TimeOnTrack = NaN; warning('TimeOnTrack not entered'); end
end
%----------------
if isempty(TimeOffTrack); TimeOffTrack = input('Enter TimeOffTrack (s)         ','s');
	TimeOffTrack = floor(str2double(TimeOffTrack));
	if isempty(TimeOffTrack) || isnan(TimeOffTrack); TimeOffTrack = NaN; warning('TimeOnTrack not entered'); end
end
%----------------
if isempty(RF);
	while ~ok
		RF = input('Enter Right Feeder1:         ','s'); RF=str2double(RF);
		if isempty(RF) || isnan(RF); ok=0; fprintf('invalid input \n'); else ok=1; end
	end
	ok = false;
end

if isempty(LF);
	while ~ok
		LF = input('Enter Left Feeder1:         ','s'); LF=str2double(LF);
		if isempty(LF) || isnan(LF); ok=0; fprintf('invalid input \n'); else ok=1; end
	end
	ok = false;
end

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
		while ~ok
			Target = input('Recording Target #1    ', 's');
			if isempty(Target); ok=0; fprintf('invalid input \n'); else ok=1; end
		end
		ok = false;
	end
	%----------------
	if isempty(Target2); Target2 = input('Recording Target #2   ', 's');
		if isempty(Target2); Target2= 'nan'; end
	end
	%----------------
	if isempty(Target3); Target3 = input('Subtarget #1   ', 's');
		if isempty(Target3); Target3= 'nan'; end
	end
	%----------------
	if isempty(Target4); Target4 = input('Subtarget #2  ', 's');
		if isempty(Target4); Target4= 'nan'; end
	end
	%----------------
	if  isempty(TetrodeTargets);
		while ~ok
			if strcmp(Target2, 'nan')==1; TetrodeTargets = '0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0';
			else TetrodeTargets = input('For each TT, input "0" for Target#1 or "1" for Target#2. \n  Separate with spaces:  ', 's');
			end
			if isempty(TetrodeTargets); ok=0; fprintf('invalid input \n'); else ok=1; end
		end
		ok = false;
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
	if isempty(TetrodeDepths);
		TetrodeDepths= input('Input depth in um for each TT (usually 14 TTs) \n  Separate with spaces:  ', 's');
		if isempty(TetrodeDepths); TetrodeDepths= 'nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan'; end
	end
	% parse CSC input
	space = regexp(CSCReference, '\s');
	if length(space)==15;
		CSC01 = CSCReference(1:space(1));
		CSC02 = CSCReference(space(1):space(2));
		CSC03 = CSCReference(space(2):space(3));
		CSC04 = CSCReference(space(3):space(4));
		CSC05 = CSCReference(space(4):space(5));
		CSC06 = CSCReference(space(5):space(6));
		CSC07 = CSCReference(space(6):space(7));
		CSC08 = CSCReference(space(7):space(8));
		CSC09 = CSCReference(space(8):space(9));
		CSC10 = CSCReference(space(9):space(10));
		CSC11 = CSCReference(space(10):space(11));
		CSC12 = CSCReference(space(11):space(12));
		CSC13 = CSCReference(space(12):space(13));
		CSC14 = CSCReference(space(13):space(14));
		CSC15 = CSCReference(space(14):space(15));
		CSC16 = CSCReference(space(15):end);
	else
		warning('unknown number of CSC channels, CSC reference in keys file may not be valid');
	end
end
%%%%%%%%%%%%%%%%%%%
% generate keys.m %
%%%%%%%%%%%%%%%%%%%
fout = cat(2,SSN,'_keys.m');
fout = regexprep(fout,'-','_');
fid = fopen(fout,'w');
%populate keys.m
fprintf(fid,'ExpKeys.Behavior = ''%s'';\n',Behavior);
fprintf(fid,'ExpKeys.Protocol = ''%s'';\n',Protocol);
fprintf(fid,'ExpKeys.PelletRatio = %d;\n',PelletRatio);
fprintf(fid,'ExpKeys.Tones = %d;\n',Tones);
fprintf(fid,'ExpKeys.Weight = %0.1f;\n',Weight);
fprintf(fid,'ExpKeys.FeederR1 = %d;\n', RF);
fprintf(fid,'ExpKeys.FeederL1 = %d;\n', LF);
fprintf(fid,'ExpKeys.Blocks = %d;\n', Blocks);
fprintf(fid,'ExpKeys.Nudges = %d;\n', Nudges);
fprintf(fid,'ExpKeys.PostFeed = %0.1f;\n', PostFeed);
if strcmp(Protocol,'Hyperdrive');
	fprintf(fid,'ExpKeys.Target = {''%s'',''%s''};\n',Target,Target2);
	fprintf(fid,'ExpKeys.Target2 = {''%s'',''%s''};\n',Target3,Target4);
	fprintf(fid,'ExpKeys.TetrodeTargets = [%s];\n',sprintf('%s',TetrodeTargets));
	fprintf(fid,'ExpKeys.TetrodeDepths = [%s]; \n',sprintf('%s', TetrodeDepths));
	fprintf(fid,'ExpKeys.HasHCTheta = %d;\n',HasHCTheta);
	fprintf(fid,'ExpKeys.CSCReference = {''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s''};\n', CSC01,CSC02,CSC03,CSC04,CSC05,CSC06,CSC07,CSC08,CSC09,CSC10,CSC11,CSC12,CSC13,CSC14,CSC15,CSC16);
end
fprintf(fid,'ExpKeys.TimeOnTrack = %d;\n',TimeOnTrack);
fprintf(fid,'ExpKeys.TimeOffTrack = %d;\n',TimeOffTrack);
fprintf(fid,'ExpKeys.Note1 = ''%s'';\n',Note1);
fprintf(fid,'ExpKeys.Note2 = ''%s'';\n',Note2);
fprintf(fid,'ExpKeys.Note3 = ''%s'';\n',Note3);
%----------------
fprintf('Keys file generated. \n');

fclose('all');



