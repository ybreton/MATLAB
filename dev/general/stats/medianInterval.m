function [ci,rnk] = medianInterval(x,alpha)
% Returns the distribution-free confidence interval about the median, where
% the rank of the lower bound is
% n/2 - Zc*sqrt(n)/2,
% and the rank of the upper bound is
% 1 + n/2 + Zc*sqrt(n)/2.
% 
% 

if nargin<2
    alpha=0.05;
end

x0 = sort(x(~isnan(x)));
n = length(x0);
ranks = 1:n;

% critical z
Zc = norminv(1-alpha/2,0,1);

rnk = nan(2,1);
ci = nan(2,1);

% lower CB is given by the
% n/2 - Zc*sqrt(n)/2 ranked value
R = n/2 - Zc*sqrt(n)/2;
rnk(1) = max(1,round(R));
ci(1) = interp1(ranks,x0,R);

% upper CB is given by the
% 1 + n/2 + Zc*sqrt(n)/2 ranked value
R = 1 + n/2 + Zc*sqrt(n)/2;
rnk(2) = min(n,round(R));
ci(2) = interp1(ranks,x0,R);
