function gc_cleanNVTs(fd,varargin)
%
%
%
%

deleteFiles = true;
process_varargin(varargin);

if nargin<1
    fd = pwd;
end
if isempty(fd)
    fd = pwd;
end

if ischar(fd)
    fd = {fd};
end

for iD = 1 : length(fd)
    pushdir(fd{iD});
    disp(fd{iD});
    fn = FindFiles('*.nvt');
    fd0 = cell(length(fn),1);
    name = fd0;
    ext = fd0;
    for iF=1:length(fn)
        [fd0{iF},name{iF},ext{iF}] = fileparts(fn{iF});
    end
    
    for iF=1:length(fd0)
        pushdir(fd0{iF});
        disp(fd0{iF});
        
        zipFn = FindFiles([name{iF} '*.zip'],'CheckSubdirs',false);
        if isempty(zipFn)
            disp('Zip file not found. Zipping.')
            zip([name{iF} '.zip'],[name{iF} ext{iF}])
            zipFn = FindFiles([name{iF} '*.zip'],'CheckSubdirs',false);
        else
            disp('Zip files found:')
            disp(zipFn);
        end
        if deleteFiles
            str = '';
            while ~(strncmpi(str,'Y',1)||strncmpi(str,'N',1))
                str = input(['Confirm delete of ' name{iF} ext{iF} ' (Y/N): '],'s');
            end
            if strncmpi(str,'Y',1)
                disp(['Deleting ' name{iF} ext{iF}]);
                delete([name{iF} ext{iF}])
            end
        end
        popdir;
    end
    popdir;
end