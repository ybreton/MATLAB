function I = cellOK(ca)
% Wrapper to identify whether a cell in a cell array is not empty.

if ~isempty(ca)
    I = ~cellfun(@isempty,ca);
else
    I = [];
end