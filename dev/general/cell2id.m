function [I,lst] = cell2id(ca)
% Wrapper to convert the unique strings in ca to a matrix with dummy IDs.
% dummy IDs will be nan wherever ca is empty.
% I = cell2id(ca)
% where     I       is m x n x ... x p matrix of dummy ID numbers
% 
%           ca      is m x n x ... x p cell array of strings/empties.
% [I,lst] = cell2id(ca)
% where     lst     is a cell array of the unique strings in ca, where
%                       ca = lst(I).
%

I = nan(size(ca));
id = cellOK(ca);
lst = unique(ca(id));
for n = 1:length(lst)
    nidx = strcmp(lst{n},ca);
    I(nidx) = n;
end