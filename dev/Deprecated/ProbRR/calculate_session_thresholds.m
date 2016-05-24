function sd = calculate_session_thresholds(sd,varargin)
%
%
%
%

timeBase = 1;
process_varargin(varargin);

zones = unique(sd.ZoneIn);

if numel(sd.nPellets)==1
    nPellets = repmat(sd.nPellets,length(zones),1);
else
    nPellets = sd.nPellets;
end
sd.nPellets = nPellets;

tSpent = sd.ExitZoneTime*timeBase- sd.EnteringZoneTime*timeBase;
b = nan(2,length(zones));
RsqCount = nan(1,length(zones));
sd.ZonePellets = nan(1,length(sd.ZoneIn));
sd.Stay = tSpent>sd.ZoneDelay;
for z = 1 : length(zones)
    idZone = zones(z) == sd.ZoneIn;
    D = sd.ZoneDelay(idZone);
    A = nPellets(z);
    sd.ZonePellets(idZone) = A;
    Stay = sd.Stay(idZone);
    
    b(:,z) = glmfit(D(:),Stay(:),'binomial');
    predP = glmval(b(:,z),D,'logit');
    predY = predP>0.5;
    Correct = sum(double(Stay(:)==predY(:)));
    Total = length(Stay);
    RsqCount(z) = Correct./Total;
end
sd.Threshold.b = b;
sd.Threshold.Rsq = RsqCount;

% e^(b1+b2*theta) = 1
% b1 + b2*theta = 0
% b2*theta = -b1
% theta = -b1/b2

theta = (-b(1,:))./(b(2,:));
sd.Threshold.Theta = theta;

ZoneThreshold = nan(1,length(sd.ZoneIn));
for z = 1 : length(zones)
    idZone = zones(z) == sd.ZoneIn;
    ZoneThreshold(idZone) = theta(z);
end
sd.ZoneThreshold = ZoneThreshold;
sd.Threshold.OverUnder = nan(1,length(sd.ZoneThreshold));
sd.Threshold.OverUnder(sd.ZoneDelay<sd.ZoneThreshold) = -1;
sd.Threshold.OverUnder(sd.ZoneDelay>sd.ZoneThreshold) = 1;
