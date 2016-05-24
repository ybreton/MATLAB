function sd = RRrotateXYalign(sd)
%
%
%
%

if ~isfield(sd,'quadrant')
    sd=RRFindQuadrant(sd);
end

Quad = nan(4,1);
for iZ=1:4;
    Tf = sd.FeederTimes(sd.FeedersFired==iZ);
    Q = sd.quadrant.data(Tf);
    Quad(iZ) = nanmedian(Q);
end

T = sd.x.range;
xAligned = nan(size(sd.x.data));
yAligned = nan(size(sd.y.data));
for iTrl=0:length(sd.ZoneIn)
    if iTrl>0
        iZ = sd.ZoneIn(iTrl);
        Tin = sd.EnteringZoneTime(iTrl);
    else
        iZ = 1;
        Tin = sd.ExpKeys.TimeOnTrack;
    end
    
    if iTrl==length(sd.ZoneIn)
        Tout = sd.ExpKeys.TimeOffTrack;
    else
        Tout = sd.EnteringZoneTime(iTrl+1);
    end
    
    x = sd.x.restrict(Tin,Tout);
    y = sd.y.restrict(Tin,Tout);
    t = x.range;
    
    if ~isempty(t)
        idT = T>=min(t)&T<=max(t);
        xAligned(idT) = sd.xR{Quad(iZ)}.data(t);
        yAligned(idT) = sd.yR{Quad(iZ)}.data(t);
    end
end

sd.xAligned = tsd(T,xAligned);
sd.yAligned = tsd(T,yAligned);