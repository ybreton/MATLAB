function taus = fit_gauss_taus(x,mus,sigmas,tau0,varargin)
% finds the maximum-likelihood mixture components for the mixture containing
% gaussians of mean mu and standard deviation sigma.
% taus = fit_gauss_taus(x,mus,sigmas)
% where     taus    is a vector of the mixing coefficients;
%           x       is a vector of observations,
%           mus     is a vector of means, for each component j,
%           sigmas  is a vector of variances, for each component j.
% optional parameters:
% debug     (default false)     display a histogram and result of mixture fit.
% const     (default 0)         assign all observations less than
%                               mu-const*sigma of lowest mean, and
%                               mu+const*sigma of highest mean, to lowest
%                               and highest components exclusively.
% censoring (default all false) logical vector specifying which x values
%                               are censored.
%
debug=false;
const = 0;
censoring = false(length(x),1);
process_varargin(varargin);

x = sort(x(:));
idnan = isnan(x);
x(idnan) = [];

n = length(x);
k = length(mus);
assert(length(mus)==length(sigmas),'List of mus must have same length as list of sigmas.');

mus = mus(:)';
sigmas = sigmas(:)';

[~,klo] = min(mus);
[~,khi] = max(mus);

if debug
    fh=figure;
end

X = repmat(x,1,k);
M = repmat(mus,n,1);
S = repmat(sigmas,n,1);

pXcondZ = normpdf(X,M,S);
if any(censoring)
    pXcondZ(censoring,:) = 1-normcdf(X(censoring,:),M(censoring,:),S(censoring,:));
end

pX = sum(pXcondZ,2);
% responsibility of distribution j for observation i
rij = pXcondZ./repmat(pX,1,k);
% Correction for very, very low or very, very high observations 
% (i.e., when p[X|Z] is approximately 0 for all j)
idlo = x<=mus(klo)-const*sigmas(klo);
idhi = x>=mus(khi)+const*sigmas(khi);
rij(idlo,:) = 0; rij(idlo,klo)=1;
rij(idhi,:) = 0; rij(idhi,khi)=1;



taus = nansum(rij,1)/n;
if debug
    [f,bin]=hist(x,30);
    w=mean(diff(bin));
    hold on
    bh=bar(bin,f./sum(f),1);
    set(get(bh,'children'),'facecolor',[0.8 0.8 0.8]);
    for jK=1:k
        d(:,jK)=normcdf(bin+w/2,mus(jK),sigmas(jK))-normcdf(bin-w/2,mus(jK),sigmas(jK));
    end
    plot(bin,d.*repmat(taus,30,1),'-','linewidth',1)
    plot(bin,d*taus(:),'r-','linewidth',2)
    plot(mus,zeros(k,1),'rs','markersize',16)
    hold off
    drawnow
    close(fh)
end
    

