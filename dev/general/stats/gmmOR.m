function [OR,lnOR] = gmmOR(gmobj,x)
% calculates the odds-ratio, or log-odds, of the data in x, according to
% Gaussian mixture model in gmobj.
% OR = gmmOR(gmobj,x)
% [OR,lnOR] = gmmOR(gmobj,x)
% where             gmobj       is a Gaussian mixture distribution object
%                                   created by gmdistribution or gmmfit,
%                   x           is an n x d (or 1 x n if dim==1) matrix of
%                                   data points in dim dimensions.
%
%                   OR          is an n x k matrix of odds ratios of each
%                                   component k for each dim-dimensional
%                                   value of x,
%                                   OR = P[k|x]/P[~k|x]
%                   lnOR        is an n x k matrix of the natural
%                                   logarithms of those odds ratios.
%

dim = length(gmobj.NDimensions);
K = gmobj.NComponents;

if size(x,1)==1 && size(x,2)>1 && dim==1
    x = x(:);
end

p = gmobj.posterior(x);
OR = nan(size(p));
for k=1:K
    OR(:,k) = p(:,k)./sum(p(:,[1:K]~=k),2);
end
lnOR = log(OR);