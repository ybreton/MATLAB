function status=nvt2mat(varargin)

zips = FindFiles('*.zip');
toRemove = cell(0,1);
if ~isempty(zips)
    fprintf('\n');
    for z = 1 : length(zips)
        [pathname,filename,ext] = fileparts(zips{z});
        pushdir(pathname);
        matFiles = FindFiles('*-vt*.mat');
        if isempty(matFiles)
            fprintf('Unzipping %s\n',zips{z});
            unzip(zips{z})
            fnZip = FindFiles('*.nvt','CheckSubdirs',false);
            toRemove(end+1:end+length(fnZip)) = fnZip;
        end
        popdir;
    end
end
fn = FindFiles('*.nvt');
process_varargin(varargin);

status0 = cell(length(fn),2);
fprintf('\n')
for f = 1 : length(fn)
    [pathname,filename,ext] = fileparts(fn{f});
    idPath = regexpi(pathname,'\');
    SSN = pathname(max(idPath)+1:end);
    pushdir(pathname);
    matFiles = FindFiles('*-vt*.mat');
    if isempty(matFiles)
        [x,y,phi] = LoadVT_lumrg([filename ext]);
        matfn = sprintf('%s-vt.mat',SSN);
        fprintf('Processing %s\n',matfn);
        save(matfn,'x','y','phi')
        status0{f,1} = fn{f};
        status0{f,2} = 1;
    else
        fprintf('%s already produced. Skipping.\n',matFiles{1})
        status0{f,1} = fn{f};
        status0{f,2} = 0;
    end
    popdir;
end
if nargout>0
    status = status0;
end

fprintf('\n')
for d = 1 : length(toRemove)
    fprintf('Cleaning up %s\n',toRemove{d});
    delete(toRemove{d});
end
