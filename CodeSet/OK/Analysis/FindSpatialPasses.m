function [passStart, passEnd] = FindSpatialPasses(sd, Lstart, Lend, Xrange, Yrange, varargin)

% [passStart, passEnd] = FindSpatialPasses(sd, Lstart, Lend, Xrange, Yrange, varargin)
%
% typical Lstart = [sd.x.starttime sd.ExitZoneTime];
% typical Lend = [sd.EnteringZoneTime sd.x.endtime];

Xd = sd.x.data;
Yd = sd.y.data;
T = sd.x.range;

% position restraints
keep = Xrange(1) < Xd & Xd < Xrange(2) & Yrange(1) < Yd & Yd < Yrange(2);

%---------------
assert(all(sd.x.range == sd.y.range), 'x/y mismatch');
assert(~isempty(Lend));

% match Lstarts to Lends
LstartToUse = nan(size(Lend));
% first
L0 = find(Lstart < Lend(1),1,'first');
if ~isempty(L0), LstartToUse(1) = L0; end
for iL = 2:length(Lend)
	L0 = find(Lstart > Lend(iL-1) & Lstart < Lend(iL), 1, 'first');
	if ~isempty(L0), LstartToUse(iL) = L0; end
end
Lstart = LstartToUse;

% GO
nLaps = length(Lstart);

passStart = nan(1,nLaps);
passEnd = nan(1,nLaps);

if ~isempty(keep);
	for iL = 1:nLaps;
		entering = find(keep & T>=Lstart(iL),1,'first');
		if ~isempty(entering)
			passStart(iL) = T(entering);
		end

		exiting = find(keep & T<=Lend(iL),1,'last');
		if ~isempty(exiting)
			passEnd(iL) = T(exiting);
		end
		
	end
end

end



