function landmarks = RRalignedLandmarks(sd,varargin)
%
%
%
%

[sd.x,sd.y] = RRcentreMaze(sd);
sd = RRFindQuadrant(sd);

quad = nan(4,1);
for iZ=1:4;
    T = sd.FeederTimes(sd.FeedersFired==iZ);
    Q = sd.quadrant.data(T);
    quad(iZ) = nanmedian(Q);
end

nTrl = length(sd.ZoneIn);
xRprev = nan(nTrl,1);
yRprev = nan(nTrl,1);
xRin = nan(nTrl,1);
yRin = nan(nTrl,1);
xRout = nan(nTrl,1);
yRout = nan(nTrl,1);
for iTrl=1:nTrl
    iZ = sd.ZoneIn(iTrl);
    Tin = sd.EnteringZoneTime(iTrl);
    
    xRin(iTrl) = sd.xR{quad(iZ)}.data(Tin);
    yRin(iTrl) = sd.yR{quad(iZ)}.data(Tin);
    
    if iTrl==nTrl
        Tout = sd.ExpKeys.TimeOffTrack;
    else
        Tout = sd.EnteringZoneTime(iTrl+1);
    end
    
    xRout(iTrl) = sd.xR{quad(iZ)}.data(Tout);
    yRout(iTrl) = sd.yR{quad(iZ)}.data(Tout);
    
    if iTrl>1
        Tprev = sd.EnteringZoneTime(iTrl-1);
        xRprev(iTrl) = sd.xR{quad(iZ)}.data(Tprev);
        yRprev(iTrl) = sd.yR{quad(iZ)}.data(Tprev);
    end
end

nRew = length(sd.FeederTimes);
xF = nan(length(sd.FeederTimes),1);
yF = nan(length(sd.FeederTimes),1);
for iRew=1:nRew;
    iZ = sd.FeedersFired(iRew);
    Tfeed = sd.FeederTimes(iRew);
    
    xF(iRew) = sd.xR{quad(iZ)}.data(Tfeed);
    yF(iRew) = sd.yR{quad(iZ)}.data(Tfeed);
end

landmarks.PrevZone.x = tsd(sd.EnteringZoneTime(:),xRprev);
landmarks.PrevZone.y = tsd(sd.EnteringZoneTime(:),yRprev);

landmarks.ZoneEntry.x = tsd(sd.EnteringZoneTime(:),xRin);
landmarks.ZoneEntry.y = tsd(sd.EnteringZoneTime(:),yRin);

landmarks.ZoneExit.x = tsd([sd.EnteringZoneTime(2:end)'; sd.ExpKeys.TimeOffTrack],xRout);
landmarks.ZoneExit.y = tsd([sd.EnteringZoneTime(2:end)'; sd.ExpKeys.TimeOffTrack],yRout);

landmarks.Feeder.x = tsd(sd.FeederTimes(:),xF);
landmarks.Feeder.y = tsd(sd.FeederTimes(:),yF);
