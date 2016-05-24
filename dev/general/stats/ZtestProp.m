function [h,p,Z,m,se] = ZtestProp(x,varargin)
%
%
%
%

alpha=0.05;
tails=2;
ctype='Bonferroni';
g = nan(size(x));
for iC=1:size(x,2)
    g(:,iC) = iC;
end
process_varargin(varargin);
assert(all(size(x)==size(g)),'Size of x and g must match.')
nGrps=length(unique(g(:)));
nComps=nchoosek(nGrps,2);
process_varargin(varargin);

if strncmpi('hsd',ctype,3)
    alphaAdj = alpha;
end
if strncmpi('Bonf',ctype,4);
    alphaAdj = alpha./nComps;
end
idnan = isnan(g)|isnan(x);
uniqueG = unique(g(~idnan));

m = nan(length(uniqueG),1);
n = nan(length(uniqueG),1);
for iG=1:length(uniqueG)
    idG = g==uniqueG(iG);
    n(iG) = sum(x(idG)==1|x(idG)==0);
    m(iG) = sum(x(idG)==1)./sum(x(idG)==1|x(idG)==0);
end
se = sqrt(m.*(1-m)./n);

Z = nan(length(uniqueG));
for iG1=1:length(uniqueG)-1
    idG1 = g==uniqueG(iG1);
    y1 = sum(x(idG1)==1);
    n1 = sum((x(idG1)==1)|(x(idG1)==0));
    p1 = y1/n1;
    
    for iG2=iG1+1:length(uniqueG)
        idG2 = g==uniqueG(iG2);
        y2 = sum(x(idG2)==1);
        n2 = sum((x(idG2)==1)|(x(idG2)==0));
        p2 = y2/n2;
        phat = (y1+y2)./(n1+n2);
        num = p2-p1;
        denom = sqrt((phat).*(1-phat).*(1./n1+1./n2));
        Z(iG2,iG1) = num./denom;
        Z(iG1,iG2) = -num./denom;
    end
end
p = 1-normcdf(abs(Z),0,1);
h = p<(alphaAdj/tails);