function [I,sd] = find_regret_instance(sd,varargin)
%
%
%
%

timeBase = 1e-6;
process_varargin(varargin);

zones = unique(sd.ZoneIn);

if numel(sd.nPellets)==1
    nPellets = repmat(sd.nPellets,length(zones),1);
else
    nPellets = sd.nPellets;
end

tSpent = sd.ExitZoneTime*timeBase- sd.EnteringZoneTime*timeBase;
b = nan(2,length(zones));
RsqCount = nan(1,length(zones));
for z = 1 : length(zones)
    idZone = zones(z) == sd.ZoneIn;
    D = sd.ZoneDelay(idZone);
    A = nPellets(z);
    Stay = tSpent(idZone)>=D;
    
    b(:,z) = glmfit(D(:),Stay(:),'binomial');
    predP = glmval(b(:,z),D,'logit');
    predY = predP>0.5;
    Correct = sum(double(Stay==predY));
    Total = length(Stay);
    RsqCount(z) = Correct./Total;
end
sd.Threshold.b = b;
sd.Threshold.Rsq = RsqCount;

% e^(b1+b2*theta) = 1
% b1 + b2*theta = 0
% b2*theta = -b1
% theta = -b1/b2

theta = (-b(1,:))/(b(2,:));
ZoneThreshold = nan(1,length(sd.ZoneIn));
for z = 1 : length(zones)
    idZone = zones(z) == sd.ZoneIn;
    ZoneThreshold(idZone) = theta(z);
end
sd.ZoneThreshold = ZoneThreshold;

