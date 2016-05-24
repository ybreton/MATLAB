function [CPentryTimes,CPexitTimes,CPentered] = ProbRR_cp_entry(x,y,varargin)
%
%
%
%

radius = 70;
CP1 = [390.5 138];
CP2 = [226.5 138];
CP3 = [219.5 288];
CP4 = [390 292];

process_varargin(varargin);
CPs = [CP1;CP2;CP3;CP4];

InCP = get_crosspoint(x.D,y.D,CPs,radius);
timestamps = x.T;
CPentryTimes = [];
CPexitTimes = [];
CPentered = [];
LastZone = NaN;
LastSeen = NaN;
for r = 1 : length(InCP)
    % first, are LastZone and this zone both not-nan?
    nums = ~isnan(InCP(r));
    
    % keep track of the last time he was seen in the zone.
    if ~isnan(InCP(r))
        LastSeen = timestamps(r-1);
    end
    % if new zone ~= last zone, has entered new zone.
    if nums 
        if InCP(r)~=LastZone
            CPentryTimes = [CPentryTimes timestamps(r)];
            CPexitTimes = [CPexitTimes LastSeen];
            CPentered = [CPentered InCP(r)];
            LastZone = InCP(r);
        end
    end
end



function InCP = get_crosspoint(xD,yD,CPs,radius)
zoneList = 1:size(CPs,1);
InCP = nan;
d = nan(size(xD,1),size(CPs,1));
for zone = 1 : length(zoneList)
    dX = xD-CPs(zone,1);
    dY = yD-CPs(zone,2);
    d(:,zone) = sqrt(dX.^2+dY.^2);
end
d = d<=radius;

zoneMat = repmat([zoneList nan],size(d,1),1);
d = [d all(~d,2)];

if any(d)
    % InCP = zoneMat(d);
    % There's got to be a better way to do this.
    for r = 1 : size(zoneMat,1)
        InCP(r,1) = zoneMat(r,d(r,:));
    end
    
end