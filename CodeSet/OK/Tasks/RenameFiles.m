
function [ ] = RenameFiles(varargin)
% 2011/01/01 AndyP
% Modified from code by AdamS
% Rename files (.ntt, .CSC, .Nev) from Cheetah data for Cutting or Promotion
%2011/03/13 AndyP added disp commands
%2011/03/24 AndyP added copyfile command.  Program no longer crashes when
%a file has already been renamed.  Added Temp = dir serach and conditional
%statements.  Streamlines code.
%2011-09-19 AEP added renaming for mpg and smi files





[~, SSNstr, ~] = fileparts(pwd);

CSC1 = 'a';
CSC2 = 'a';
CSC3 = 'a';
CSC4 = 'a';
CSC5 = 'a';
CSC6 = 'a';
CSC7 = 'a';
CSC8 = 'a';
CSC9 = 'a';
CSC10 = 'a';
CSC11 = 'a';
CSC12 = 'a';
CSC13 = 'r1';
CSC14 = 'r2';
CSC15 = 'eeg';
CSC16 = 'r1r2';

process_varargin(varargin);
RenamedSomething = 0;


%% Rename Keys File

Temp = dir('*keys.m');
if exist(Temp.name, 'file')>=1 && ~strcmp(Temp.name,strcat(strrep(SSNstr, '-', '_'), '_keys.m'));
	RenamedSomething=1;
	disp('Renaming keys file');
	File=Temp.name;
	name = strcat(strrep(SSNstr, '-', '_'), '_keys.m');
	java.io.File(File).renameTo(java.io.File(name));
end

%% Rename events and mat file
Temp = dir('*.Nev');
if exist(Temp.name, 'file')>=1 && ~strcmp(Temp.name,strcat(SSNstr, '-Events.Nev'));
	RenamedSomething =1;
	disp('Renaming events file.');
	File= Temp.name;
	java.io.File(File).renameTo(java.io.File(strcat(SSNstr, '-Events.Nev')));
end

Temp = dir('DD*.mat');
if exist(Temp.name, 'file')>=1 && ~strcmp(Temp.name,strcat(SSNstr, '-DD.mat'));
	RenamedSomething =1;
	disp('Renaming DD.mat file.');
	File= Temp.name;
	java.io.File(File).renameTo(java.io.File(strcat(SSNstr, '-DD.mat')));
end

%% Rename VideoTracker Files
Temp = dir('*vt1.mat');
if exist(Temp.name, 'file')>=1 && ~strcmp(Temp.name,strcat(SSNstr, '-vt1.mat'));
	RenamedSomething =1;
	disp('Renaming vt1.mat');
	File= Temp.name;
	java.io.File(File).renameTo(java.io.File(strcat(SSNstr, '-vt1.mat')));
end

Temp = dir('*vt2.mat');
if exist(Temp.name, 'file')>=1 && ~strcmp(Temp.name,strcat(SSNstr, '-vt2.mat'));
	RenamedSomething =1;
	disp('Renaming vt2.mat');
	File= Temp.name;
	java.io.File(File).renameTo(java.io.File(strcat(SSNstr, '-vt2.mat')));
end

Temp = dir('*1.Nvt');
if exist(Temp.name, 'file')>=1 && ~strcmp(Temp.name,strcat(SSNstr, '-VT1.Nvt'));
	RenamedSomething =1;
	disp('Renaming VT1.Nvt');
	File= Temp.name;
	java.io.File(File).renameTo(java.io.File(strcat(SSNstr, '-VT1.Nvt')));
end

Temp = dir('*2.Nvt');
if exist(Temp.name, 'file')>=1 && ~strcmp(Temp.name,strcat(SSNstr, '-VT2.Nvt'));
	RenamedSomething =1;
	disp('Renaming VT2.Nvt');
	File= Temp.name;
	java.io.File(File).renameTo(java.io.File(strcat(SSNstr, '-VT2.Nvt')));
