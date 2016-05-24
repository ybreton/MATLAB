function moveFilesInProcess(src,dest)
% moveFilesInProcess()
% Moves all promotable files to 
% \\COMPUTERNAME\InProcess
% from current directory.
%
% moveFilesInProcess(src) moves files from src to \\COMPUTERNAME\InProcess.
% moveFilesInProcess(src,dest) moves files from src to dest.
%
%
%
if nargin<2
    dest = ['\\' getenv('computername') '\InProcess'];
end
if nargin<1
    src = pwd;
end

%% Figure out session
try
    SSN = GetSSN();
catch
    disp('No sessions. Skipping.')
    SSN = {};
end

if ischar(SSN)
    SSN = {SSN};
end
wbh = waitbar(0,'initializing');
k = 0;
total = length(SSN)*13;
for iSSN = 1 : length(SSN)
    str = SSN{iSSN};
    idR = min(regexpi(str,'-'));
    Rat = str(1:idR-1);
    ratdir = fullfile(dest, Rat);
    to = fullfile(dest, Rat, str);
    from = fullfile(src, str);
    %% Create directories
    if ~(exist(ratdir,'dir')==7)
        disp(Rat)
        mkdir(ratdir)
    end
    if ~(exist(to,'dir')==7)
        mkdir(to)
    end
    assert(exist(from,'dir')==7,'Source directory does not exist.')
    
    %% Find all of the following and copy:
    pushdir(from);
    disp(['Processing ' from])
    % R*_*_keys.m
    disp('experiment keys files...')
    k=k+1;
    waitbar(k/total,wbh,'Keys...')
    fn = FindFiles('R*_*_keys.m');
    copyFileList(fn,to)
    
    %   R*-sd.mat
    disp('standard session data files...')
    k=k+1;
    waitbar(k/total,wbh,'sd...')
    fn = FindFiles('R*-sd.mat');
    copyFileList(fn,to)

    %   R*-vt.mat
    disp('videotracking data files...')
    k=k+1;
    waitbar(k/total,wbh,'vt...')
    fn = FindFiles('R*-vt.mat');
    copyFileList(fn,to)

    %   R*-CluQual.mat
    disp('cluster quality data files...')
    k=k+1;
    waitbar(k/total,wbh,'CluQual...')
    fn = FindFiles('R*-CluQual.mat');
    copyFileList(fn,to)

    %   R*-wv.mat
    disp('wave data files...')
    k=k+1;
    waitbar(k/total,wbh,'wv...')
    fn = FindFiles('R*-wv.mat');
    copyFileList(fn,to)

    %   RR-*_*.mat
    disp('raw data files...')
    k=k+1;
    waitbar(k/total,wbh,'RR*.mat...')
    fn = FindFiles('RR-*_*.mat');
    copyFileList(fn,to)

    %   R*.ncs
    disp('continuously sampled channel files...')
    k=k+1;
    waitbar(k/total,wbh,'ncs...')
    fn = FindFiles('R*.ncs');
    copyFileList(fn,to)

    %   R*.nev
    disp('neuralynx event files...')
    k=k+1;
    waitbar(k/total,wbh,'nev...')
    fn = FindFiles('R*.nev');
    copyFileList(fn,to)

    %   R*.ntt
    disp('neuralynx tetrode files...')
    k=k+1;
    waitbar(k/total,wbh,'ntt...')
    fn = FindFiles('R*.ntt');
    copyFileList(fn,to)

    %   R*.t
    disp('spike timestamp files...')
    k=k+1;
    waitbar(k/total,wbh,'t...')
    fn = FindFiles('R*.t');
    copyFileList(fn,to)
    fn = FindFiles('R*._t');
    copyFileList(fn,to)

    %   RR-*_*.txt
    disp('summary text files...')
    k=k+1;
    waitbar(k/total,wbh,'txt...')
    fn = FindFiles('RR-*_*.txt');
    copyFileList(fn,to)

    %   R*-TTdepth.csv
    disp('tetrode depth files...')
    k=k+1;
    waitbar(k/total,wbh,'TTdepth...')
    fn = FindFiles('R*-TTdepth.csv');
    copyFileList(fn,to)

    %   R*-VT1.zip
    disp('raw videotracking files...')
    k=k+1;
    waitbar(k/total,wbh,'zip...')
    fn = FindFiles('R*-VT1.zip');
    copyFileList(fn,to)

    popdir;
end
close(wbh)

function copyFileList(lst,dest)
if ischar(lst)
    lst = {lst};
end
for iF = 1 : length(lst)
    fn = lst{iF};
    [~,filename,ext] = fileparts(fn);
    to = fullfile(dest,[filename ext]);
    disp([fn '->' to])
    movefile(fn,to)
end