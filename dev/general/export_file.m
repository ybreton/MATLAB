function export_file(fn,F,varargin)
% Writes and exports an ASCII file fn to MATLAB matrix and/or cell arrays of
% strings.
% export_file(fn,F)
% where     F       is a n x m cell array of doubles and strings,
%
%           fn      is the file name of a delimited file with numeric
%                   and/or text data to be exported from MATLAB.
%
% OPTIONAL ARGUMENTS:
% ******************
% delim     (default ',' -> ,)
%   delimiter to be used to differentiate columns.
% txt       (default '''' -> ')
%   delimiter to be used to indicate a cell with text that contains the
%   column delimiter or end-of-line delimiter
% eol       (default '\r\n' -> carriage return-new line)
%   delimiter to be used to indicate the end of a line (row)
% prec      (default [])
%   integer specifying the degree of precision to be used in exporting
%   numeric values; default is MATLAB's num2str.
%

delim = ',';    % Cell delimiter
txt = '''';    % Text delimiter
eol = '\r\n';   % end-of-line character
prec = [];      % precision level
process_varargin(varargin);

F = F(:,:);

fid = fopen(fn,'w');
fprintf('\n')
for iL = 1:size(F,1)
    str = '';
    for iC = 1:size(F,2)
        fprintf('.')
        c = F{iL,iC};
        if ~isnumeric(c)
            idTxt = ~isempty(regexp(c,delim,'once')) || ~isempty(regexp(c,eol,'once'));
            if idTxt
                s = [txt c txt];
            else
                s = c;
            end
        else
            if isempty(prec)
                s = num2str(c);
            else
                s = eval(['fprintf(''%.' num2str(prec) 'f'', c)']);
            end
        end
        str = [str s delim];
    end
    fprintf('\n')
    str = str(1:end-1);
    fprintf(fid, '%s%s', str, eol);
end
fclose(fid);