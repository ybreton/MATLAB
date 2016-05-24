function sdOut = sdRRthreshold(sd)
% Returns a 1 x nTrials vector of threshold for each trial (sd.threshold), and 1 x nZones
% vector of threshold for each zone (sd.zoneThresh).

for iSubsess=1:length(sd)
    sd0 = sd(iSubsess);
    
    z = sd0.ZoneIn(:);
    d = sd0.ZoneDelay(:);
    sg= sd0.stayGo(:);
    uniqueZ = unique(z);
    sd0.threshold = nan(1,length(z));
    sd0.zoneThresh = nan(1,max(uniqueZ));
    for iZ=1:length(uniqueZ);
        idZ = z == uniqueZ(iZ);
        th = RRheaviside(d(idZ),sg(idZ));
        sd0.threshold(idZ) = th;
        sd0.zoneThresh(uniqueZ(iZ)) = th;
    end
    sdOut(iSubsess) = sd0;
end