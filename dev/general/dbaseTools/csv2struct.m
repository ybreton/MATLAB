function S = csv2struct(filename, varargin)
% Converts a table in csv format to a structure array whose fields are the
% columns of the csv.
%
% S = csv2struct(filename)
% where     S           is a structure array,
% 
%           filename    is a character string with the file name to open.
%
% OPTIONAL ARGUMENTS:
% ******************
% align     (default = 'left')
%   When filling rows with incomplete columns, align the csv to the left
%   (filling columns left to right) or to the right (filling columns right
%   to left).
% header    (default = true)
%   Start csv read with a header row indicating the fieldnames of the
%   columns.
% delim     (default = ',')
%   Delimiter indicating different columns of the csv.
% pNumThresh (default = 0.5)
%   Minimum proportion numerical values (out of non-empty rows) to declare
%   column numeric.
% saveFlag  (default = false)
%   Flag indicating that the structure should be saved as struct with
%   filename.mat.
%
%

align = 'left';
header = true;
delim = ',';
pNumThresh = 0.5;
saveFlag = false;
process_varargin(varargin);

fid = fopen(filename,'r');

nCol = nan;
if header
    disp('Opening csv header...')
    l = fgetl(fid);
    id = [0 regexp(l, delim) length(l)+1];
    nCol = length(id) - 1;
    start = id(1:end-1) + 1;
    stop = id(2:end) - 1;
    for col = 1 : nCol
        fname = l(start(col):stop(col));
        fname = strrep(fname, '-', '_');
        fname = strrep(fname, '.', '_');
        fname = strrep(fname, ' ', '_');
        if ~isempty(fname)
            cname{col} = fname;
        else
            cname{col} = sprintf('Index%d',col);
        end
    end
end
k=0;
if ~isnan(nCol)
    data = cell(0,nCol);
end
disp('Reading csv contents...')
l = fgetl(fid);
fprintf('\n');
while ischar(l)
    k = k + 1;
    id = [0 regexp(l, delim) length(l)+1];
    start = id(1:end-1) + 1;
    stop = id(2:end) - 1;
    if isnan(nCol); 
        disp('Using first row for number of columns.')
        data = cell(0,nCol);
        nCol = length(id) - 1; 
    end;
    if mod(k,100)==1
        fprintf('\n');
    end
    fprintf('.');
    
    if strncmpi(align,'l',1)
        clist = 1:nCol;
        start = start(1:end);
        stop = stop(1:end);
    elseif strncmpi(align,'r',1)
        clist = nCol:-1:1;
        start = start(end:-1:1);
        stop = stop(end:-1:1);
    end
    for icol=1:length(start)
        col = clist(icol);
        val = l(start(col):stop(col));
        alpha = [regexpi(val,'[A-Z]') regexpi(val,'_')];
        if strcmpi(val,'NA') || strcmpi(val,'NAN') || strcmpi(val,'N/A')
            alpha=[];
        end
        if isempty(alpha)
            if isempty(val)
                val = [];
            else
                val = str2double(val);
            end
        end
        data{k,col} = val;
    end
    l = fgetl(fid);
end
fprintf('\n');
fclose(fid);

empty = cellfun(@isempty, data);
num = false(size(data));
num(~empty) = cellfun(@isnumeric, data(~empty));


pNum = nansum(num,1)./(nansum(~empty)+eps);
pNum(~isnan(pNum)) = pNum(~isnan(pNum))>=pNumThresh;
pNum(isnan(pNum)) = 1;

for col=1:length(cname)
    if pNum(col)
        val = nan(size(data,1),1);
        for row=1:size(data,1)
            if ~isempty(data{row,col});
                val(row) = data{row,col};
            else
                val(row) = nan;
            end
        end
    else
        val = data(:,col);
    end
    disp(['Field ' cname{col} ': ' num2str(length(val)) ' x 1.'])
    S.(cname{col}) = val;
end

if saveFlag
    [fd,fn] = fileparts(filename);
    fn2 = fullfile(fd,[fn '.mat']);
    disp(['Saving ' fn2])
    save(fn2,'-struct','S')
end
