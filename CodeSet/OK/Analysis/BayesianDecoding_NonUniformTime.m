function R = BayesianDecoding_NonUniformTime(Q, dt, TC)

% R = BayesianDecoding(Q, TC)
%
% Constructs P(x|s) using BayesianDecoding
% P(x|s) = P(s|x) * P(x)/P(s)
%
% ASSUMES
%   1. cells are independent
%   2. cells are Poisson
%   3. P(x) is uniform
%
% INPUTS
%
%   Q - tsd of firing rates by time - see MakeQfromS_NonUniform
%   dt - size of timestep for each Q bin
%   TC - output of TuningCurves
%
% ADR/JS 2011-12
%modified to work with non-uniform time scales. ie, qmatrices from
%MakeQfromS_NonUniformTime
%amw - 14Mar2012
% 20120-05-21 AndyP
% added check that dt and Q match, moved .^Q0 exponent of logarithm on tempProd out
% front to be a multiplier
epsilon = 1e-100;
%---------------------
% PREP
%---------------------
assert(size(TC.H,1)==size(Q.data(),2), 'nCells does not match');
assert(length(dt)==size(Q.data(),1),'dt does not match');
Q0 = full(Q.data()'); % -> cells by time
[nC, nT] = size(Q0);

shape = size(TC.H); nB = prod(shape(2:end));
TC0 = reshape(TC.H, nC, nB);

%-------------------
% normalize TC to get spikes/sec
%-------------------
for iC = 1:nC
	TC0(iC,:) = TC0(iC,:) ./ TC.Occ(:)' + epsilon;
end

%-----------------
% Assume uniform occupancy
%-----------------
Px = 1/nB;

%---------------
% by bin
%---------------
% see (eq 36) Zhang and McNaughton, 1998
% In tempProd, we take advantage of the fact that the product is equal to the exponent of the sum of logarithms:
% exp(sum(Q0_{i}*ln(TC_{i})))=prod(TC_{i}^Q0_{i}) where f_{i}(x)=TC, and n_{i}=Q0, and i counts the cell number.
%
% This follows from the properties:
%
%            1) ln(xy)=ln(x)+ln(y)
%            2) exp(ln(x))=x
%            3) ln(x^y)=y*ln(x)
pxs = nan(nT, nB);
for iB = 1:nB
	if TC.Occ(iB)
		
		
		tempProd = nansum(Q0.*log(repmat(TC0(:,iB),1,nT)));
		tempSum = exp(-dt.*nansum(TC0(:,iB)));
		pxs(:,iB) = exp(tempProd').*tempSum*Px;
	end
end

for iT = 1:nT
	pxs(iT,:) = pxs(iT,:)./nansum(pxs(iT,:));
end

pxs = reshape(pxs, [nT shape(2:end)]);
pxs = tsd(Q.range(), pxs);
R.pxs = pxs;
R.min = TC.min;
R.max = TC.max;
R.nBin = TC.nBin;