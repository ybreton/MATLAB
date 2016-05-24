function [] = CreateFPTKeys(TOnT, TOffT, varargin)
% 2012-05-10 AndyP. Reformatted by JJS. 2012-07-23
% Create a keys.mat file for one behavioral session through a series of
% user-inputs
% CreateFPTKeys();
% Variables in Keys File
% ExpKeys.Behavior        string, the behavioral task
% ExpKeys.Protocol        string, 'Behavior' or 'Hyperdrive'
% ExpKeys.PelletRatio
% ExpKeys.Tones           1x1 double, 1 if tone cues used during task
% ExpKeys.Blocks          1x1 double, the number of blocks used
% ExpKeys.Nudges          1x1 double, the number of nudges used
% ExpKeys.Weight          1x1 double, the weight of the rat [grams]
% ExpKeys.Note1           string, experimental note #1  (Note: Do NOT use apostraphes ')
% ExpKeys.Note2
% ExpKeys.Note3
Behavior = [];         %the behavioral task
Protocol = [];         % behavior, hyperdrive recording, pharmacology, etc
PostFeed = [];
PelletRatio = [];   % Delay discounting has two different sized pellet-rewards. Default procedure is 3 pellets :1 pellet.
Tones =  1;         % 1 indicates an audible musical scale 'countdown' accompanied the delays
Blocks = [];
Nudges = [];
Weight = [];         % the weight of the rat in grams
Notes = [];          % document any unusual events, task malfunctions, or unusual behavior (e.g. lost tracking lap 20, feeder misfires lap 20, ghost pixels, rat fell off track lap 20 etc).
SkipNotes = false;   % if no notes are explicitly entered, no notes to be included.
%----------------
[~,SSN,~]=fileparts(pwd);
process_varargin(varargin);
TimeOnTrack = TOnT;
TimeOffTrack = TOffT;
%----------------
if isempty(Behavior); Behavior = 'DD-CE'; fprintf('Default: Behavior = ''DD-CE'' \n'); end
if isempty(Protocol); Protocol = 'FPT'; fprintf('Default: Behavior = ''FPT'' \n'); end
%----------------
%%%%%%%%%%%%%%%%%%%
% behavioral keys %
%%%%%%%%%%%%%%%%%%%
load(strcat(SSN,'-DD.mat'));
if World.nPleft > World.nPright;
    PelletRatio = World.nPleft;
else
    PelletRatio = World.nPright;
end
%----------------
if isempty(Weight);
	Weight = input('Weight    ', 's'); Weight = str2double(Weight);
	if isempty(Weight); Weight=NaN; end
end
%----------------
if isempty(Tones); Tones = 1; fprintf('Default: Tones = 1 \n'); end
%----------------
if isempty(Blocks); Blocks = input('Enter # of Blocks    ', 's'); Blocks = str2double(Blocks);
	if isempty(Blocks); Blocks = NaN; end
end
%----------------
if isempty(Nudges); Nudges = input('Enter # of Nudges    ', 's'); Nudges = str2double(Nudges);
	if isempty(Nudges); Nudges = NaN; end
end
%----------------
if isempty(PostFeed); PostFeed = input('Enter PostFeed (g)    ', 's'); PostFeed = str2double(PostFeed);
	if isempty(PostFeed); PostFeed = NaN; end
end
%----------------
% generate notes.
if isempty(Notes)&&~SkipNotes;
	Notes = input('Any additional Notes about this session? (skip if none)    ', 's');
	if isempty(Notes)
		Notes= '';
    end
elseif isempty(Notes)&&SkipNotes
    Notes = '';
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
fprintf(fid,'ExpKeys.Blocks = %d;\n', Blocks);
fprintf(fid,'ExpKeys.Nudges = %d;\n', Nudges);
fprintf(fid,'ExpKeys.PostFeed = %0.1f;\n', PostFeed);
fprintf(fid,'ExpKeys.TimeOnTrack = %f;\n',TimeOnTrack);
fprintf(fid,'ExpKeys.TimeOffTrack = %f;\n',TimeOffTrack);
fprintf(fid,'ExpKeys.FeederR1 = 0;\n');
fprintf(fid,'ExpKeys.FeederL1 = 1;\n');
fprintf(fid,'ExpKeys.Notes = ''%s'';\n',Notes);
%----------------
fprintf('Keys file generated. \n');

fclose('all');



