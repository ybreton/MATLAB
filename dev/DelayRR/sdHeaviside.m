function sdOut = sdHeaviside(sdIn,varargin)
% Returns a standard session data object with field "threshold" containing
% threshold for the zone for the session.
% sd = sdHeavisideSigmoidHybrid(sd)
% where     sd      is a standard sessiond data structure
%
% OPTIONAL ARGUMENTS:
% ******************
% byField = 'ZoneIn'        Calculate threshold for each unique value of
%                               this
% xField = 'ZoneDelay'      Calculate for threshold xField value
% yField = 'stayGo'         Calculate threshold using yField value
%
%
%
byField = 'ZoneIn';
xField = 'ZoneDelay';
yField = 'stayGo';

for iS=1:length(sdIn)
    sd0 = sdIn(iS);
    sd0.threshold = nan(length(sd0.(byField)),1);
    uniqueZ = unique(sd0.(byField));
    idOK = isOK(sd0.(xField))&isOK(sd0.(yField));
    for iZ=1:length(uniqueZ)
        id = sd0.(byField)==uniqueZ(iZ);
        x = sd0.(xField)(id&idOK);
        y = sd0.(yField)(id&idOK);
        sd0.threshold(id) = heavisidefit(x,y);
    end
    sdOut(iS) = sd0;
end