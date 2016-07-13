function [M, C, F] = import_file(fn,varargin)
% Reads and imports an ASCII file fn to MATLAB matrix and/or cell arrays of
% strings.
% M = import_file(fn)
% [M, C] = import_file(fn)
% [M, C, F] = import_file(fn)
% where     M       is a n x m matrix of doubles,
%           C       is a n x m cell array of strings,
%           F       is a n x m cell array of doubles and strings,
%
%           fn      is the file name of a delimited file with numeric
%                   and/or text data to be imported to MATLAB.
%
% OPTIONAL ARGUMENTS:
% ******************
% delim     (default ',' -> ,)
%   delimiter to be used to differentiate columns.
% txt       (default '''' -> ')
%   delimiter to be used to indicate a cell with text that contains the
%   column delimiter
%

delim = ',';    % Cell delimiter
txt = '''';    % Text delimiter
process_varargin(varargin);

fid = fopen(fn,'r');
ca = cell(0,1);
num = zeros(0,1);
l = fgetl(fid);
k = 1;
fprintf('\n')
while ischar(l);
    fprintf('.')
    [c,n] = parseStr(l, delim, txt);
    ca(k,1:length(c)) = c;
    num(k,1:length(n)) = n;
    l = fgetl(fid);
    k = k+1;
end
fprintf('\n')
fclose(fid);

empty = cellfun(@isempty,ca);

if nargout==0
    M = cell(size(ca));
    idF = find(~empty);
    for id = idF(:)'
        M{id} = ca{id};
    end
end

if nargout>0
    M = nan(size(ca));
    idM = find(~empty&num);
    for id = idM(:)'
        M(id) = str2double(ca{id});
    end
end

if nargout>1
    C = cell(size(ca));
    idC = find(~empty&~num);
    for id = idC(:)'
        C{id} = ca{id};
    end
end

if nargout>2
    F = cell(size(ca));
    idF = find(~empty);
    for id = idF(:)'
        F{id} = ca{id};
    end
end

function [c, num] = parseStr(str,delim,txt)
tid = regexp(str,txt);
if mod(length(tid),2)==1
    tid(end+1) = length(txt);
end
tid = reshape(tid,2,numel(tid)/2);

cid = [0,regexp(str,delim),length(str)+1];
quoted = nan(length(cid),1);
for iC=1:length(cid)
    quoted(iC) = any(cid(iC)>tid(1,:) & cid(iC)<tid(2,:));
end
cid = cid(~quoted);

c = cell(1,length(cid)-1);
num = false(1,length(cid)-1);
for iC=1:length(cid)-1
    s = str(cid(iC)+1:cid(iC+1)-1);
    c{iC} = s;
    id = 1:length(s);
    idnum = regexp(s,'[0-9]');
    nonnum = any(~ismember(id,idnum));
    num(iC) = ~nonnum;
end