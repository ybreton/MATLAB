function [fit,LnL] = fit_1D_EM_gaussian_mixture(x,c,K,varargin)

global MinDiff
algorithm = 'interior-point';
display = 'off';
MinDiff = 0;
process_varargin(varargin);
MinDiff = abs(MinDiff);
%%

c = logical(c(:));
x = x(:);

%%
converge = false;
iter = 0;
tau_new(1,1:K) = 1/K;
[MS(1), MS(2)] = normfit(x,0.05,c);

MuSigma_new(1,:) = ones(1,K)*MS(1);
MuSigma_new(2,:) = MS(2);
LnL_new = -inf;

% fmincon options
OPTIONS = optimset('algorithm',algorithm,'display',display);
% fmincon equality constraints for weights
AeqTau = ones(1,K);
beqTau = 1;
% fmincon lower bounds for Mu (none), Sigma (zero)
lbMS(1,1:K) = -inf;
lbMS(2,1:K) = 0;
% fmincon inequality constraints for Mu (sorted), Sigma (none).
% A * x < b
% [1 -1 0 0 0 ... 0] < 0
% sorted increasing.
AMS = [];
parfor k = 1 : K-1
    Am = zeros(1,K);
    Am(k) = 1;
    Am(k+1) = -1;
    As = zeros(1,K);
    As(k:k+1) = 0;
    Amsk = [Am;As];
    AMS(k,:) = Amsk(:);
end
bMS = zeros(K-1,1);

%%
while ~converge & iter<500
    iter = iter+1;
    tau_old = tau_new;
    MuSigma_old = MuSigma_new;
    LnL_old = LnL_new;
    
    % E step
    tau_new = fmincon(@(tau) nLnLikelihood(x,c,tau,MuSigma_new),tau_old,[],[],AeqTau,beqTau,zeros(1,K),ones(1,K),[],OPTIONS);
    tau_new = tau_new(:)';
    
    delta_tau = abs(tau_new(:) - tau_old(:));
    % M step
    MuSigma_new = fmincon(@(MuSigma) nLnLikelihood(x,c,tau_new,MuSigma),MuSigma_old(:),AMS,bMS,[],[],lbMS,[],@nonlincon,OPTIONS);
    MuSigma_new = reshape(MuSigma_new,2,numel(MuSigma_new)/2);
    
    delta_MS = abs(MuSigma_new(:) - MuSigma_old(:));
    
    LnL_new = -nLnLikelihood(x,c,tau_new,MuSigma_new);
    delta_LnL = (LnL_new - LnL_old);
    
    if all(delta_LnL<1e-3) || (all(delta_tau<1e-3) && all(delta_MS<1e-3))
        converge = true;
    end
    if mod(iter,10)==0
        fprintf('.')
    end
    if mod(iter,100)==0
        fprintf('\n')
    end
end
LnL = -nLnLikelihood(x,c,tau_new,MuSigma_new);
fit = [tau_new;MuSigma_new];

%%

function [c,ceq] = nonlincon(ms)
%
%
%
%
global MinDiff
ms=reshape(ms,2,numel(ms)/2);
c = zeros(size(ms,2),1);
if size(ms,2)>1
    for k = 1 : size(ms,2)-1
        d = ms(1,k+1)-ms(1,k);
        c(k) = MinDiff*(max(ms(2,k),ms(2,k+1))) - d;
    end
else
    c = 0;
end
ceq = 0;

function nLnL = nLnLikelihood(x,c,tau,MuSigma)
MuSigma = reshape(MuSigma,2,numel(MuSigma)/2);
tau = tau(:)';
if any(c)
    L(c) = censLike(x(c),tau,MuSigma);
end
if any(~c)
    L(~c) = uncensLike(x(~c),tau,MuSigma);
end
L(L==0) = eps;
LnL = log(L);
LnLsum = sum(LnL);
nLnL = -LnLsum;

function L = censLike(x,tau,MuSigma)
K = size(MuSigma,2);
S = zeros(length(x),K);
Mus = MuSigma(1,:);
Sigmas = MuSigma(2,:);
parfor k = 1 : K
    S(:,k) = 1-normcdf(x,Mus(k),Sigmas(k));
end
L = S*tau';

function L = uncensLike(x,tau,MuSigma)
K = size(MuSigma,2);
P = zeros(length(x),K);
Mus = MuSigma(1,:);
Sigmas = MuSigma(2,:);
parfor k = 1 : K
    P(:,k) = normpdf(x,Mus(k),Sigmas(k));
end
L = P*tau';
