function R = BayesianDecoding(Q, TC)

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
%   Q - tsd of firing rates by time - see MakeQfromS
%   TC - output of TuningCurves
%
% ADR/JS 2011-12

epsilon = 1e-100;
%---------------------
% PREP
%---------------------
assert(size(TC.H,1)==size(Q.data(),2), 'nCells does not match');

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
pxs = nan(nT, nB);
for iB = 1:nB
    if TC.Occ(iB)
        tempProd = nansum(log(repmat(TC0(:,iB),1,nT).^Q0));
        tempSum = exp(-Q.dt()*nansum(TC0(:,iB)));
        pxs(:,iB) = exp(tempProd)*tempSum*Px;
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