function Z = nanzscore(X,flag,dim)
% Z-score ignoring NaNs
% Z = nanzscore(X)
% Z = nanzscore(X,dim)
% Z = nanzscore(X,flag,dim)
% where     Z       is m x n x ... x p matrix of Z-scores
%
%           X       is m x n x ... x p matrix of raw scores
%           dim     is 1x1 integer with dimension along which to calculate
%                       mean and SD for Z score
%           flag    is 1x1 population normalization boolean specifying
%                       whether the standard deviation along dimension dim
%                       should be taken as SS/(n-1), when flag is false, or
%                       SS/n, when flag is true. By default, flag==false.
%                       false:  normalize using a sample standard
%                               deviation (default).
%                       true:   normalize using a population standard
%                               deviation.
%

if nargin<1
    Z = nan;
end
if nargin==1
    if length(size(X))==2 && size(X,1)==1 && size(X,2)>1
        dim=2;
    else
        dim=1;
    end
    flag=0;
end
if nargin==2
    dim=flag;
    flag=0;
end

assert(dim<=length(size(X)),['X must have at least ' num2str(dim) ' dimensions.']);
assert((flag==0||flag==1),'flag must be a boolean.');


sz = size(X);
reps = ones(1,length(sz));
reps(dim) = sz(dim);

M = repmat(nanmean(X,dim),reps);
S = repmat(nanstd(X,flag,dim),reps);

idnan = isnan(X);

Z = (X-M)./(S+eps);
Z(idnan) = nan;