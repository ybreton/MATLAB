function [status,message,messageid] = fileNumericFormat(fileList,varargin)
% Renames files with numbers according to sprintf numeric format.
%
% fileNumericFormat(fileList,n1,n2,...)
% [status,message,messageid] = fileNumericFormat(fileList,n1,n2,...)
% where     status, message, messageid are returned by movefile
%
%           fileList        is a m x n x ... x p cell array of file names
%           n1, n2, ...     are format specs for each number encountered in
%                               the file name, repeating if more numbers
%                               are found in the file name than there are
%                               format specs. See documentation on sprintf
%                               for usage of format specs.
%
% Example:
% >> fileNumericFormat(FindFiles('*.ntt'),'%02d')
%
% will rename files ending with .ntt extension such that the numbers will
% be represented as signed integers with 0's padding the two first digits.
%
% TT1.ntt -> TT01.ntt
% TT10.ntt -> TT10.ntt
% ...
% TT2.ntt -> TT02.ntt
% TT20.ntt-> TT20.ntt
% ...
% TT9.ntt -> TT09.ntt
%
%

if ischar(fileList)
    fileList = {fileList};
end

s = nan(size(fileList));
message = cell(size(fileList));
messageid = cell(size(fileList));
for iF=1:numel(fileList)
    fn = fileList{iF};
    [d,f,x] = fileparts(fn);
    if isempty(d)
        d = pwd;
    end
    
    f2 = parseString(f,varargin);
    
    if exist(fn,'file')==2
        pushdir(d);
        disp(d);
        source = fullfile(d,[f x]);
        destination = fullfile(d,[f2 x]);
        
        disp([f x ' -> ' f2 x]);
        s(iF) = movefile(source,destination);
        
        popdir;
    else
        s(iF)=-1;
        message{iF} = 'File not found.';
        messageid{iF} = 'File not found.';
    end
end
disp('Formatting complete.')

if nargout>0
    status=s;
end

function f2 = parseString(f,formatSpec)
f2 = '';
n = '';
FMTnum = 0;
iChar=1;

% First character
isAlpha = ~isempty(regexpi(f(iChar),'[A-Z,a-z,:,\\,/,_]'));
isNum = ~isempty(regexpi(f(iChar),'[0-9]'));
isDot = ~isempty(regexpi(f(iChar),'\.'));
if isDot || isAlpha
    f2 = [f2 f(1)];
    lastAlph=true;
    lastNum=false;
end
if isNum
    FMTnum = FMTnum+1;
    n = [n f(1)];
    lastNum=true;
    lastAlph=false;
end

% Subsequent characters
for iChar=2:length(f)
    isAlpha = isempty(regexpi(f(iChar),'[0-9]'));
    isNum = ~isempty(regexpi(f(iChar),'[0-9]'));
    isDot = ~isempty(regexpi(f(iChar),'\.'));

    if isDot && iChar+1<=length(f)
        nStr = regexpi(f(iChar-1:2:iChar+1),'[0-9]');
        if length(nStr)==2
            isAlpha=false;
            isNum=true;
        else
            isAlpha=true;
            isNum=false;
        end
    elseif isDot
        isAlpha=true;
        isNum=false;
    end

    if lastAlph && isNum
        % begin accumulating number string
        n = f(iChar);
        FMTnum = FMTnum+1;
    end
    if lastAlph && isAlpha
        % dump alpha into f2
        f2 = [f2 f(iChar)];
    end
    if lastNum && isNum
        % dump number into number string
        n = [n f(iChar)];
    end
    if lastNum && isAlpha
        % translate and dump number string into f2
        if FMTnum>length(formatSpec)
            FMTnum = mod(FMTnum,length(formatSpec))+1;
        end
        str = formatSpec{FMTnum};
        % str contains the formatting info, e.g. '%02d'
        evalStr = ['sprintf(''' str ''',n0);'];
        n0 = str2double(n);
        f1 = eval(evalStr);

        % dump numeric buffer and alpha into f2
        f2 = [f2 f1 f(iChar)];
        
        % flush numeric buffer
        n = '';
    end
    lastAlph = isAlpha;
    lastNum = isNum;
end
if lastNum
    % dump final numeric buffer into f2
    if FMTnum>length(formatSpec)
            FMTnum = mod(FMTnum,length(formatSpec))+1;
    end
    str = formatSpec{FMTnum};
    % str contains the formatting info, e.g. '%02d'
    evalStr = ['sprintf(''' str ''',n0);'];
    n0 = str2double(n);
    f1 = eval(evalStr);

    % dump numeric buffer into f2
    f2 = [f2 f1];
end