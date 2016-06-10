function Keys = eval_keys(fd)
% Automatically finds and evaluates the keys file.
% ExpKeys = eval_keys()
%   where   ExpKeys     is a structure of experiment keys,
% will automatically find and evaluate the keys file in the current
% directory. All cell arrays of strings of size 1x1 will automatically
% become string fields.
%
% Keys = eval_keys(fd)
%   where   ExpKeys     is a structure of n x m x ... x p experiment keys,
%   
%           fd          is a cell array of n x m x ... session directories,
% will automatically find and evaluate all keys files in specified
% directories. 
% If fd is n x m x ..., then the fields of Keys will be n x m x ... x p
% If fd is 1 x n, then the fields of Keys will be 1 x n x p
% If fd is n x 1, then the fields of Keys will be n x p
% where p is the maximum length of the field in Keys.
% All string fields will become n x m x ... x 1 cell arrays,
% All p-element cell arrays will become n x m x ... x p cell arrays,
% All pq-element cell arrays will become n x m x ... x pq cell arrays,
% All p-element vectors will become n x m x ... x p matrices,
% All pq-element matrices will become n x m x ... x pq matrices.
%
if nargin<1
    fd = pwd;
end

if ischar(fd)
    fd = {fd};
end
sz = size(fd);
if length(sz)==2 && sz(2)==1
    sz = sz(1);
end

fnames = cell(0,1);
disp('Pre-processing keys...')
for iF=1:numel(fd)
    d = fd{iF};
    pushdir(d);
    delim = regexpi(d,'\');
    SSN = d(max(delim)+1:end);
    keyfn = [strrep(SSN,'-','_') '_*keys.m'];
    keyfns = FindFiles(keyfn,'CheckSubdirs',0);
    if ~isempty(keyfns)
        keyfn = keyfns{end};
        [~,keyfn] = fileparts(keyfn);
        eval(keyfn);
        fnames = unique([fnames(:),fieldnames(ExpKeys)]);
    end
end
disp('Getting maximum length of fields...')
len = zeros(length(fnames),1);
num = nan(length(fnames),numel(fd));
for iF=1:numel(fd)
    d = fd{iF};
    pushdir(d);
    delim = regexpi(d,'\');
    SSN = d(max(delim)+1:end);
    keyfn = [strrep(SSN,'-','_') '_*keys.m'];
    keyfns = FindFiles(keyfn,'CheckSubdirs',0);
    if ~isempty(keyfns)
        keyfn = keyfns{end};
        [~,keyfn] = fileparts(keyfn);
        eval(keyfn);
        for iField=1:length(fnames)
            fname = fnames{iField};
            if isfield(ExpKeys,fname)
                x = ExpKeys.(fname);
                if ischar(x)
                    x = {x};
                end
                if isnumeric(x)
                    num(iField,iF) = 1;
                else
                    num(iField,iF) = 0;
                end
                n = numel(x);
                len(iField) = max(len(iField), n);
            end
        end
    end
end
num = nanmedian(num,2);

for iField=1:length(fnames)
%     disp([fnames{iField} ', nKeysFn x ' num2str(len(iField)) '...'])
    if num(iField)
        Keys.(fnames{iField}) = nan([sz len(iField)]);
    else
        Keys.(fnames{iField}) = cell([sz len(iField)]);
    end
end
disp('Adding values to fields...')
for iF=1:numel(fd)
    d = fd{iF};
    pushdir(d);
    delim = regexpi(d,'\');
    SSN = d(max(delim)+1:end);
    keyfn = [strrep(SSN,'-','_') '_*keys.m'];
    keyfns = FindFiles(keyfn,'CheckSubdirs',0);
    if ~isempty(keyfns)
        keyfn = keyfns{end};
        [~,keyfn] = fileparts(keyfn);
        eval(keyfn);
        for iField=1:length(fnames)
            if isfield(ExpKeys,fnames{iField})
                x = ExpKeys.(fnames{iField});
                if ischar(x)
                    x = {x};
                end
                n = numel(x);
                for iC=1:n
                    if num(iField)
                        Keys.(fnames{iField})(iF,iC) = x(iC);
                    else
                        Keys.(fnames{iField}){iF,iC} = x{iC};
                    end
                end
            end
        end
    end
end

disp('Reshaping fields')
for iField=1:length(fnames)
    str = sprintf('%.0f x ', [sz len(iField)]);
    str = str(1:end-3);
    disp([fnames{iField} ': ' str])
    Keys.(fnames{iField}) = reshape(Keys.(fnames{iField}),[sz len(iField)]);
end

if length(sz)==1 & sz(1)==1
    disp('Uncompressing character fields from 1x1 cell arrays')
    for iField=1:length(fnames)
        if len(iField)==1 && num(iField)==0
            disp(fnames{iField});
            Keys.(fnames{iField}) = Keys.(fnames{iField}){1};
        end
    end
end