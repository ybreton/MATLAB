function [p, stats] = WatsonsCircU(phi, psi)

% [p, stats] = WatsonsCircU(phi, psi)
%
% p = probability value (note, assumes n, m > 
% stats structure returned:
%   U2 = U^2 statistic
%   cumsumPhi = cumsum(phi)
%   cumsumPsi = cumsum(psi)
%   theta = angular x
% 
% phi and psi are assumed to be in radians
%
% Source: Batschelet 1981

phi = phi(:)';
psi = psi(:)';

% remove nans
phi(isnan(phi)) = [];
psi(isnan(psi)) = [];

% add some jitter to remove possibility of equivalence
phi = phi + (rand(size(phi))-0.5)*(1e-15);
psi = psi + (rand(size(psi))-0.5)*(1e-15);

phi = sort(phi);
psi = sort(psi);

n = length(phi);
m = length(psi);
N = n+m;

[allAngles sortorder] = sort([phi psi]);

phiKey = [ones(size(phi))  zeros(size(psi))];
psiKey = [zeros(size(phi)) ones(size(psi))];

phiKey = phiKey(sortorder);
psiKey = psiKey(sortorder);
cumsumPhi = cumsum(phiKey)/n;
cumsumPsi = cumsum(psiKey)/m;

d = (cumsumPhi - cumsumPsi);
U2 = n*m/N^2 * (sum(d.^2) - (sum(d)^2)/N);

stats.cumsumPhi = cumsumPhi;
stats.cumsumPsi = cumsumPsi;
stats.theta = allAngles * 180/pi;
stats.U2 = U2;

% p-values
if n<100 || m<100
	warning('P-values for Watson''s U assume n>10 & m>12.');
	p = nan;
else
	p = 1.0;
	critU2 = 0;
	while U2 > critU2
		p = p/10;
		critU2 = -(1/2/pi^2)*(log(p/2) - log(1+(p/2)^3));
	end
end
	