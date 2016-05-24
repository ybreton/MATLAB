function TD = xls2ttdepthCSV(varargin)
%
%
%
%

ttdepthCol = [];
fd = pwd;
moveCSVs = true;
deleteCSVs = true;
overwriteCSVs = true;
process_varargin(varargin);

if ischar(fd)
    fd = {fd};
end

k = 1;
for d = 1 : length(fd)
    pushdir(fd{d});
    [file,folder] = uigetfile('*.*', sprintf('Select Excel file for %s',fd{d}));
    idExt = regexp(file,'\.');
    extension = file(max(idExt):end);
    file = file(1:max(idExt)-1);
    
    [type,sheetname] = xlsfinfo(fullfile(folder,[file extension]));
    n = length(sheetname);
    disp(['Processing ' fullfile(folder,[file extension])])
    exported = cell(n,1);
    filelist = cell(n,1);
    for wsnum = 1 : n
        sheet = sheetname{wsnum};
        
        disp(['Processing worksheet ' sheet])
        
        data = xlsread(fullfile(folder,[file extension]),sheet);

        if isempty(ttdepthCol)
            depth = data(:,end);
        else
            depth = data(:,ttdepthCol);
        end

        filename = [fd{d} '\' file '-' sheet '-TTdepth' '.csv'];
        
        ex = exist(filename,'file')==2;
        if ~ex | overwriteCSVs
            csvwrite(filename,depth)
        end
        
        exported{wsnum} = sheet;
        filelist{wsnum} = filename;
    end
    for f = 1 : length(exported)
        fn = FindFiles(['*' exported{f} '*.mat']);
        if ~isempty(fn) && moveCSVs
            for d = 1 : length(fn)
                fd = fileparts(fn{d});
                pushdir(fd);
                [folder,file,ext] = fileparts(filelist{f});
                
                TD{k} = fullfile(fd,[file ext]);

                disp(['Moving ' TD{k}])
                copyfile(filelist{f},TD{k});

                k = k+1;
                
                popdir;
            end
            if deleteCSVs
                delete(filelist{f});
            end
        end
    end
    popdir;
end