function S = sortkeysdb(L, keys)
% 
% 
% 
% 

S = getDims(L,keys);
sz = S.size;

txt = cell(prod(sz),length(sz));
I = nan(size(txt));
for iK=1:length(keys)
    rp = sz;
    rp(iK) = 1;
    rs = ones(1,length(sz));
    rs(iK) = sz(iK);
    
    x = S.dimLevels{iK};
    X = repmat(reshape(x,rs),rp);
    idx = repmat(reshape(1:length(x),rs),rp);
    for ix=1:length(X(:))
        if isnumeric(X)
            txt{ix,iK} = X(ix);
        else
            txt{ix,iK} = X{ix};
        end
    end
    I(:,iK) = idx(:);
end
fields = fieldnames(L);
fields = fields(~ismember(fields,{'dimLevels' 'dimNames' 'size'}));
for iF=1:length(fields)
    L.(fields{iF}) = reshapeField(L.(fields{iF}),[numel(L.directories) 1]);
end


function R = reshapeField(F,rs)
if isstruct(F)
    f = fieldnames(F);
    for iF=1:length(f)
        R.(f{iF}) = reshapeField(F.(f{iF}), rs);
    end
else
    n = ceil(numel(F)/prod(rs));
    sz = [rs n];
    R = reshape(F, sz);
end

function S = getDims(L,keys)
dimLevels = cell(length(keys),1);
dimNames = cell(length(keys),1);
sz = nan(1,length(keys));
pbh=timedProgressBar('Fetching keys...',length(keys));
for iK=1:length(keys)
    keyname = keys{iK};
    [values,empty] = getValue(L,keyname);
    
    dimLevels{iK} = unique(values(~empty));
    dimNames{iK} = keyname;
    if any(empty(:))
        if iscell(dimLevels{iK})
            dimLevels{iK} = cat(2,dimLevels{iK},[]);
        elseif isnumeric(dimLevels{iK})
            dimLevels{iK} = cat(2,dimLevels{iK},nan);
        end
    end
    sz(iK) = length(dimLevels{iK});
    pbh = pbh.update();
end
pbh.close();
S.directories = L.directories;
S.dimNames = dimNames;
S.dimLevels = dimLevels;
S.size = sz;

function [values,empty] = getValue(L,keyname)
if isstruct(L.(keyname))
    values = L.(keyname).Names;
    empty = cellfun(@isempty,values);
end
if iscell(L.(keyname))
    values = L.(keyname);
    empty = cellfun(@isempty,values);
end
if isnumeric(L.(keyname))
    values = L.(keyname);
    empty = isnan(values);
end