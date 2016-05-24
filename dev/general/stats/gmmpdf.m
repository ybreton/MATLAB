function p = gmmpdf(gmobj,x)
% Returns the probability density function of each component Gaussian in a
% gmdistribution object evaluated at x.
%
% p = gmmpdf(gmobj,x)
% where     p           is an n x d x k matrix of probability densities, or
%                           n x k if unidimensional.
%
%           gmobj       is a gmdistribution object with k components in d
%                           dimensions
%           x           is a list of x values for the pdf, in d-dimensions
%                           where each row is [x_1, x_2, ..., x_d]
%

n = length(x);
K = gmobj.NComponents;
D = gmobj.NDimensions;

if size(x,2) > 1 && size(x,1)==1 && D==1
    disp('x is 1 x n, not n x 1. Fixing.')
    x = x(:);
end

assert(size(x,2)==D,sprintf('x values must have %d columns to match gmobj dimensions.',D))

v = gmobj.Sigma;
m = gmobj.mu;
t = gmobj.PComponents;

p = nan(n,D,K);
for component = 1 : K
    M = m(component,:);
    S = v(:,:,component);
    p(:,:,component) = mvnpdf(x,M,S)*t(component);
end

if D==1
    p = squeeze(p);
end