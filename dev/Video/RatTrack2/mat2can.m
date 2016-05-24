function can=mat2can(mat)
% Converts a matrix to a cell array of numbers.
%
%
%

can = cell(size(mat));
parfor r=1:numel(mat)
    can{r}=mat(r);
end