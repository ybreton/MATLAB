function CA = import_ascii_text(fn,varargin)
% CA = import_ascii_text(fn,varargin)
% VARARGIN:     delim, regex delimiter for columns (default none)
%
%

delim = '';
process_varargin(varargin);

assert(exist(fn,'file')==2,sprintf('File %s not found.',fn));

fid = fopen(fn,'r');

r = 1;
CA = cell(0);
while ~feof(fid)
    lineIn = fgetl(fid);
    
    if ~isempty(delim)
        cols = process_delim_row(lineIn,delim);
    else
        cols{1} = lineIn;
    end
    CA(r,1:length(cols)) = cols;
    r = r + 1;
end

fclose(fid);

function cols = process_delim_row(lineIn,delim)

idDelim = regexp(lineIn,delim);
if isempty(idDelim)
    idDelim = length(lineIn)+1;
    startChar = 1;
    stopChar = length(lineIn);
else
    startChar = [1 idDelim+length(delim)];
    stopChar = [idDelim-1 length(lineIn)];
end

cols = cell(1,length(startChar));
for c = 1 : length(startChar)
    if stopChar(c)<=length(lineIn) & startChar(c)>=1 & stopChar(c)>=1 & startChar(c)<=length(lineIn)
        cols{c} = lineIn(startChar(c):stopChar(c));
    end
end