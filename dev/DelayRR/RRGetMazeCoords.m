function sd = RRGetMazeCoords(sd,varargin)
%
%
%
%
flavors = {'Cherry' 'Banana' 'Plain' 'Chocolate'};
zones = unique(sd.ZoneIn);
process_varargin(varargin);

sd.World.Zones = nan(2,length(zones));
for iZ=1:length(zones)
    idx = sd.ZoneIn==zones(iZ);
    xZ = nanmedian(sd.x.data(sd.EnteringCPTime(idx)));
    yZ = nanmedian(sd.y.data(sd.EnteringCPTime(idx)));
    sd.World.Zones(:,iZ) = [xZ;yZ];
end

sd.World.Feeders = nan(2,length(zones));
for iZ=1:length(zones)
    idx = sd.FeedersFired==zones(iZ);
    xZ = nanmedian(sd.x.data(sd.FeederTimes(idx)));
    yZ = nanmedian(sd.y.data(sd.FeederTimes(idx)));
    sd.World.Feeders(:,iZ) = [xZ;yZ];
end

sd.World.flavors = flavors;