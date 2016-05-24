function [status,message,messageid] = movefiles(fileList,destination)
% Moves files in fileList to directory "destination".
% [status,message,messageid] = movefiles(fileList,destination)
% where     status, message, messageid      are identifiers from the movefile operation indicating success of movefile
%           
%           fileList                        is n x 1 cell array of files to move
%           destination                     is character string of destination
%                                               (if no path delimiters are
%                                               found, defaults to
%                                               subdirectory of current
%                                               directory.)
% example:
% >> movefiles(FindFiles('*.fd','Checksubdirs',0),'fd')
% moves all files in current directory ending with .fd extension to
% subdirectory "fd" of current directory.
%
% >> movefiles(FindFiles('*.fd'),'fd')
% moves all files in current and children of current ending with .fd to
% subdirectory "fd" of current directory.
%
% >> cd('R358-2016-01-31');
% >> movefiles(FindFiles('*.*'),'\\SERVER\data\R358\R358-2016-01-31')
% moves all files in directory "R358-2016-01-31" to folder accessible at
% "\\SERVER\data\R358\R358-2016-01-31".
%
% See documentation on movefile for meaning of status, message, and
% messageid output arguments.
%

if ischar(fileList)
    fileList = {fileList};
end

if isempty(regexpi(destination,'/'))&&isempty(regexpi(destination,'\'))
    destination = fullfile(pwd, destination);
end

if ~(exist(destination,'dir')==7)
    mkdir(destination)
end

h = waitbar(0,'Copying files');
set(get(get(h,'children'),'title'),'interpreter','none')

s = nan(length(fileList),1);
m = cell(length(fileList),1);
mid = cell(length(fileList),1);
for iF=1:length(fileList)
    disp([fileList{iF} '->' destination])
    [~,fn,ext] = fileparts(fileList{iF});
    try
        [s(iF),m{iF},mid{iF}]=movefile(fileList{iF},destination);
    catch exception
        disp(['Error moving ' fileList{iF} ':'])
        disp(exception.message)
    end
    waitbar(iF/length(fileList),h,sprintf('%s',[fn ext]))
end
close(h);

if nargout>0
    status = s;
end
if nargout>1
    message = m;
end
if nargout>2
    messageid = mid;
end