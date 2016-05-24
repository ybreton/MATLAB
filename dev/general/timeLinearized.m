function l = RRlinearize(sd)
% Linearize restaurant row for skips and stays separately. 
% 

% start with skips
ZoneIn = sd.ZoneIn(sd.stayGo==0);
In = sd.EnteringZoneTime(sd.stayGo==0);
Out = sd.NextZoneTime(sd.stayGo==0);

for zone=unique(ZoneIn(isOK(ZoneIn(:)))');
    idZ = ZoneIn==zone;
    t1 = In(idZ);
    t2 = Out(idZ);
    nT = (max(t2-t1)/sd.x.dt)+1;
    
    X = nan(length(t1),nT);
    Y = nan(length(t1),nT);
    T = nan(length(t1),nT);
    for iTrl=1:length(t1)
        x = sd.x.restrict(t1(iTrl),t2(iTrl));
        y = sd.y.restrict(t1(iTrl),t2(iTrl));
        X(iTrl,1:length(x.data)) = x.data;
        Y(iTrl,1:length(y.data)) = y.data;
        T(iTrl,1:length(x.range)) = x.range-t1;
    end
    xm = nanmedian(X,1);
    ym = nanmedian(Y,1);
    tm = nanmedian(T,1);
    t0 = 0:sd.x.dt:sd.x.dt*nT;
    Zx(zone,1:nT) = interp1q(tm,xm,t0);
    Zy(zone,1:nT) = interp1q(tm,ym,t0);
    
end