end

Temp = dir('*1.zip');
if exist(Temp.name, 'file')>=1 && ~strcmp(Temp.name,strcat(SSNstr, '-VT1.zip'));
	RenamedSomething =1;
	disp('Renaming VT1.zip');
	File= Temp.name;
	java.io.File(File).renameTo(java.io.File(strcat(SSNstr, '-VT1.zip')));
end

Temp = dir('*2.zip');
if exist(Temp.name, 'file')>=1 && ~strcmp(Temp.name,strcat(SSNstr, '-VT2.zip'));
	RenamedSomething =1;
	disp('Renaming VT2.zip');
	File= Temp.name;
	java.io.File(File).renameTo(java.io.File(strcat(SSNstr, '-VT2.zip')));
end

%% Rename mpg files
Temp = dir('*VT1.mpg');
if exist(Temp.name, 'file')>=1 && ~strcmp(Temp.name,strcat(SSNstr, '-VT1.mpg'));
	RenamedSomething =1;
	disp('Renaming VT1.mpg');
	File = Temp.name;
	java.io.File(File).renameTo(java.io.File(strcat(SSNstr, '-VT1.mpg')));
end

Temp = dir('*VT1_01.mpg');
if exist(Temp.name, 'file')>=1 && ~strcmp(Temp.name,strcat(SSNstr, '-VT1_01.mpg'));
	RenamedSomething =1;
	disp('Renaming VT1.mpg');
	File = Temp.name;
	java.io.File(File).renameTo(java.io.File(strcat(SSNstr, '-VT1_01.mpg')));
end

Temp = dir('*VT1_02.mpg');
if exist(Temp.name, 'file')>=1 && ~strcmp(Temp.name,strcat(SSNstr, '-VT1_02.mpg'));
	RenamedSomething =1;
	disp('Renaming VT1.mpg');
	File = Temp.name;
	java.io.File(File).renameTo(java.io.File(strcat(SSNstr, '-VT1_02.mpg')));
end

Temp = dir('*VT2.mpg');
if exist(Temp.name, 'file')>=1 && ~strcmp(Temp.name,strcat(SSNstr, '-VT2.mpg'));
	RenamedSomething =1;
	disp('Renaming VT2.mpg');
	File = Temp.name;
	java.io.File(File).renameTo(java.io.File(strcat(SSNstr, '-VT2.mpg')));
end

Temp = dir('*VT2_01.mpg');
if exist(Temp.name, 'file')>=1 && ~strcmp(Temp.name, strcat(SSNstr, '-VT2_01.mpg'));
	RenamedSomething =1;
	disp('Renaming VT2.mpg');
	File = Temp.name;
	java.io.File(File).renameTo(java.io.File(strcat(SSNstr, '-VT2_01.mpg')));
end

Temp = dir('*VT2_02.mpg');
if exist(Temp.name, 'file')>=1 && ~strcmp(Temp.name, strcat(SSNstr, '-VT2_02.mpg'));
	RenamedSomething =1;
	disp('Renaming VT2.mpg');
	File = Temp.name;
	java.io.File(File).renameTo(java.io.File(strcat(SSNstr, '-VT2_02.mpg')));
end

Temp = dir('*VT1.smi');
if exist(Temp.name, 'file')>=1 && ~strcmp(Temp.name,strcat(SSNstr, '-VT1.smi'));
	RenamedSomething =1;
	disp('Renaming VT1.smi');
	File = Temp.name;
	java.io.File(File).renameTo(java.io.File(strcat(SSNstr, '-VT1.smi')));
end

Temp = dir('*VT1_01.smi');
if exist(Temp.name, 'file')>=1 && ~strcmp(Temp.name,strcat(SSNstr, '-VT1_01.smi'));
	RenamedSomething =1;
	disp('Renaming VT1.smi');
	File = Temp.name;
	java.io.File(File).renameTo(java.io.File(strcat(SSNstr, '-VT1_01.smi')));
