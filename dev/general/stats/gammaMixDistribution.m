function fit = gammaMixDistribution(x,k,varargin)
%
%
%
%

Replicates = 1;
OPTIONS = optimset('algorithm','interior-point','display','off');
maxIters = 100;
tol = 0.01;
process_varargin(varargin);

assert(length(x)>2*k,sprintf('Not Enough Observations For Mixture of %d Gamma Distributions.',k))

parfor rep = 1 : Replicates
    id = randperm(length(x));
    Tau = repmat(1/k,1,k);
    n = floor(length(x)/k);
    idRep = reshape(id(1:n*k),n,k);
    for comp = 1 : k
        KappaTheta(:,comp) = gamfit(x(idRep(:,comp)));
    end
    nLnL = NegLogLikelihood(x,KappaTheta,Tau);
    converge = false;
    Iters = 0;
    converged = true;
    while ~converge && Iters<maxIters
        if k>1
            Tau0 = Tau;
            % Arrange by weight.
            A = zeros(k-1,k);
            b = zeros(k-1,1);
            for comp = 1 : k-1
                A(comp,comp) = -1;
                A(comp,comp+1) = 1;
            end
            Aeq = ones(1,k);
            beq = 1;
            lb = zeros(1,k);
            ub = ones(1,k);
            Tau = fmincon(@(Tau) NegLogLikelihood(x,KappaTheta,Tau),Tau0,A,b,Aeq,beq,lb,ub,[],OPTIONS);
            [Tau,idSort] = sort(Tau);
            KappaTheta = KappaTheta(:,idSort);
        end
        KappaTheta0 = KappaTheta;
        A = [];
        b = [];
        Aeq = [];
        beq = [];
        lb = zeros(1,k);
        ub = inf;
        KappaTheta = fmincon(@(KappaTheta) NegLogLikelihood(x,KappaTheta,Tau),KappaTheta0,A,b,Aeq,beq,lb,ub,[],OPTIONS);
        KappaTheta = reshape(KappaTheta,numel(KappaTheta)/k,k);
        nLnLold = nLnL;
        nLnL = NegLogLikelihood(x,KappaTheta,Tau);
        Iters = Iters+1;
        if abs(nLnLold-nLnL)<tol
            converge = true;
            converged = true;
        end
        if Iters>=maxIters
            converged = false;
        end
    end
    LnLrep(rep) = -nLnL;
    fitList(rep).KappaTheta = KappaTheta;
    fitList(rep).Tau = Tau;
    fitList(rep).Iters = Iters-1;
    fitList(rep).converged=converged;
end
[LnL,idMax] = max(LnLrep);
NLogL = -LnL;
Tau = fitList(idMax).Tau;
KappaTheta = fitList(idMax).KappaTheta;
converged = fitList(idMax).converged;
Iters = fitList(idMax).Iters;
AIC = -2*LnL+2*(k*2+k-1);
BIC = -2*LnL+(k*2+k-1)*log(length(x));

fit.NDimensions=1;
fit.DistName='gamma mixture distribution';
fit.NComponents=k;
fit.PComponents=Tau;
fit.Kappa=KappaTheta(1,:);
fit.Theta=KappaTheta(2,:);
fit.mu=prod(KappaTheta,1);
fit.Sigma=reshape(sqrt(KappaTheta(1,:).*(KappaTheta(2,:).^2)),1,1,k);
fit.NlogL=NLogL;
fit.AIC=AIC;
fit.BIC=BIC;
fit.Converged=converged;
fit.Iters=Iters;
fit.SharedCov=0;
fit.CovType='full';
fit.RegV=0;


function NlnL = NegLogLikelihood(x,KappaTheta,Tau)

KappaTheta = reshape(KappaTheta(:),2,numel(KappaTheta)/2);

f = nan(length(x),size(KappaTheta,2));
for k = 1 : size(KappaTheta,2)
    f(:,k) = gampdf(x,KappaTheta(1,k),KappaTheta(2,k));
end
g = f*Tau(:);

LnL = log(g);
NlnL = -sum(LnL);