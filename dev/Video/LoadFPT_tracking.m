function [x,y,phi] = LoadFPT_tracking(fileList,varargin)
% Loads FPT-tracking file as
%
%
%

process_varargin(varargin);
if nargin<1
    fileList = FindFiles('FPT-tracking-*.txt','CheckSubdirs',0);
end
if ischar(fileList)
    fileList = {fileList};
end

T = [];
X = [];
Y = [];
for f = 1 : length(fileList)
    fn = fileList{f};
    fid = fopen(fn,'r');
    lineNum = 0;
    data = nan(0,0);
    header = cell(0,0);
    while ~feof(fid)
        str = fgetl(fid);
        idContents = regexp(str,' [0-9A-Za-z]');
        idSpc = regexp(str,' ');
        idSpc = unique([idSpc length(str)+1]);
        tline = cell(1,length(idContents));
        for c = 1 : length(idContents);
            start = idContents(c)+1;
            finish = min(idSpc(idSpc>idContents(c)))-1;
            tline{c} = str(start:finish);
        end
        if lineNum==0
            header = tline;
        else
            data(lineNum,1:length(tline)) = nan;
            for c = 1 : length(tline)
                data(lineNum,c) = str2double(tline{c});
            end
        end
        lineNum = lineNum + 1;
    end
    Tcol = strcmp(header,'T');
    Xcol = strcmp(header,'X');
    Ycol = strcmp(header,'Y');

    T0 = data(:,Tcol);
    X0 = data(:,Xcol);
    Y0 = data(:,Ycol);
    
    T = cat(1,T,T0);
    X = cat(1,X,X0);
    Y = cat(1,Y,Y0);
    fclose(fid);
end
[T,id] = sort(T);
X = X(id);
Y = Y(id);

if nargout < 2
    x = ts(T);
end
if nargout >= 2
    x = tsd(T,X);
    y = tsd(T,Y);
end
if nargout == 3
    phi = tsd(T,arctan(Y./X));
end