function [D,firstLap,Dmat] = DelayOnDelayedSide(sd)
% 
%
%
%

ZoneIn = sd.ZoneIn;
ZoneDelay = sd.ZoneDelay;
DelayZone = sd.DelayZone;
zList = 3:4;
NonDelayZone = zList(zList~=DelayZone);

% Number of pellets to increase zone 3 after choosing 3
%   sd.World.incrLgoL
% Number of pellets to increase zone 3 after choosing 4
%   sd.World.incrLgoR
% Number of pellets to increase zone 4 after choosing 3
%   sd.World.incrRgoL
% Number of pellets to increase zone 4 after choosing 4
%   sd.World.incrRgoR

% WorldMat: choose row i, increase column j
WorldMat = zeros(4,4);
WorldMat(3,3) = sd.World.incrLgoL;
WorldMat(4,3) = sd.World.incrLgoR;
WorldMat(3,4) = sd.World.incrRgoL;
WorldMat(4,4) = sd.World.incrRgoR;

nLaps = length(ZoneIn);

Laps = 1 : nLaps;

firstLap = min(Laps(ZoneIn==DelayZone));

Dmat = nan(nLaps,4);
Dmat(firstLap,DelayZone) = ZoneDelay(firstLap);
Dmat(1:firstLap-1,NonDelayZone) = ZoneDelay(1:firstLap-1);

for lap = firstLap+1:nLaps
    lastChoice = ZoneIn(lap-1);
    increase = WorldMat(lastChoice,:);
    Dmat(lap,:) = max(Dmat(lap-1,:)+increase,1);
end
D = Dmat(:,DelayZone);