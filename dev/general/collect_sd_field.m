function array = collect_sd_field(field,varargin)
%
%
%
%
fd = pwd;
sd_filename = '*-sd.mat';
sd_object = 'sd';
dim = 1;
process_varargin(varargin);
disp(['Searching ' fd ' for files with ' sd_filename])
disp(['Loading ' sd_object ' to compile ' field])

idDot = regexpi(field,'\.');
if ~isempty(idDot)
    field0 = field(1:min(idDot)-1);
else
    field0 = field;
end

if ischar(fd)
    fd = {fd};
end

k = 0;
array = cell(0,1);
for p = 1 : length(fd)
    pushdir(fd{p}) 
    fn = FindFiles(sd_filename);
    for f = 1 : length(fn)
        pathname = fileparts(fn{f});
        pushdir(pathname);
        load(fn{f})
        if isfield(sd,field0)
            contents = eval([sd_object '.' field]);
            k = k+1;
            array{k} = contents;
        end
        popdir;
    end
    popdir;
end
if dim>1
    disp(['Reshaping array to list across dimension ' num2str(dim)])
    m = ones(dim,1);
    m(dim) = numel(array);
    array = reshape(array,m);
else
    array = array(:);
end