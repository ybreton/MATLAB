function recording_directory_rename(varargin)
%
%
%
%

pathname = {pwd};
process_varargin(varargin);

for iPath = 1 : length(pathname)
    pathStr = pathname{iPath};
    idx = sort([regexpi(pathStr,'/') regexpi(pathStr,'\')]);
    idx = max(idx);
    SSN = pathStr(idx+1:end);
    pushdir(pathname{iPath})
    disp(pathname{iPath})
    
    ExperimentRecordingSheet = FindFiles('ExperimentRecordingSheet.csv','CheckSubdirs',0);
    if isempty(ExperimentRecordingSheet)
        for iStar = 1 : 13+length(SSN)
            fprintf('*')
        end
        fprintf('\nFor session %s:\n',SSN)
        ncs = FindFiles('*.ncs');
        CSC = cell(length(ncs),3);
        for iCSC = 1 : length(ncs)
            CSC{iCSC,1} = ncs{iCSC};
            CSC{iCSC,2} = input(sprintf('CSC%d Tetrode',iCSC));
            CSC{iCSC,3} = input(sprintf('CSC%d Channel',iCSC));
        end
        for iStar = 1 : 13+length(SSN)
            fprintf('*')
        end
        fprintf('\n')
    else
        [~,~,CSC]=xlsread(ExperimentRecordingSheet{1});
    end
    
    rows = 1 : size(CSC,1);
    ncs = FindFiles('*.ncs','CheckSubdirs',0);
    for f = 1 : length(ncs)
        [pathStr,fileStr,ext] = fileparts(ncs{f});
        source = [pathStr '\' fileStr ext];
        
        idx = strcmpi([fileStr ext],CSC(:,1));
        r = rows(idx);
        tetrode = CSC{r,2};
        channel = CSC{r,3};
        
        if isnan(channel)
            channel = '';
        end
        if isnan(tetrode)
            tetrode = '';
        end
        
        if isnumeric(tetrode)
            destination = sprintf('%s-CSC%02d%s.ncs',SSN,tetrode,channel);
        else
            destination = sprintf('%s-CSC%s%s.ncs',SSN,tetrode,channel);
        end
        fprintf('Renaming %s to %s ...\n',source,destination);
        str = sprintf('!rename %s %s',source,destination);
        eval(str)
    end
    
    ntt = FindFiles('*.ntt');
    for f = 1 : length(ntt)
        source = ntt{f};
        destination = sprintf('%s-TT%02d.ntt',SSN,f);
        
        fprintf('Renaming %s to %s ...\n',source,destination);
        str = sprintf('!rename %s %s',source,destination);
        eval(str)
    end
    
    nev = FindFiles('*.nev');
    for f = 1 : length(nev)
        source = nev{f};
        [pathname,filename,ext] = fileparts(source);
        destination = sprintf('%s-%s.nev',SSN,filename);
        
        fprintf('Renaming %s to %s ...\n',source,destination);
        str = sprintf('!rename %s %s',source,destination);
        eval(str)
    end
    
    % VT1
    try
        unzip('VT1.zip')
        delete('VT1.zip')
        nvt = FindFiles('*.nvt');
        for f = 1 : length(nvt)
            source = nvt{f};
            [pathname,filename,ext] = fileparts(source);
            destination = sprintf('%s-%s.nvt',SSN,filename);

            fprintf('Renaming %s to %s ...\n',source,destination);
            str = sprintf('!rename %s %s',source,destination);
            eval(str)
        end
        zip('VT1.zip',destination)
    catch
        disp('NO VT1.ZIP')
    end
    
    popdir;
end