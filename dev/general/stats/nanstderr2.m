function S = nanstderr2(X,FLAG,DIM)
% Calculates the standard error of the mean, ignoring nans, along the first
% nonsingleton dimension.
%

sz = size(X);
if all(sz==1)
    nonsingleton = true(1,size(sz));
else
    nonsingleton = sz>1;
end

if nargin<3
    DIM = find(nonsingleton,1,'first');
end
if nargin<2
    FLAG=false;
end
if ((FLAG~=1)&&(FLAG~=0))
    DIM = FLAG;
    FLAG = false;
end

s = nanstd(X,FLAG,DIM);
n = sum(~isnan(X),DIM);

S = s./sqrt(n);