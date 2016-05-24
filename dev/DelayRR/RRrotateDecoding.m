function pxsRot = RRrotateDecoding(B,sd)
%
%
%
%

Quad = nan(4,1);
for iZ=1:4;
    Tf = sd.FeederTimes(sd.FeedersFired==iZ);
    Q = sd.quadrant.data(Tf);
    Quad(iZ) = nanmedian(Q);
end

T = B.pxs.range;
D = nan(size(B.pxs.data));
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
    
    p = B.pxs.restrict(Tin,Tout);
    t = p.range;
    d = p.data;
    
    Drot = nan(size(d));
    for iFr=1:size(d,1)
        D0 = rot90(squeeze(d(iFr,:,:)),-(Quad(iZ)-1));
        Drot(iFr,:,:) = reshape(D0,[1 B.nBin]);
    end
    if ~isempty(t)
        idT = T>=min(t)&T<=max(t);
        D(idT,:,:) = Drot;
    end
    
end

pxsRot = tsd(T,D);