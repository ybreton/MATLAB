function sortFigFiles(fd)
% Moves files in directory to subdirectories based on file extension.
%
%
%

if nargin<1
    fd = pwd;
end

pushdir(fd);

fn = dir;

filetypes = cell(length(fn),1);
subdirs = cell(length(fn),1);
files = cell(length(fn),1);
disp('Parsing filetypes...')
for iF=1:length(fn);
    name = fn(iF).name;
    if ~fn(iF).isdir;
        [parent,filename,ext] = fileparts(name);
        filetypes{iF} = ext(2:end);
        files{iF} = name;
    else
        if ~strcmpi(name,'.') && ~strcmpi(name,'..')
            subdirs{iF} = name;
        end
    end
end
empty = cellfun(@isempty,subdirs);
subdirs = unique(subdirs(~empty));
empty = cellfun(@isempty,filetypes);
uniquefiletypes = unique(filetypes(~empty));
disp(['Found ' num2str(length(uniquefiletypes)) ' file types in directory.'])
for iFT=1:length(uniquefiletypes)
    createnew = true;
    for iSD=1:length(subdirs)
        if strcmpi(subdirs{iSD},uniquefiletypes{iFT})
            createnew = false;
        end
    end
    if createnew
        disp(['Creating subdirectory ' uniquefiletypes{iFT} '...'])
        mkdir(uniquefiletypes{iFT});
    end
    matchingFiles = strcmpi(filetypes,uniquefiletypes{iFT});
    names = files(matchingFiles);
    disp(['Moving ' num2str(length(names)) ' ' uniquefiletypes{iFT} ' files to subdirectory...'])
    for iF=1:length(names)
        movefile(names{iF},[pwd '\' uniquefiletypes{iFT} '\' names{iF}]);
    end
end

popdir;