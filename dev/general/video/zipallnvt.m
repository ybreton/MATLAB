function zipallnvt(varargin)
%
%
%
%

fd = pwd;
process_varargin(varargin);
if ischar(fd)
    fd = {fd};
end
fd = fd(:);


for d = 1 : length(fd)
    pushdir(fd{d});
    fn = FindFiles('*.nvt');
    fprintf('\nFound %d .NVT files in %s.\n',length(fn),fd{d});
    for f = 1 : length(fn)
        [directory,filename,ext] = fileparts(fn{f});
        pushdir(directory);
        zipfn = [filename '.zip'];
        if ~(exist(zipfn,'file')==2)
            disp(['Zipping ' directory '\' filename ext])
            zip(zipfn,fn{f});
        end
        disp(['Deleting ' directory '\' filename ext])
        delete(fn{f});
        popdir;
    end
    popdir;
end