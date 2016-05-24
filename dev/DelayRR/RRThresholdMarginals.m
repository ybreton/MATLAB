function [marginalAmountByFlavour,marginalFlavourByAmount,marginalAmountFlavour] = RRThresholdMarginals(sd,varargin)
% Produces matrices of thresholds marginalzed over amount for each flavour,
% over flavour for each amount, or over both for entire session.
% [marginalAmountByFlavour,marginalFlavourByAmount,marginalAmountFlavour] = RRThresholdMarginals(sd)
% where     marginalAmountByFlavour      is nZone x nPellet vector of
%                                           thresholds for any amount of a
%                                           flavour,
%           marginalFlavourByAmount      is nZone x nPellet vector of
%                                           thresholds for any flavour of
%                                           an amount,
%           marginalAmountFlavour        is nZone x nPellet vector of
%                                           thresholds for any flavour or
%                                           amount.
%           
%           sd              is nSubsess x 1 structure of sd.
% 
% Note:
% marginalAmountByFlavour should have identical values across columns,
%   since no matter what the amount, the marginalized threshold is the
%   same.
% marginalFlavourByAmount should have identical values across rows, since
%   no matter what the flavour, the marginalized threshold is the same.
% marginalAmountFlavour should have identical values throughout the matrix,
%   since the threshold is marginalized across both zones and pellets.
%
% OPTIONAL ARGUMENTS:
% ******************
% nZones        (default 4)     number of zones
% maxPellets    (default 3)     maximum number of pellets delivered
%


nZones = 4;
maxPellets = 3;
process_varargin(varargin);

staygo = RRGetStaygo(sd);
zones = RRGetZones(sd);
pellets = RRGetPellets(sd);
delays = RRGetDelays(sd);

nPlist = unique(pellets(~isnan(pellets)));
Zlist = unique(zones(~isnan(zones)));
nPlist = nPlist(:)';
Zlist = Zlist(:)';

marginalAmountByFlavour = nan(nZones,maxPellets);
for iZ = Zlist;
    idZ = zones==iZ;
    theta = RRheaviside(delays(idZ),staygo(idZ));
    marginalAmountByFlavour(iZ,:) = theta;
end

marginalFlavourByAmount = nan(nZones,maxPellets);
for nP = nPlist;
    idP = pellets==nP;
    theta = RRheaviside(delays(idP),staygo(idP));
    marginalFlavourByAmount(:,nP) = theta;
end
theta = RRheaviside(delays(:),staygo(:));
marginalAmountFlavour = repmat(theta,nZones,maxPellets);