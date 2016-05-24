function writeKeysFromStruc(ExpKeys,fn)
% Writes a Keys file based on the input structure array ExpKeys.
%
%
%

sname = inputname(1);

fields = fieldnames(ExpKeys);
fid = fopen(fn,'w');
for iF=1:length(fields)
    disp(fields{iF});
    x = ExpKeys.(fields{iF});
    str1 = ['ExpKeys.' fields{iF}];
    
    if iscell(x)
        disp('<Cell array>')
        str2 = '{';
        for ix=1:length(x)
            xx = x{ix};
            if isnumeric(xx)
                xx = num2str(xx);
            else
                xx = ['''' xx ''''];
            end
            str2 = [str2 xx ','];
        end
        str2 = str2(1:end-1);
        str2 = [str2 '}'];
    end
    
    if isnumeric(x)
        disp('<Vector>')
        str2 = '[';
        for ix=1:length(x)
            xx = x(ix);
            if isnumeric(xx)
                xx = num2str(xx);
            end
            str2 = [str2 xx ','];
        end
        str2 = str2(1:end-1);
        str2 = [str2 ']'];
    end
    
    if ischar(x)
        disp('<Character>')
        str2 = ['''' x ''''];
    end
    
    str = [str1 ' = ' str2 ';\r\n'];
    
    fprintf(fid, str);
end