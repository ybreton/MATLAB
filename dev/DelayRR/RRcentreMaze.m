function [x,y] = RRcentreMaze(sd)
% Transforms x,y coordinates in RR to a coordinate system where the origin
% is maze centre, and .
%
%
%

zoneEntryXY = nan(length(unique(sd.ZoneIn)),2);
for iZ=1:length(unique(sd.ZoneIn));
    idZ = sd.ZoneIn==iZ;
    zoneEntryXY(iZ,1) = nanmean(sd.x.data(sd.EnteringZoneTime(idZ)));
    zoneEntryXY(iZ,2) = nanmean(sd.y.data(sd.EnteringZoneTime(idZ)));
end
CoM = [nanmedian(zoneEntryXY(:,1)) nanmedian(zoneEntryXY(:,2))];

xy = nan(2,length(sd.x.data));
xy(1,:) = sd.x.data - CoM(1);
xy(2,:) = sd.y.data - CoM(2);

x = tsd(sd.x.range,xy(1,:)');
y = tsd(sd.y.range,xy(2,:)');
