function dx = dxdt2(x,varargin)

window = 1; % seconds
postSmoothing = 0.5; % seconds --- 0 means don't
display = 0;
process_varargin(varargin);

x = ctsd(removeNaNs(x));
xD = x.data();
dT = x.dt();

nW = min(ceil(window/x.dt()),length(xD));
nX = length(xD);

MSE = zeros(nX, nW);
b = zeros(nX,nW);

MSE(:,1:2) = Inf;
nanvector = nan(nW,1);

for iN = 3:nW
	if display, fprintf(2,'.'); end
	b(:,iN) = ([nanvector(1:iN); xD(1:(end-iN))] - xD)/iN;
	for iK = 1:iN
		q = ([nanvector(1:iK); xD(1:(end-iK))] - xD + b(:,iN) * iK);
		MSE(:,iN) = MSE(:,iN) + q.*q;		
	end
	MSE(:,iN) = MSE(:,iN)/iN;	
end
if display, fprintf(2, '!'); end

[~, nSelect] = min(MSE,[],2);
dx = nan .* ones(size(xD));
for iX = 1:nX
	dx(iX) = -b(iX,nSelect(iX)) / dT;  % CORRECTED ADR 6 August 2012 - it was returning the negative direction
end

if postSmoothing
	nS = ceil(postSmoothing/x.dt());
	dx = conv2(dx,ones(nS)/nS,'same');
end
	
dx = tsd(x.range(),dx);