function num = kludge_datenum(dateStr,delim)
% kludge for datenum error.
% num = 365*Y+12*M+D.
%
%

id = regexpi(dateStr,delim);
Y = str2double(dateStr(1:id(1)-1));
M = str2double(dateStr(id(1)+1:id(2)-1));
D = str2double(dateStr(id(2)+1:end));
num = Y*365+M*12+D;