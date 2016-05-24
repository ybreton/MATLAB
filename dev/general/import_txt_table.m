function varargout = import_txt_table(fn,varargin)
% Imports an ASCII encoded text table.
% varargout = import_txt_table(fn,{options})
% where     varargout is a list of output tables,
%           fn is a file name or cell array of files to import
% options:
%           delim       column delimiter (default is comma-space ', ')
%           headers     first line contains column headers
%

delim = ', ';
headers = true;
process_varargin(varargin)

if ischar(fn)
    fn0{1} = fn;
    clear fn
    fn = fn0;
end
fn = fn(:);

for f = 1 : length(fn)
    % Open file for reading.
    fid=fopen(fn{f},'r');
    
    tline = fgetl(fid);
    id = regexpi(tline,delim);
    % each time the delimiter is encountered, make it a new column.
    id = [0 id length(tline)];
    for c = 1 : length(id)-1
        start = id(c)+1;
        finish = id(c+1)-length(delim);
        str0 = tline(start:finish);
        str = strrep(str0,'"','');
        line1{c} = str;
    end
    DATA = cell(0,size(line1,2));
    if headers
        HEADER = line1;
        k = 1;
    else
        DATA(1,:) = line1;
        HEADER = cell(1,size(line1,2));
        k = 2;
    end
    while ischar(tline)
        tline = fgetl(fid);
        if ischar(tline)
            id = regexpi(tline,delim);
            % each time the delimiter is encountered, make it a new column.
            id = [0 id length(tline)];
            linek = cell(1,length(id)-1);
            for c = 1 : length(id)-1
                start = id(c)+1;
                finish = id(c+1);
                str0 = tline(start:finish);
                str = strrep(str0,'"','');
                str = strrep(str,' ','');
                linek{c} = str;
            end
            DATA(k,1:length(linek)) = linek;
            k = k+1;
        end
    end
    
    Table.HEADER = HEADER;
    Table.DATA = DATA;
    Table.NAME = fn{f};
    
    fclose(fid);
    varargout{f} = Table;
end