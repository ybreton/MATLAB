function [pBin,edges] = gmmPBin(gmobj,centers,varargin)
% Returns P(x<=center+tol/2) - P(x<=center-tol/2) for each component of the
% gmdistribution object, in each bin with center defined as centers.
% pBin = gmmPBin(gmobj,centers)
% where     pBin        is n x d x k list of probabilities (if d>1) or
%                           n x k list of probabilities (if d==1).
%
%           gmobj       is a gmdistribution object with k components
%           centers     is n x d matrix of bin centers, with each row a
%                               [x_1, x_2, ..., x_d] combination.
%
% [pBin,edges] = gmmPBin(gmobj,centers)
% where     edges       is 1 x d cell array, containing bin edges for each
%                           of the d dimensions.
%
% if centers is a row vector of unidimensional data and gmobj is a Gaussian
% mixture distribution object in one dimension, gmmPBin will automatically
% fix it as a row vector.
%


firstEdge = [];
process_varargin(varargin);
n = length(centers);
K = gmobj.NComponents;
D = gmobj.NDimensions;

if size(centers,2) > 1 && size(centers,1)==1 && D==1
    disp('Centers is 1 x n, not n x 1. Fixing.')
    centers = centers(:);
end

assert(size(centers,2)==D,sprintf('Bin centers must have %d dimensions to match gmobj.',D))


tolX = nan(size(centers));
if nargout>1
    edges = cell(1,size(centers,2));
end
for d = 1 : D
    uniqueX = unique(centers(:,d));
    dX = diff(uniqueX);
    dX = [dX(1);dX];
    for iX = 1 : length(uniqueX)
        idX = centers(:,d)==uniqueX(iX);
        tolX(idX,d) = dX(iX);
    end
    if nargout>1
        edges{d} = unique([uniqueX;uniqueX-dX/2;uniqueX+dX/2]);
    end
end

if isempty(firstEdge)
    L = centers-tolX/2;
    U = centers+tolX/2;
end

% v = reshape(gmobj.Sigma,1,k);
% s = sqrt(v);
% Gaussian SD
v = gmobj.Sigma;
m = gmobj.mu;
% Gaussian Mean
t = gmobj.PComponents;
% Gaussian Mixing Coeff

% S = repmat(s,n,1);
% M = repmat(m,n,1);
% T = repmat(t,n,1);
% 
% L = repmat(l,1,k);
% U = repmat(u,1,k);

% c1 = normcdf(L,M,S).*T;
% c2 = normcdf(U,M,S).*T;

C1 = nan(n,d,K);
C2 = C1;
for component = 1 : K
    M = m(component,:);
    S = v(:,:,component);
    c1 = mvncdf(L,M,S)*t(component);
    c2 = mvncdf(U,M,S)*t(component);
    C1(:,:,component) = c1;
    C2(:,:,component) = c2;
end

pBin = C2 - C1;
if D==1
    pBin = squeeze(pBin);
end