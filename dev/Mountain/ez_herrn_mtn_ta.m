function TA  = ez_herrn_mtn_ta(x,params)
% TA  = ez_herrn_mtn_ta(x,params)
%           x(:,1) = log10 amount
%           x(:,2) = log10 delay
%           x(:,3) = Probability
%           x(:,4) = ZoneIn
%
%     A = params(1);
%     k = params(2);
%     S0 = params(3);
%     Sp = params(4);
%     Ce = 10.^params(5);
%     F = 10.^params(6:end);
%
% TA = (U.^A)./(U.^A+Uskip.^A)
% Ui = Ri
% Ri = (ni^G)/(ni^G+nfhm^G)
% Ci = 1/(1+k*Di)
% Ce = (Imax/(1+k*Di))*Psi
% Psi = max(min(1,S0+Sp*Pr),0);
% Uskip = C/Ce


LogN = x(:,1);
LogD = x(:,2);
Pr = x(:,3);
Z = x(:,4);

A = params(1);
k = params(2);
S0 = params(3);
Sp = params(4);
Ce = 10.^params(5);
Fhm = 10.^params(6:end);

Ps = min(1,(Pr+S0)*Sp);

n = 10.^LogN;
D = 10.^LogD;
flvr = nan(length(Z),1);
for choice = 1 : length(Z)
    flvr(choice) = Fhm(Z(choice));
end

C = Ps./(1+k.*D);
R = (n.*flvr);

U = R;
Uskip = (C./(Ce./Ps));

TA = (U.^A)./(U.^A+Uskip.^A);