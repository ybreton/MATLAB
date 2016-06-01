function Thresholds = RROW_FindThresholds(TE)

% Thresholds = RROW_FindThresholds(TE)
% INPUT:
%   TE = taskEvents from sd
% OUTPUT
%   thresholds for each of n flavors

% assumes there four flavors and TE.Flavors is a list of 1..4

nFlavors = 4;

Thresholds = nan(nFlavors,1);

for iFlavor = 1:nFlavors
    offersSeen = TE.Offers(TE.Flavors==iFlavor);
    % FIND THRESHOLD
    Thresholds(iF) = ;
end

end