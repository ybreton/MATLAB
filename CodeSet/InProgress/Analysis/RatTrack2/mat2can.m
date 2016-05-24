function can=mat2can(mat)
% Converts a matrix to a cell array of numbers.
%
%
%

for m = 1 : size(mat,1)
    for n = 1 : size(mat,2)
        can{m,n} = mat(m,n);
    end
end