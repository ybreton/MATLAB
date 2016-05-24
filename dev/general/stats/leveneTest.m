function [h,p,W] = leveneTest(X,G,varargin)
%
%
%
%

alpha=0.05;
process_varargin(varargin);

assert(alpha>0&alpha<1,'alpha must be in (0,1).')
assert(length(size(G))==2,'Grouping variable must be n x 1 or n x m.');
if size(G,1)==1 && size(G,2)>1
    G = G';
end

uniqueG = unique(G,'rows');
k = size(uniqueG,1);
N = size(G,1);

Xbar = nan(N,1);
for iG=1:k
    compG = uniqueG(iG,:);
    compG = repmat(compG,[N 1]);
    idG = all(compG==G,2);
    Xbar(idG) = nanmean(X(idG));
end
Z = abs(X-Xbar);
Zgrand = nanmean(Z);
Zbar = nan(N,1);
for iG=1:k
    compG = uniqueG(iG,:);
    compG = repmat(compG,[size(G,1) 1]);
    idG = all(compG==G,2);
    Zbar(idG) = nanmean(Z(idG));
end
deva = Zbar-Zgrand;
SSa = deva(:)'*deva(:);
devr = Z-Zbar;
SSerr = devr(:)'*devr(:);

W = (N-k)/(k-1) * SSa/SSerr;

Fcrit = finv(alpha,k-1,N-k);

h = W>Fcrit;

p = 1-fcdf(W,k-1,N-k);
