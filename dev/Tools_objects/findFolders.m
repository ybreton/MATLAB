function folders = findFolders(regex,varargin)
%
%
%
%

StartingDirectory = '.';
CheckSubdirs = false;
exact = false;
process_varargin(varargin)
cd(StartingDirectory)
prefix = cd;

directories = dir;
k = 0;
folders = cell(0,1);
for d = 1 : length(directories)
    if ~exact
        id = regexpi(directories(d).name,regex);
        ismatch = ~isempty(id);
    else
        ismatch = strcmp(regex,directories(d).name);
    end
    isvalid = directories(d).isdir && strcmp('.',directories(d).name)==0 && strcmp('..',directories(d).name)==0;
    if ismatch && isvalid
        k = k + 1;
        folders{k,1} = [prefix '\' directories(d).name];
    end
    if CheckSubdirs && isvalid
        subdir = directories(d).name;
        subfolders = findFolders(regex,'StartingDirectory',subdir);
        nSubs = length(subfolders);
        nFold = length(folders);
        folders(nFold+1:nFold+nSubs) = subfolders;
    end
    cd(prefix)
end