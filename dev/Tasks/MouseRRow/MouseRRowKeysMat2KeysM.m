function MouseRRowKeysMat2KeysM(fn)
% Converts M*-keys.mat to M*-keys.m
%

if ischar(fn)
    fn = {fn};
end

for iF=1:length(fn)
    [fd,fname,ext] = fileparts(fn{iF});
    fname = strrep(fname,'-','_');
    pushdir(fd);
    keys = load(fn{iF});
    keys = keys.keys;
    fid = fopen([fname '.m'],'w');
    fields = fieldnames(keys);
    for iField=1:length(fields);
        param_value = keys.(fields{iField});
        if isnumeric(param_value)
            if numel(param_value)>1
                param_str = '[';
                for iValue=1:length(param_value)
                    param_str = [param_str sprintf('%.4f', param_value(iValue)) ', '];
                end
                param_str = param_str(1:end-2);
                param_str = [param_str ']'];
            else
                param_str = sprintf('%.4f', param_value);
            end

            fprintf(fid, 'ExpKeys.%s = %s;\r\n', fields{iField}, param_str);
        else
            if iscell(param_value)
                param_str = '{';
                for iValue=1:length(param_value)
                    param_str = [param_str sprintf('''%s''', param_value{iValue}) ', '];
                end
                param_str = param_str(1:end-2);
                param_str = [param_str '}'];

                fprintf(fid, 'ExpKeys.%s = %s;\r\n', fields{iField}, param_str);
            else
                fprintf(fid, 'ExpKeys.%s = ''%s'';\r\n', fields{iField}, param_value);
            end
        end
    end
    fclose(fid);
    popdir;
end