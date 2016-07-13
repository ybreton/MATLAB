function L = keysdb(fd, keys, varargin)
% Returns a structure L with the experiment keys of each session in the
% database in directories of fd.
%
%
%
if ischar(fd)
    fd = {fd};
end
process_varargin(varargin);

sz = size(fd);
if length(sz)==2
    if sz(1)==1
        sz = sz(2);
    elseif sz(2)==1
        sz = sz(1);
    end
    sz0 = [sz 1];
else
    sz0 = sz;
end
fd = fd(:);

if nargin<2
    keys = [];
end

if isempty(keys)
    keys = getKeys(fd);
end
keys = keys(:);
Type = getTypes(fd, keys);

for iF = 1:numel(fd);
    ExpKeys = EvalKeys(fd{iF});
    for iK=1:length(keys)
        if isfield(ExpKeys,keys{iK})
            S.(keys{iK}) = ExpKeys.(keys{iK});
        else
            if Type.M(iK)
                S.(keys{iK}) = nan(1,0);
            end
            if Type.C(iK)
                S.(keys{iK}) = cell(1,0);
            end
            if Type.S(iK)
                S.(keys{iK}) = '';
            end
            if Type.T(iK)
                S.(keys{iK}) = ts([]);
            end
        end
    end
    L0(iF) = S;
    clear S;
end

for iK=1:length(keys)
    kname = keys{iK};
    ksz = [1 1];
    kdim = 2;
    for iF=1:length(L0)
        value = L0(iF).(kname);
        vsz = size(value);
        vdim = length(vsz);
        if vdim>kdim
            ksz(end+1:end+vdim-kdim) = 1;
            kdim=vdim;
        end
        ksz = max([ksz;vsz]);
    end
    if Type.M(iK)
        L.(kname) = nan([numel(fd) ksz]);
        L.(kname) = L.(kname)(:,:);
        for iF=1:length(L0)
            v = L0(iF).(kname)(:)';
            L.(kname)(iF,1:length(v)) = v;
        end
        
        L.(kname) = reshape(L.(kname),[sz ksz]);
    end
    if Type.S(iK)
        L.(kname).Names = cell([numel(fd) 1]);
        for iF=1:length(L0)
            v = L0(iF).(kname);
            L.(kname).Names{iF} = v;
        end
        L.(kname).Names = reshape(L.(kname).Names,[sz 1]);
        c = L.(kname).Names;
        e = cellfun(@isempty,c);
        u = unique(c(~e));
        for iU=1:length(u)
            subkey = genvarname(u{iU});
            L.(kname).(subkey) = strcmp(u{iU}, L.(kname).Names);
        end
    end
    if Type.C(iK)
        subkeys = cell(0,1);
        for iF=1:length(L0);
            C = L0(iF).(kname)(:);
            e = cellfun(@isempty,C);
            subkeys = unique(cat(1,subkeys(:),unique(C(~e))));
        end
        for iSub=1:length(subkeys)
            subkey = genvarname(subkeys{iSub});
            L.(kname).(subkey) = nan(numel(fd),1);
        end
        for iSub=1:length(subkeys)
            subkey = genvarname(subkeys{iSub});
            for iF=1:length(L0);
                C = L0(iF).(kname);
                L.(kname).(subkey)(iF) = any(strcmp(subkey,C));
            end
            L.(kname).(subkey) = reshape(L.(kname).(subkey),[sz 1]);
        end
    end
    if Type.T(iK)
        L.(kname) = cell(numel(fd), 1);
        for iF=1:length(L0)
            v = L0(iF).(kname);
            L.(kname){iF} = v;
        end
        L.(kname) = reshape(L.(kname), [sz 1]);
    end
end
L.size = sz0(:)';
L.directories = fd;

function ExpKeys = EvalKeys(fd)
if ~isempty(fd)
    pushdir(fd);
    ssn = GetSSN();
    S = regexp(ssn,'[A-Z][0-9]');
    D = regexp(ssn,'[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]');
    delim = regexp(ssn,'-');
    SubjNum = ssn(S+1:min(delim)-1);
    Subject = ssn(S:min(delim)-1);
    DateStr = ssn(D:end);
    fn = FindFiles('*keys.m','CheckSubdirs',0);
    if ~isempty(fn)
        [~,fn] = fileparts(fn{end});
        eval(fn);
        ExpKeys.SSN = ssn;
        ExpKeys.SubjNum = str2double(SubjNum);
        ExpKeys.Subject = Subject;
        ExpKeys.DateStr = DateStr;
    end
    popdir;
else
    ExpKeys = [];
end

function K = getKeys(fd)
K = {};
pbh=timedProgressBar('Finding all keys',numel(fd));
for iF = 1:numel(fd)
    if ~isempty(fd{iF})
        ExpKeys = EvalKeys(fd{iF});
        keys = fieldnames(ExpKeys);
        K = unique(cat(1, K(:), keys(:)));
    end
    pbh=pbh.update();
end
pbh.close();

function Type = getTypes(fd, keys)
m = false(numel(fd), numel(keys));
s = false(numel(fd), numel(keys));
c = false(numel(fd), numel(keys));
t = false(numel(fd), numel(keys));
empty = false(numel(fd), numel(keys));
pbh=timedProgressBar('Identifying key types',numel(fd));
for iF = 1:numel(fd);
    if ~isempty(fd{iF})
        ExpKeys = EvalKeys(fd{iF});
        for iK=1:numel(keys)
            if isfield(ExpKeys,keys{iK});
                v = ExpKeys.(keys{iK});
                m(iF,iK) = isnumeric(v);
                s(iF,iK) = ischar(v);
                c(iF,iK) = iscell(v);
                t(iF,iK) = isa(v,'ts') | isa(v,'ctsd');
            else
                empty(iF,iK) = true;
            end
        end
    end
    pbh=pbh.update();
end
Type.M = nansum(m,1)./nansum(~empty,1)>0.5;
Type.S = nansum(s,1)./nansum(~empty,1)>0.5;
Type.C = nansum(c,1)./nansum(~empty,1)>0.5;
Type.T = nansum(t,1)./nansum(~empty,1)>0.5;
