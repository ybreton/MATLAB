function flist = files(fd)
% returns cell array of all files (non-directories) in specified directory.
% If only one file is present, returns a string.
% flist = files(fd)
%   where   flist is a list of files in directory fd, and
%           fd is the directory to list (default is cd)
%

if nargin < 1
    fd = pwd;
end
contents = dir(fd);
idDirs = arrayfun(@(contents) logical(contents.isdir),contents);
files = contents(~idDirs);
if numel(files)==1
    flist = files.name;
elseif numel(files)>1
    for f = 1 : numel(files)
        flist{f} = files(f).name;
    end
else
    flist = '';
end