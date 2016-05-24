function RatVisibility

global RatTrackData

% % indices = 1:length(RatTrackData.LEDx);
% % nanRows = isnan(RatTrackData.LEDx)|isnan(RatTrackData.LEDy);
% % numRows = ~isnan(RatTrackData.LEDx)&~isnan(RatTrackData.LEDy);
% % the first number row is the first frame to take.
% % if any(numRows)
% %     firstRow = min(indices(numRows));
% %     lastRow = max(indices(numRows));
% % else
% %     firstRow = indices(1);
% %     lastRow = indices(end);
% % end

RatTrackData.RatVisible.time = [RatTrackData.timestamp(1) RatTrackData.timestamp(end)];
RatTrackData.RatVisible.frame = [RatTrackData.iFrame(1) RatTrackData.iFrame(end)];