end

Temp = dir('*VT1_02.smi');
if exist(Temp.name, 'file')>=1 && ~strcmp(Temp.name,strcat(SSNstr, '-VT1_02.smi'));
	RenamedSomething =1;
	disp('Renaming VT1.smi');
	File = Temp.name;
	java.io.File(File).renameTo(java.io.File(strcat(SSNstr, '-VT1_02.smi')));
end

Temp = dir('*VT2.smi');
if exist(Temp.name, 'file')>=1 && ~strcmp(Temp.name,strcat(SSNstr, '-VT2.smi'));
	RenamedSomething =1;
	disp('Renaming VT2.smi');
	File = Temp.name;
	java.io.File(File).renameTo(java.io.File(strcat(SSNstr, '-VT2.smi')));
end

Temp = dir('*VT2_01.smi');
if exist(Temp.name, 'file')>=1 && ~strcmp(Temp.name,strcat(SSNstr, '-VT2_01.smi'));
	RenamedSomething =1;
	disp('Renaming VT2.smi');
	File = Temp.name;
	java.io.File(File).renameTo(java.io.File(strcat(SSNstr, '-VT2_01.smi')));
end

Temp = dir('*VT2_02.smi');
if exist(Temp.name, 'file')>=1 && ~strcmp(Temp.name,strcat(SSNstr, '-VT2_02.smi'));
	RenamedSomething =1;
	disp('Renaming VT2.smi');
	File = Temp.name;
	java.io.File(File).renameTo(java.io.File(strcat(SSNstr, '-VT2_02.smi')));
end
%% Rename TT Files
for number=1:12
	numstr=num2str(number);
	
	%Format TT numbers one through nine with a leading zero 01, 02, ...
	if number < 10
		formatnumstr=['0' numstr];
	else
		formatnumstr=numstr;
	end
	
	
	if exist(cat(2,'Sc',numstr,'.ntt'), 'file')>=1 || exist(cat(2,'TT',numstr,'.ntt'), 'file')>=1
		fprintf(strcat('Renaming TT',formatnumstr, '\n'));
		NTTFile=[dir(cat(2,'Sc',numstr,'.ntt')) dir(cat(2,'TT',numstr,'.ntt'))];
		NTTstr=[SSNstr '-TT' formatnumstr];
		File=NTTFile(1).name;
		java.io.File(File).renameTo(java.io.File(strcat(NTTstr, '.ntt')));
	end
end

%% Rename CSC Files
%All .csc files are named Rrrrr-yyyy-mm-dd-CSCttx.ncs (where tt is 01 to 12
%[you will need to look at the experiment sheet to find which tetrode the
%CSC was recorded from; and x is a/b/c/d referring to the channel from
%which the csc was recorded).
Refs = {CSC1, CSC2, CSC3, CSC4, CSC5, CSC6, CSC7, CSC8, CSC9, CSC10, CSC11, CSC12, CSC13, CSC14, CSC15, CSC16};
for number=1:16
	
	numstr=num2str(number);
	
	%Format CSC numbers one through nine with a leading zero 01, 02, ...
	if number < 10
		formatnumstr=['0' numstr];
	else
		formatnumstr=numstr;
	end
	
	
	ch = Refs{number};
	if exist(cat(2,'CSC',numstr,'.Ncs'), 'file')>=1
		if nargin==0; warning('Using default CSC channel format.');
			RenamedSomething =1;
			fprintf(strcat('Renaming CSC',formatnumstr, '\n'));
			NCSFile=dir(cat(2,'CSC',numstr,'.Ncs'));
			NCSstr=[SSNstr '-CSC' formatnumstr ch];
			File=NCSFile(1).name;
			java.io.File(File).renameTo(java.io.File(strcat(NCSstr, '.Ncs')));
		end
	end
end
%%

if RenamedSomething == 0,
	disp('No files were found to be renamed.');
end


end