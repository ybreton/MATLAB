function S = mvfield(S, old, new)
% Moves (renames) field 'old' to field 'new' in structure array S.
% S = mvfield(S, old, new)
% where     S           is a structure array with fields that include old
%
%           old         is a field in structure array S
%           new         is a field to be added to structure array S
%
% old and new can be character strings, in which case
% S.old -> S.new
% old and new can be cell arrays with identical number of elements, in
% which case
% S.old{i} -> S.new{i}
%

if ischar(old)
    if strcmp(new,old)==0
        S.(new) = S.(old);
        S = rmfield(S,old);
    end
end
if iscell(old)
    assert(numel(old)==numel(new), 'old and new must have same number of elements if cell arrays.');
    for iF=1:numel(old)
        S.(new{iF}) = S.(old{iF});
        S = rmfield(S,old{iF});
    end
end