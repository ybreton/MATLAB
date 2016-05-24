function matching_ProbRR_4x20(varargin)
%
%
%
%

load('RR-2013-02-03-14_56_37.mat')

process_varargin(varargin);

nZones = 4;

% Rate of responding for arm I and tone J.
% entries / (time between entries)

% Rate of reinforcement for arm I and tone J.
% pellets / (time between pellets)

idEntries = ZoneIn>10;
ArmEntries = zeros(length(ZoneIn),1);
ArmProbabilities = zeros(length(ZoneIn),1);
ArmEntries(idEntries) = mod(ZoneIn(idEntries),10);
ArmProbabilities(idEntries) = ZoneProbability(idEntries);

Probs = unique(ArmProbabilities);
nTones = length(Probs);

% ArmEntries gives the arm that was entered, when it was entered.
% ArmProbabilities gives the probability that was entered, when it was
% entered.

ArmPellets = zeros(length(ZoneIn),1);
if numel(nPelletsPerDrop)==1
    nPelletsPerDrop = repmat(nPelletsPerDrop,nZones,1);
end
FeederWouldFire = false(length(ZoneIn),1);

c = 0;
for z = 1 : length(ZoneIn)
    if ZoneIn(z)>10
        zone = mod(ZoneIn(z),10);
        ArmPellets(z) = nPelletsPerDrop(zone);
    end
    if ZoneIn(z)<10
        c = c+1;
        fire = FireFeeder(c);
    end
    FeederWouldFire(z) = fire;
end
% ArmPellets gives the number of pellets dispensed.
% FeederWouldFire provides information about whether the feeder would fire
% if entered.
FeederWouldFire = logical(FeederWouldFire);
r = zeros(nZones,nTones);
Rf = zeros(nZones,nTones);
for arm = 1 : nZones
    idArm = ArmEntries == arm;
    % Arm was entered.
    for tone = 1 : nTones
        p = Probs(tone);
        idTone = ZoneProbability(:) == p;
        idArmTone = idArm & idTone;
        % Rate of responding for arm & tone
        entries = sum(double(idArmTone));
        timeBetweenEntries = diff(EnteringZoneTime(idArmTone));
        if entries>1
            r(arm,tone) = entries/mean(timeBetweenEntries);
        else
            r(arm,tone) = 0;
        end
        
        % Rate of reinforcement for arm & tone
        pellets = ArmPellets(idArmTone&FeederWouldFire);
        timeBetweenPellets = diff(EnteringZoneTime(idArmTone&FeederWouldFire));
        
        if pellets>0
            Rf(arm,tone) = pellets/mean(timeBetweenPellets);
        else
            Rf(arm,tone) = 0;
        end
    end
end