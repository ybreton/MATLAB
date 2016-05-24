function s = prefixFiles(prefix,fileList,suffix)
% Renames a list of files such that each file is appended a prefix and
% optional suffix.
%
% s = prefixFiles(prefix,fileList)
% s = prefixFiles(prefix,fileList,suffix)
%
% where     s           is n x m x ... x p matrix of status codes
%                           -1 : source not found
%                            0 : destination already exists
%                            1 : succesfully renamed
%   
%           prefix      is a string to prefix to the start of each file
%                           name
%           fileList    is a string or cell array of strings with the file
%                           names to rename; if path is not indicated,
%                           defaults to current folder
%           suffix      is a string to suffix to the end of each file name
%                           (optional)
%
% Example:
% >> prefixFiles('R329-2015-07-20-',FindFiles('*.ntt','CheckSubdirs',false))
%
% renames all files in current directory ending with .ntt extension with 
% prefix 'R329-2015-07-20-', producing the following output:
% 
% 'TT01.ntt' -> 'R329-2015-07-20-TT01.ntt'
% 'TT02.ntt' -> 'R329-2015-07-20-TT02.ntt'
% ...
% 'TT24.ntt' -> 'R329-2015-07-20-TT24.ntt'
% Renaming complete.
%
if nargin<3
    suffix = '';
end

if ischar(fileList)
    fileList = {fileList};
end

s = nan(size(fileList));
for iFn=1:numel(fileList)
    fn = fileList{iFn};
    [d,f,x] = fileparts(fn);
    if isempty(d)
        d0 = pwd;
    else
        d0 = d;
    end
    source = [f x];
    destination = [prefix f suffix x];
    dest = fullfile(d,[prefix f suffix x]);
    if exist(fn,'file')==2
        pushdir(d0);
        if ~exist(destination,'file')==2
            disp([fn '->' dest])
            s(iFn) = movefile(source,destination);
        else
            disp(['Destination file ' fullfile(d0,destination) ' already exists.'])
            s(iFn) = 0;
        end
        popdir;
    else
        disp(['Source file ' fn ' not found.'])
        s(iFn) = -1;
    end
end
disp('Renaming complete.')