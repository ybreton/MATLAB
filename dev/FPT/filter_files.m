function filteredList = filter_files(fileList,inclusion,exclusion)
% filters the list of files according to all inclusion criteria and any
% exclusion criteria.
% filteredList = filter_files(fileList,inclusion,exclusion)
%   where   fileList is the list to be filtered
%           inclusion is a cell array of regexp's to include
%               (default is empty--include all)
%           exclusion is a cell array of regexp's to exclude
%               (default is empty--exclude all)
%

if ischar(fileList)
    fileList{1} = fileList;
end
if nargin < 3
    exclusion = cell(0);
end
if nargin < 2
    inclusion = cell(0);
end
if ischar(inclusion)
    str = inclusion;
    inclusion = cell(1);
    inclusion{1} = str;
end
if ischar(exclusion)
    str = exclusion;
    exclusion = cell(1);
    exclusion{1} = str;
end

for f = 1 : numel(fileList)
    fn = fileList{f};
    inc = true;
    crit = 1;
    % test each inclusion criterion.
    while crit<=numel(inclusion)
        inc = ~isempty(regexpi(fn,inclusion{crit})) & inc;
        crit = crit + 1;
    end
    if inc
        exc = false;
        crit = 1;
        while ~exc && crit<=numel(exclusion)
            exc = ~isempty(regexpi(fn,exclusion{crit})) | exc;
            crit = crit + 1;
        end
    else
        exc = 1;
    end
    addToList(f) = inc & ~exc;
end
filteredList = fileList(addToList);