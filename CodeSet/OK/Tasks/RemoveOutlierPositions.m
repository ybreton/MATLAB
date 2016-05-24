function sd = RemoveOutlierPositions(sd, varargin)

% sd = RemoveOutlierPositions(sd, varargin)
%   Removes any points that jump by more than maxtraveldist before and
%   after.  This helps when there are flickers that jump away.  Replaces
%   them with the mean of the points ahead and behind them.
%
% PARMS
%   maxTravelDist = 10;
%
% ADR 2012 Nov

maxTravelDist = 10;
process_varargin(varargin);

dz = sqrt(diff(sd.x.data).^2+diff(sd.y.data).^2);
problemDiffs = dz > maxTravelDist;
problemPoints = find(problemDiffs(1:(end-1)) & problemDiffs(2:end));

xR = sd.x.range;
xD = sd.x.data; yD = sd.y.data;

for iP = problemPoints'
	xD(iP+1) = mean([xD(iP), xD(iP+2)]);
	yD(iP+1) = mean([yD(iP), yD(iP+2)]);
end

sd.x = tsd(xR, xD);
sd.y = tsd(xR, yD);