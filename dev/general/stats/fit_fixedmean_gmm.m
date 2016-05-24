function [taus,sigmas] = fit_fixedmean_gmm(x,mus,sigma0,tau0,varargin)
% finds the maximum-likelihood mixture components for the mixture containing
% gaussians of mean mu and standard deviation sigma.
% taus = fit_gauss_taus(x,mus,sigmas)
%
%
tol = 1e-4;
debug=false;
process_varargin(varargin);

x = sort(x(:));
n = length(x);
k = length(mus);
assert(length(mus)==length(sigma0),'List of mus must have same length as list of sigmas.');

mus = mus(:)';
sigma0 = sigma0(:)';
taus = tau0(:)';
[lo,idlo] = min(mus);
[hi,idhi] = max(mus);
if debug
    fh=figure;
end

X = repmat(x,1,k);
M = repmat(mus,n,1);
S = repmat(sigma0,n,1);
T = repmat(tau0,n,1);

converge = false;
iter = 0;
LnL = -inf;
while ~converge
    iter = iter+1;
    % P[X=xi|Z=zj]*P[Z=zj]
    pXcondZ = normpdf(X,M,S).*T;
    
    % P[X=xi]
    pX = sum(pXcondZ,2);
    % P[Z=zj|X=xi] = P[X=xi|Z=zj]*P[Z=zj]/P[X=xi]
    rij = pXcondZ./repmat(pX,1,k);
    
    % sigma_j = sum_i( P[Z=zj|X=xi]*(xi-mu_j)*(xi-mu_j)' ) 
    %           / sum_i (P[Z=zj|X=xi])
    sigmaOld = S(1,:);
    tauOld = T(1,:);
    LnLOld = LnL;
    sigmas = sqrt(sum(rij.*(X-M).^2,1)./sum(rij,1));
    % tau_j = 1/n * sum_i (P[Z=zj|X=xi])
    taus = sum(rij,1)/n;
    
    S = repmat(sigmas,n,1);
    T = repmat(taus,n,1);
    
    % Log[L] = sum_i ( Log ( P[X=xi|theta_t] ) )
    LnL = sum(log(pX));
    delta = LnL - LnLOld;
    if delta<1e-6 || iter>500
        converge = true;
    elseif debug
        [f,bin]=hist(x,30);
        w=mean(diff(bin));
        clf
        hold on
        bh=bar(bin,f./sum(f),1);
        set(get(bh,'children'),'facecolor',[0.8 0.8 0.8]);
        for jK=1:k
            d(:,jK)=normcdf(bin+w/2,mus(jK),sigma0(jK))-normcdf(bin-w/2,mus(jK),sigma0(jK));
        end
        plot(bin,d.*repmat(taus,30,1),'-','linewidth',1)
        plot(bin,d*taus(:),'r-','linewidth',2)
        plot(mus,zeros(k,1),'rs','markersize',16)
        hold off
        drawnow
    end
end

if debug
    close(fh)
end
    

