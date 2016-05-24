function Asq = nansquareMat(A)
% Squares a matrix A ignoring nan's.
% Asq = nansquareMat(A)
% where     Asq         is an m x m matrix,
%
%           A           is an m x n matrix.
%
% if entry a(i,j) is nan, it is ignored.
%
% Example:
% A = [1    2   3   4;
%      nan  5   6   7];
% Asq = nansquareMat(A)
%
% Asq = [1*1+2*2+3*3+4*4        2*5+3*6+4*7;
%            5*2+6*3+7*4    1*1+2*2+3*3+4*4];
% Asq = [30 56;
%        56 30];

idnan = isnan(A);

Asq = nan(size(A,1));
for iA=1:size(A,1)
    A1 = A(iA,:);
    for jA=1:size(A,1)
        A2 = A(jA,:);
        Asq(iA,jA) = A1(~idnan(iA,:)&~idnan(jA,:))*A2(~idnan(iA,:)&~idnan(jA,:))';
    end
end