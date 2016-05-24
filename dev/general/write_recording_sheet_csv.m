function write_recording_sheet_csv(varargin)
% Writes a csv of the generic experimental recording sheet.
% optional input arguments:
% dirs          {default is all subdirectories}     session to process
%

curDir = cd;
contents = dir;
idxDirs = arrayfun(@(x) x.isdir, contents);
dirStruc = contents(idxDirs);
dirs = cell(0,1);
for iD = 1 : length(dirStruc)
    pathname = dirStruc.name;
    if ~strcmpi('.',pathname) && ~strcmpi('..',pathname)
        dirs{iD} = [curDir '\' pathname];
    end
end
process_varargin(varargin);

if isempty(dirs)
    dirs = {curDir};
end

for d = 1 : length(dirs)
    pushdir(dirs{d});
    fprintf('\n')
    disp(dirs{d})
    fprintf('\n')
    
    ncs = FindFiles('*.ncs','CheckSubdirs',0);
    CSC = cell(length(ncs),7);
    for f = 1 : length(ncs)
        filename = ncs{f};
        [pathname,filename,ext] = fileparts(filename);
        idx = regexpi(pathname,'\');
        idx = max(idx);
        SSN = pathname(idx+1:end);

        fprintf('\n')
        for iTemp = 1 : length(filename)+length(ext)
            fprintf('*')
        end
        fprintf('\n')
        fprintf('%s%s\n',filename,ext)
        CSC{f,1} = [filename ext];
        
        str = lower(input('Input [a]: ','s'));
        if isempty(str)
            str = 'a';
        end
        num = regexpi(filename,'[0-9]');
        channel = str2double(filename(num));
        listOrder(f) = channel;
        if all(~strcmpi(str,{'a' 'b' 'c' 'd'}))
            channel = [];
            str2 = lower(input('Referenced to: ','s'));
            if isempty(str2)
                str2 = '';
            end
        else
            str2 = '';
            thresh = input('Threshold [50]: ');
            if isempty(thresh)
                thresh = 50;
            end
            inputRange = input('Input range [197]: ');
            if isempty(inputRange)
                inputRange = 197;
            end
            ampGain = input('Amplitude gain [5055]: ');
            if isempty(ampGain)
                ampGain = 5055;
            end
        end
        if isempty(channel)
            CSC{f,2} = str;
            CSC{f,3} = str2;
            CSC{f,7} = sprintf('%s-CSC%s%s',SSN,str,str2);
        else
            CSC{f,2} = sprintf('%02d',channel);
            CSC{f,3} = sprintf('%s',str);
            CSC{f,4} = sprintf('%d',thresh);
            CSC{f,5} = sprintf('%d',inputRange);
            CSC{f,6} = sprintf('%d',ampGain);
            CSC{f,7} = sprintf('%s-CSC%02d%s',SSN,channel,str);
        end

        for iTemp = 1 : length(filename)+length(ext)
            fprintf('*')
        end
        fprintf('\n')
    end

    [listOrder,idx] = sort(listOrder);
    CSC = CSC(idx,:);
    
    fprintf('\n')
    fprintf('Writing %s\\ExperimentRecordingSheet.csv\n',dirs{d})
    
    cell2csv('ExperimentRecordingSheet.csv',CSC,',');
    
    popdir;
end