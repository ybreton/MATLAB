function [fit,LnL] = fit_1D_EM_NormLogNorm(x,c,D,varargin)
% Fits a mixture of K normal (D=0) and log-normal distributions (D=1) to
% data in x, with censored observations in c.
% fit = fit_1D_EM_NormLogNorm(x,c,D,varargin)
% where     fit is (4 x K) matrix with distribution, proportion, mean, s.d. in log space
%           lx   is (n x 1) vector of log-observations
%           c   is (n x 1) indicator vector of censored observations
%           D   is (1 x K) indicator vector of log-normal distributions
% and
%           algorithm = 'interior-point'    (algorithm for fmincon)
%           display   = 'off'               (display iterations of fmincon)
%

algorithm = 'interior-point';
display = 'off';
plotFlag = true;
debug = true;
minDiffComp = 0;
nBoots = 500;
tolCompProp = 0.01;
process_varargin(varargin);
OPTIONS = optimset('algorithm',algorithm,'display',display);

if isempty(c)
    c = zeros(size(x));
end
% Turn into column vectors.
x = x(:);
c = logical(c(:));
D = logical(D(:)');
% Exclude non-positive x values.
idExc = x<=0;
x(idExc) = [];
c(idExc) = [];

lx = log10(x);

% K is the number of components.
K = length(D);

% Wherever D==0, x ~ N(mu,sigma).
% Wherever D==1, log10(x) ~ N(mu,sigma).


% Inequality constraints for tau: none.
A_tau = [];
b_tau = [];
% Equality constraints for tau: sum of all taus must be 1 (convex
% combination).
%
% [1 1 ... 1] * [tau(i)     == 1
%                tau(i+1)
%                ...
%                tau(K)]
Aeq_tau = ones(1,K);
beq_tau = 1;
% Lower bound on tau: no component less than basically 0.
LB_tau = zeros(1,K)+tolCompProp;
% Upper bound on tau: no component more than basically 1.
UB_tau = ones(1,K)-tolCompProp;

% Inequality constraints for Mu/Sigma:
%   for normal distributions,
%       Mu = 10.^log(mean(x))
%   for lognormal,
%       Mu = 10.^mean(log(x))
%   ->
%   Mu(i) < Mu(i+1)
% log10(Mu(i)) < log10(Mu(i+1))
%   Mu(i) - Mu(i+1) <= tol
% [1 -1 0 ... 0] * [Mu(i)   <= tol
%                   Mu(i+1)
%                   ...
%                   Mu(K)]

A_ms = zeros(K-1,2*K);
b_ms = ones(K-1)*minDiffComp;
parfor k = 1 : K-1
    A = zeros(2,K);
    A(1,k) = 1;
    A(1,k+1) = -1;
    A_ms(k,:) = A(:)';
end

% Equality constraints for Mu/Sigma: none.
Aeq_ms = [];
beq_ms = [];
% Lower/Upper bound on Mu:
%   for normal distributions, min(x)<=m(x)<=max(x) -> min(lx)<=log(m(x))<=max(lx)
%   for lognormal, min(lx)<=m(lx)<=max(lx)
LB_ms(1,1:K) = min(lx);
UB_ms(1,1:K) = max(lx);
% Lower/Upper bound on Sigma:
%   for normal distributions, s(x)>0 -> log(s(x)) > -inf
%   for lognormal, s(lx)>0
LB_ms(2,~D) = -inf;
LB_ms(2,D) = 0;
UB_ms(2,1:K) = inf;

ListOfParams = zeros(nBoots,K,2);
parfor attempt = 1 : nBoots
    params = zeros(2,K);
%     params(1,:) = sort(rand(1,K)*(max(lx)-min(lx))+min(lx));
    mu0 = linspace(min(lx),max(lx),K+2);
    params(1,:) = mu0(2:length(mu0)-1);
    params(2,:) = sqrt(var(lx)/K);
    ListOfParams(attempt,:,:) = reshape(params,1,2,K);
end

fitList = zeros(nBoots,4,K);
LnL = nan(nBoots,1);
for attempt = 1 : nBoots
    LogMuSigma_new = squeeze(ListOfParams(attempt,:,:));
    tau_new = ones(1,K)./K;
    
    LnL_new = inf;
    converge = false;
    iter = 0;
    while ~converge && iter < 500
        iter = iter + 1;
        % Make new estimates the old estimates.
        tau_old = tau_new;
        LogMuSigma_old = LogMuSigma_new;
        LnL_old = LnL_new;

        % E-step. Find mixture proportions.
        tau_new = fmincon(@(tau) nLogLikelihood(x,c,D,tau,LogMuSigma_new),tau_old,A_tau,b_tau,Aeq_tau,beq_tau,LB_tau,UB_tau,[],OPTIONS);

        % M-step. Find mixture parameters.
        LogMuSigma_new = fmincon(@(LogMuSigma) nLogLikelihood(x,c,D,tau_new,LogMuSigma),LogMuSigma_old,A_ms,b_ms,Aeq_ms,beq_ms,LB_ms,UB_ms,@nonlinconst,OPTIONS);
        LogMuSigma_new = reshape(LogMuSigma_new,2,numel(LogMuSigma_new)/2);

        LnL_new = -nLogLikelihood(x,c,D,tau_new,LogMuSigma_new);
        delta_LnL = abs(LnL_new - LnL_old);
        if delta_LnL < 1e-3
            converge = true;
        end
    end
    fit = [D;tau_new(:)';LogMuSigma_new];
    fitList(attempt,:,:) = fit;
    LnL(attempt) = LnL_new;
end
[LnL,idBest] = max(LnL);
fit = squeeze(fitList(idBest,:,:));

function [c,ceq] = nonlinconst(LogMuSigma)
LogMuSigma = reshape(LogMuSigma,2,numel(LogMuSigma)/2);
K = size(LogMuSigma,2);

MuSigma = 10.^LogMuSigma;
Mu = MuSigma(1,:);
A = eye(K-1,K) + [zeros(K-1,1) -eye(K-1,K-1)];
c = A*Mu(:);
ceq = 0;

function nLnL = nLogLikelihood(x,c,D,tau,LogMuSigma)
LogMuSigma = reshape(LogMuSigma,2,numel(LogMuSigma)/2);

if any(c)
    L(c) = mixSurv(x,D,tau,LogMuSigma);
end
if any(~c)
    L(~c) = mixDens(x,D,tau,LogMuSigma);
end
L(L<=10^-15) = 10^-15;
LnL = log(L);
LnLs = sum(LnL);
nLnL = -LnLs;

function md = mixDens(x,D,tau,LogMuSigma)
LogMU = LogMuSigma(1,:);
LogSIGMA = LogMuSigma(2,:);
MU = 10.^LogMU;
SIGMA = 10.^LogSIGMA;
K = length(tau);
lx = log10(x);
d = zeros(length(x),K);
for k = 1 : K
    if D(k)
        % log-normal
        d(:,k) = normpdf(lx,LogMU(k),LogSIGMA(k));
    else
        % normal
        d(:,k) = normpdf(x,MU(k),SIGMA(k));
    end
end
md = d*tau(:);

function ms = mixSurv(x,D,tau,LogMuSigma)
LogMU = LogMuSigma(1,:);
LogSIGMA = LogMuSigma(2,:);
MU = 10.^LogMu;
SIGMA = 10.^LogSIGMA;
K = length(tau);
lx = log10(x);
s = zeros(length(x),K);
for k = 1 : K
    if D(k)
        % log-normal
        s(:,k) = 1-normcdf(lx,LogMU(k),LogSIGMA(k));
    else
        % normal
        s(:,k) = 1-normcdf(x,MU(k),SIGMA(k));
    end
end
ms = s*tau(:);