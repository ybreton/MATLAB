function [params,LnL,stats] = fit_value_logit_DD(L,A,D,C,varargin)
%
%
%
%

params0 = glmfit(D(:),C(:),'binomial');
params0(1) = 10;
params0(2) = 1;
params0(3) = abs(params0(2));
params0(4) = 1;
process_varargin(varargin);

OPTIONS = optimset('algorithm','interior-point','display','off');

lb = [0 0 0 0];
params = fmincon(@(params) negloglike(L,A,D,C,params),params0,[],[],[],[],lb,[],[],OPTIONS);
LnL = -negloglike(L,A,D,C,params);
LnL0 = -negloglike(L,A,D,C,[0 0 0 0]);
LLR = log(exp(LnL)/exp(LnL0));
p = 1-chi2cdf(LLR,4);

stats.LnL = LnL;
stats.LLR = LLR;
stats.p = p;

Lhm = params(1);
Betamax = params(2);
g = params(3);
k = params(4);

V = A.*(1./(1+params(4).*D));
[V,idSort] = sort(V);

clf
subplot(1,3,1)
hold on
beta = (L.^g)./(L.^g+Lhm.^g)*Betamax;
plot(L,beta,'ro')
hold off
subplot(1,3,2)
plot_grouped_Y(V,C(idSort))
hold on
plot(V,valfun(L,A,D,params),'r-')
hold off
subplot(1,3,3)
hold on
plot(D(idSort),V,'ro')
hold off

function NLnL = negloglike(L,A,D,C,params)
Lhm = params(1);
Betamax = params(2);
g = params(3);
k = params(4);

e = exp(1);

Vd = A.*1./(1+k.*D);
Vi = 1.*1./(1+k.*1);
beta = (L.^g)./(L.^g+Lhm.^g)*Betamax;

Pd = e.^(beta.*Vd)./(e.^(beta.*Vd)+e.^(beta.*Vi));

LnL = C(:).*log(Pd) + (1-C(:)).*log(1-Pd);
NLnL = -sum(LnL);


function val = valfun(L,A,D,params)
Lhm = params(1);
Betamax = params(2);
g = params(3);
k = params(4);
e = exp(1);

beta = (L.^g)./(L.^g+Lhm.^g).*Betamax;

val = e.^(beta.*(A./(1+k*D)))./(e.^(beta.*(A./(1+k*D)))+e.^(beta.*(1./(1+k*1))));