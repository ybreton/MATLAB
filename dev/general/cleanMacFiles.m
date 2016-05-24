function cleanMacFiles(fd,varargin)

confirm=false;
process_varargin(varargin);

if nargin<1
    fd = pwd;
end
cd(fd);

fn = FindFiles('.*');
exc = false(length(fn),1);
for iF=1:length(fn)
    [~,~,ext] = fileparts(fn{iF});
    exc(iF) = strcmp('.',ext);
end
fnInc = fn(~exc);

for iF=1:length(fnInc)
    disp(['deleting ' fnInc{iF} '...'])
    if confirm
        disp('Press enter to delete.')
        pause;
    end
    delete(fnInc{iF});
end
    