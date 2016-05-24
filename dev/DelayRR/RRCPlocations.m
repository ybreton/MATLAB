function sd = RRCPlocations(sd,varargin)
% 46cm radius from feeder
%
%
%
radiuscm = 46;
process_varargin(varargin);

cm2px = 1./(RRpx2cm(sd,1));
radiuspx = radiuscm*cm2px;

t = sd.x.range;
x = sd.x.data;
y = sd.y.data;

Zx = sd.World.FeederLocations.x(:)';
Zy = sd.World.FeederLocations.y(:)';

tin = [];
tout = [];
d = nan(length(t),length(Zx));
S = [1 0 0 0];
lastZone = nan;
nextZone = [2:length(Zx) 1];
for iT=1:length(t)
    t0 = t(iT);
    x0 = x(iT);
    y0 = y(iT);
    d  = sqrt((x0-Zx)^2+(y0-Zy)^2); %d is nZone x 2 distances
    if any(d<=radiuspx)
        zoneIn = d<=radiuspx;
        if length(zoneIn)>1
            zoneIn = lastZone;
        end
        if S(zoneIn)==1 % if zone is primed,
            S(zoneIn)=2;% activate it
            S(nextZone(zoneIn))=1; % prime the next one
            tin = [tin t0]; % set entry into choice point
            lastZone = zoneIn; % set the last zone to the current zone
        end
    end
    if all(d>radiuspx)
        if ~isnan(lastZone)
            if S(lastZone)==2 % if the last zone was active
                S(lastZone)=0; % de-activate it
                tout = [tout t0]; % set exit from choice point
            end
        end
    end
end
sd.CPin = tin;
sd.CPout = tout;