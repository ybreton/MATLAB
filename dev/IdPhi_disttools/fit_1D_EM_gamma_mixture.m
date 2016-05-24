function [fit,LnL] = fit_1D_EM_gamma_mixture(x,c,K,varargin)

algorithm = 'interior-point';
display = 'off';
process_varargin(varargin);

%%

c = logical(c(:));
x = x(:);

%%
converge = false;
iter = 0;
tau_new(1,1:K) = 1/K;
[overallGammaFit] = gamfit(x,0.05,c);
overallKappa = overallGammaFit(1);
overallTheta = overallGammaFit(2);
LogKappaTheta_new(1,:) = ones(1,K)*log10(overallKappa);
LogKappaTheta_new(2,:) = ones(1,K)*log10(overallTheta);
LnL_new = -inf;

% fmincon options
OPTIONS = optimset('algorithm',algorithm,'display',display);
% fmincon equality constraints for weights
AeqTau = ones(1,K);
beqTau = 1;
% fmincon inequality constraints
% A * x < b
% [1 -1 0 0 0 ... 0] < 0
% sorted increasing.
AKT = zeros(K-1,K*2);
parfor k = 1 : K-1
    Akt = zeros(2,K);
    Akt(1,k) = 1;
    Akt(2,k) = 1;
    Akt(1,k+1) = -1;
    Akt(2,k+1) = -1;
    AKT(k,:) = Akt(:)';
end
bKT = zeros(K-1,1);

%%
while ~converge & iter<500
    iter = iter+1;
    tau_old = tau_new;
    LogKappaTheta_old = LogKappaTheta_new;
    LnL_old = LnL_new;
    
    % E step
    tau_new = fmincon(@(tau) nLnLikelihood(x,c,tau,LogKappaTheta_new),tau_old,[],[],AeqTau,beqTau,zeros(1,K),ones(1,K),[],OPTIONS);
    tau_new = tau_new(:)';
    
    delta_tau = abs(tau_new(:) - tau_old(:));
    % M step
    if K>1
        % Constrain to be ordered
        LogKappaTheta_new = fmincon(@(LogKappaTheta) nLnLikelihood(x,c,tau_new,LogKappaTheta),LogKappaTheta_old(:),AKT,bKT,[],[],[],[],[],OPTIONS);
    else
        % No constraint
        LogKappaTheta_new = fminsearch(@(LogKappaTheta) nLnLikelihood(x,c,tau_new,LogKappaTheta),LogKappaTheta_old(:),OPTIONS);
    end
    LogKappaTheta_new = reshape(LogKappaTheta_new,2,numel(LogKappaTheta_new)/2);
    
    delta_MS = abs(LogKappaTheta_new(:) - LogKappaTheta_old(:));
    
    LnL_new = -nLnLikelihood(x,c,tau_new,LogKappaTheta_new);
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
LnL = -nLnLikelihood(x,c,tau_new,LogKappaTheta_new);
fit = [tau_new;10.^LogKappaTheta_new];

%%

function nLnL = nLnLikelihood(x,c,tau,LogKappaTheta)
LogKappaTheta = reshape(LogKappaTheta,2,numel(LogKappaTheta)/2);
KappaTheta = 10.^LogKappaTheta;
tau = tau(:)';
if any(c)
    L(c) = censLike(x(c),tau,KappaTheta);
end
if any(~c)
    L(~c) = uncensLike(x(~c),tau,KappaTheta);
end
L(L==0) = eps;
LnL = log(L);
LnLsum = sum(LnL);
nLnL = -LnLsum;

function L = censLike(x,tau,KappaTheta)
K = size(KappaTheta,2);
S = zeros(length(x),K);
Kappas = KappaTheta(1,:);
Thetas = KappaTheta(2,:);
parfor k = 1 : K
    S(:,k) = 1-gamcdf(x,Kappas(k),Thetas(k));
end
L = S*tau';

function L = uncensLike(x,tau,KappaTheta)
K = size(KappaTheta,2);
P = zeros(length(x),K);
Kappas = KappaTheta(1,:);
Thetas = KappaTheta(2,:);
parfor k = 1 : K
    P(:,k) = gampdf(x,Kappas(k),Thetas(k));
end
L = P*tau';
