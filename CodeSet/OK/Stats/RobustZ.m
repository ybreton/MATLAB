function [z,mu,sigma] = RobustZ(x)

% [z,mu,sigma] = RobustZ(x)
% 
% Calculates mu and sigma from middle range of data within IQR of 25-75
% around median.  Calculates z from this.
%
% ADR 2012/06

DEBUG = false;

mu = 0;
lastmu = inf;
keep = true(size(x));

while abs(mu-lastmu)>0

	m = nanmedian(x(keep));
	lo = prctile(abs(x-m),0);
	hi = prctile(abs(x-m),50);

	keep = abs(x-m)>lo & abs(x-m)<hi;

	mu = nanmean(x(keep));
	sigma = nanstd(x(keep));
	
	if DEBUG
		disp(sprintf('%.2f -> %.2f', lastmu, mu));
	end
	lastmu = mu;
	
end

z = (x-mu)/sigma;
	