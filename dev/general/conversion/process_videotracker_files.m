function vtfiles = process_videotracker_files(varargin)
%
%
%
%

process_varargin(varargin);

zipfn = FindFiles('*VT*.zip');

vtfiles = cell(length(zipfn),1);
k = 1;

for f = 1 : length(zipfn)
    % for every zip, unzip and remember the output name. We will delete
    % this output file later.
    [pathname,filename,ext] = fileparts(zipfn{f});
    pushdir(pathname);
    id = sort([regexpi(pathname,'/') regexpi(pathname,'\')]);
    SSN = pathname(max(id)+1:end);
    ls = dir;
    directoryListing = cell(length(ls),1);
    for iF = 1 : length(ls)
        directoryListing{iF} = ls(iF).name;
    end
    idEx = strncmpi('.',directoryListing,1) | strncmpi('..',directoryListing,2);
    directoryListing(idEx) = [];
    
    unzip(zipfn{f})
    ls = dir;
    comparisonListing = cell(length(ls),1);
    for iF = 1 : length(ls)
        comparisonListing{iF} = ls(iF).name;
    end
    idEx = strncmpi('.',comparisonListing,1) | strncmpi('..',comparisonListing,2);
    comparisonListing(idEx) = [];
    
    old = false(length(comparisonListing),1);
    for iF = 1 : length(comparisonListing)
        iOrig = 1;
        while iOrig <= length(directoryListing) & old(iF)==false
            if strcmpi(comparisonListing{iF},directoryListing{iOrig})
                old(iF) = true;
            end
            iOrig = iOrig+1;
        end
    end
    zippedFiles = comparisonListing(~old);
    
    nvts = FindFiles('*.nvt','CheckSubdirs',0);
    for n = 1 : length(nvts)
        [x,y] = LoadVT_lumrg(nvts{n});
        if n>1
            disp(sprintf('Processing file %s',[SSN '-vt' sprintf('%d',n) '.mat']))
            vtfiles{k} = [pathname '\' SSN '-vt' sprintf('%d',n) '.mat'];
            save([SSN '-vt' sprintf('%d',n) '.mat'],'x','y')
        else
            disp(sprintf('Processing file %s',[SSN '-vt.mat']))
            vtfiles{k} = [pathname '\' SSN '-vt.mat'];
            save([SSN '-vt.mat'],'x','y')
        end
        k = k + 1;
    end
    
    for z = 1 : length(zippedFiles)
        delete(zippedFiles{z})
        disp(sprintf('Cleaning up zipped file %s',zippedFiles{z}))
    end
    
    popdir;
end

nvtfn = FindFiles('*.Nvt');

for f = 1 : length(nvtfn)
    [pathname,filename,ext] = fileparts(nvtfn{f});
    pushdir(pathname);
    id = sort([regexpi(pathname,'/') regexpi(pathname,'\')]);
    SSN = pathname(max(id)+1:end);
    
    id = regexpi(filename,'[0-9]');
    if ~isempty(id)
        n = str2double(filename(id:end));
    else
        n = 1;
    end
    
    [x,y] = LoadVT_lumrg(nvtfn{f});
    if n>1
        disp(sprintf('Processing file %s',[SSN '-vt' sprintf('%d',n) '.mat']))
        save([SSN '-vt' sprintf('%d',n) '.mat'],'x','y')
        vtfiles{k} = [pathname '\' SSN '-vt' sprintf('%d',n) '.mat'];
    else
        disp(sprintf('Processing file %s',[SSN '-vt.mat']))
        save([SSN '-vt.mat'],'x','y')
        vtfiles{k} = [pathname '\' SSN '-vt.mat'];
    end
    k = k + 1;
    popdir;
end