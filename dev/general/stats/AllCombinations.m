function C = AllCombinations(A)
% Returns all combinations of the vectors in the cells of cell array A.
% C = AllCombinations(A)
% where     C       is (n*...*p) x m matrix of combinations, with
%                   C(i,:) a set of combinations of the values in the cells
%                   of A, and C(:,j) the set of values that A{j} can take.
%                   The number of rows in C will be the product of the
%                   number of elements in each cell of A.
%
%           A       is m-element cell array, with A{j} containing a vector
%                   of values.
% 
% Example:
% >> A = {[1,2,3], [1,2], [5,6,7]}
% >> C = AllCombinations(A)
%
% C =
% 
%      1     1     5
%      2     1     5
%      3     1     5
%      1     2     5
%      2     2     5
%      3     2     5
%      1     1     6
%      2     1     6
%      3     1     6
%      1     2     6
%      2     2     6
%      3     2     6
%      1     1     7
%      2     1     7
%      3     1     7
%      1     2     7
%      2     2     7
%      3     2     7
%
% Note that C is 18 rows (3*2*3) and 3 columns (one for each element of A).
% Each row provides a unique combination of the 3 elements in A.
%

if isnumeric(A)
    warning('Converting numeric matrix A into cell array')
    A0 = cell(size(A));
    for iEl=1:numel(A)
        A0{iEl} = 1:A(iEl);
    end
    A = A0;
end

nEls = cellfun(@numel,A);
I = find(nEls<1);
for ii=I(:)'
    A{ii} = nan;
end
nEls = cellfun(@numel,A);

C = (1:nEls(1))';

for iSeq=2:length(A)
    n = nEls(iSeq);
    a = A{iSeq};
    
    C1 = repmat(C,[n 1]);
    C2 = [];
    for iR=1:n
        C2 = cat(1,C2,ones(size(C,1),1)*a(iR));
    end
    
    C = cat(2,C1,C2);
end
% Each row of C is now a unique combination of the values in A.