function copyTfiles(src,dest)
% Copies .T and ._T files to destination directory (segregated by SSN) for
% easier burning to DVD.
%
%
%

if nargin<2
    dest = fullfile('\\adrlab21', 'InProcess');
end
if nargin<1
    src = pwd;
end

pushdir(src);

try
    SSN = GetSSN();
catch
    disp('No sessions. Skipping.')
    SSN = {};
end
if ischar(SSN)
    SSN = {SSN};
end

for iSSN=1:length(SSN)
    fd = SSN{iSSN};
    pushdir(fd);
    disp(fd)
    fn1 = FindFiles('*.t');
    fn2 = FindFiles('*._t');
    fn3 = FindFiles('*-wv.mat');
    fn4 = FindFiles('*-CluQual.mat');
    fn5 = FindFiles('*.clusters');
    to = fullfile(dest,fd);
    if ~(exist(to,'dir')==7)
        mkdir(dest,fd)
    end
    
    if ~isempty(fn1)
        copyFileList(fn1,to);
        pause(1)
    end
    
    if ~isempty(fn2)
        copyFileList(fn2,to);
        pause(1)
    end
    
    if ~isempty(fn3)
        copyFileList(fn3,to);
        pause(1)
    end
    
    if ~isempty(fn4)
        copyFileList(fn4,to);
        pause(1)
    end
    
    if ~isempty(fn5)
        copyFileList(fn5,to);
        pause(1)
    end
    
    pause(0.1)
    popdir;
end

popdir;

function copyFileList(lst,dest)
if ischar(lst)
    lst = {lst};
end
for iF = 1 : length(lst)
    fn = lst{iF};
    [~,filename,ext] = fileparts(fn);
    to = fullfile(dest,[filename ext]);
    disp([fn '->' to])
    copyfile(fn,to)
end