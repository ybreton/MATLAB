function p = gmmPosteriors1D(x,gmobj)
% Returns an m x n x ... x k matrix of posterior probabilities of component
% k given x.
% Assumes gmobj is 1-dimensional.
%
%
%

sz = size(x);
x0 = x(:);

p0 = gmobj.posterior(x0);
p = [];
for iK=1:size(p0,2)
    pK = reshape(p0(:,iK),sz);
    p = cat(length(sz)+1,p,pK);
end
