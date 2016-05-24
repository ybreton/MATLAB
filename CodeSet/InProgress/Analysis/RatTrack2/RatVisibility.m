function RatVisibility

global RatTrackData

indices = 1:length(RatTrackData.LEDx);
nanRows = isnan(RatTrackData.LEDx)|isnan(RatTrackData.LEDy);
nanIndices = indices(nanRows);
if isempty(nanIndices)
    lastNaN = 0;
else
    lastNaN = max(nanIndices);
end
RatTrackData.RatVisible.time = [RatTrackData.timestamp(lastNaN+1) RatTrackData.timestamp(end)];
RatTrackData.RatVisible.frame = [RatTrackData.iFrame(lastNaN+1) RatTrackData.iFrame(end)];
