function fd = FindDirsWithFiles(globfn,varargin)
% Acts like FindFiles, but returns the directories in which the files can
% be found.
%
% OPTIONAL ARGUMENTS:
% ******************
% Unique    (default true)      returns only the unique directories,
%                                   without repetitions.


StartingDirectory = '.';
CheckSubdirs = 1;
Unique = true;
process_varargin(varargin);

fns = FindFiles(globfn, 'StartingDirectory', StartingDirectory, 'CheckSubdirs', CheckSubdirs);

fd = cell(size(fns));
for iFn=1:length(fns)
    fd{iFn} = fileparts(fns{iFn});
end

if Unique
    fd = unique(fd);
end