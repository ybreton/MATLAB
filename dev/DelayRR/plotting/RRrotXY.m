function [xRot,yRot] = RRrotXY(sd)
%
%
%
%

zoneEntryXY = nan(length(unique(sd.ZoneIn)),2);
for iZ=1:length(unique(sd.ZoneIn));
    idZ = sd.ZoneIn==iZ;
    zoneEntryXY(iZ,1) = nanmean(sd.x.data(sd.EnteringZoneTime(idZ)));
    zoneEntryXY(iZ,2) = nanmean(sd.y.data(sd.EnteringZoneTime(idZ)));
end
mazeCenter = [nanmedian(zoneEntryXY(:,1)) nanmedian(zoneEntryXY(:,2))];

theta = [-pi/2;
         0;
         pi/2
         pi];

x = sd.x;
y = sd.y;

z = nan(length(x.data),1);
t = x.range;
for iTrl=1:length(sd.EnteringZoneTime)
    idT = t>=sd.EnteringZoneTime(iTrl) & t<sd.NextZoneTime(iTrl);
    z(idT) = sd.ZoneIn(iTrl);
end
z = tsd(t,z);

x = x.data(t)-mazeCenter(1);
y = y.data(t)-mazeCenter(2);
z = z.data(t);

x0 = nan(length(x),4);
y0 = nan(length(y),4);
for iQ=1:4
    R = [cos(-theta(iQ)) -sin(-theta(iQ));
         sin(-theta(iQ))  cos(-theta(iQ))];
    
    xy = [x y]*R';
    x0(:,iQ) = xy(:,1);
    y0(:,iQ) = xy(:,2);
end

xRot = nan(length(x0),1);
yRot = nan(length(y0),1);
for iPt=1:size(x0,1)
    if ~isnan(z(iPt))
        xRot(iPt) = x0(iPt,z(iPt));
        yRot(iPt) = y0(iPt,z(iPt));
    end
end

xRot = tsd(t,xRot);
yRot = tsd(t,yRot);