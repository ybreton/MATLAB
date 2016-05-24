function l = RRlinearize(sd,varargin)
% Linearize restaurant row for skips and stays separately. 
% l = RRlinearize(sd)
% where     l               is a structure with fields
%               .Stays
%               .Skips 
%                           each containing:
%                   .Zx     The x-values of the zone points
%                   .Zy     The y-values of the zone points
%                   .Zt     The normalized (zone:zone+1) time stamps that
%                           provide the linearization of the (x,y) values
%                   .x      The x position of the linearized location
%                   .y      The y position of the linearized location
%                   .L      The linearized location, based on looking up
%                           the Zt that corresponds to (x,y).
%
%           sd              is a standard session data structure.
%
% OPTIONAL ARGUMENTS:
% ******************
% nxbins            (default inf, no downsampling)
%   Number of x bins to downsample raw x positions before linearizing
% nybins            (default inf, no downsampling)
%   Number of y bins to downsample raw y positions before linearizing
% TrialTypes        (default {'Stay' 'Skip'})
%   Labels corresponding to each unique value for trial type, in numerical
%   order.
% TrialTypeField    (default 'stayGo')
%   Field in sg assigning each trial a type for separately calculating the
%   linearized path. Empty means all trials are identical.
%
% 

nxbins = inf;
nybins = inf;
smoothing = true;
TrialTypes = {'Skip' 'Stay'};
TrialTypeField = 'stayGo';
process_varargin(varargin);

% Prepare linearization-by-time
nT = ceil(max(sd.NextZoneTime-sd.ExitZoneTime)/sd.x.dt)+1;
tm = 0:1/nT:1-1/nT;

% Prepare x,y data so it's downsampled.
if isOK(nxbins)
    sd.x=downsampleDiscrete(sd.x,nxbins);
end
if isOK(nybins)
    sd.y=downsampleDiscrete(sd.y,nybins);
end
if smoothing
    sd = SmoothPath(sd);
end

% Empty TrialTypeField means all trials are identical
if ~isempty(TrialTypeField)
    sg = sd.(TrialTypeField)(:);
    uniqueSG = unique(sg(isOK(sg)));
else
    TrialTypes = {'AllTrials'};
    sg = ones(length(sd.EnteringZoneTime),1);
    uniqueSG = 1;
end

for iTrialType=1:length(uniqueSG)
    % start with skips
    ZoneIn = sd.ZoneIn(sg==uniqueSG(iTrialType));
    In = sd.EnteringZoneTime(sg==uniqueSG(iTrialType));
    Out = sd.NextZoneTime(sg==uniqueSG(iTrialType));
    uniqueZones = unique(ZoneIn(isOK(ZoneIn)));
    Zx = nan(nT,max(uniqueZones));
    Zy = Zx;
    Zt = Zx;
    for zone=uniqueZones(:)';
        idZ = ZoneIn==zone;
        t1 = In(idZ);
        t2 = Out(idZ);

        X = nan(length(t1),nT);
        Y = nan(length(t1),nT);
        for iTrl=1:length(t1)
            x = sd.x.restrict(t1(iTrl),t2(iTrl));
            y = sd.y.restrict(t1(iTrl),t2(iTrl));
            t = (x.range-t1(iTrl))./(t2(iTrl)-t1(iTrl));


            X(iTrl,:) = interp1(t, x.data, tm(:));
            Y(iTrl,:) = interp1(t, y.data, tm(:));
        end
        xm = nanmedian(X,1);
        ym = nanmedian(Y,1);
        
        d = [0 sqrt((xm(2:end)-(xm(1:end-1))).^2+(ym(2:end)-ym(1:end-1)).^2)];
        d(~isOK(d)) = 0;
        c = cumsum(d);
        [~,I] = unique(c);
        c0 = c(I);
        tm0 = tm(I);
        OK = isOK(c0) & isOK(tm0);
        c0 = c0(OK);
        tm0 = tm0(OK);

        C = interp1(c0,tm0,floor(min(c)):ceil(max(c)));
        L = (C-min(C))/max(C);
        x0 = interp1(tm,xm,L);
        y0 = interp1(tm,ym,L);

        Zx(1:length(x0),zone) = x0;
        Zy(1:length(y0),zone) = y0;
        Zt(1:length(L),zone) = L+zone;
    end
    OK = any(~isnan(Zx),2);
    S.Zx = Zx(OK,:);
    OK = any(~isnan(Zy),2);
    S.Zy = Zy(OK,:);
    OK = any(~isnan(Zt),2);
    S.Zt = Zt(OK,:);

    % Now we move x,y to the closest point Zx,Zy.
    x = sd.x.data;
    y = sd.y.data;
    t = sd.x.range;
    OK = isOK(x)&isOK(y)&isOK(t);
    x = x(OK);
    y = y(OK);
    t = t(OK);

    I = nan(length(x),1);
    Err = I;
    for iT=1:length(x)
        D = (x(iT)-S.Zx).^2+(y(iT)-S.Zy).^2;
        if any(~isnan(D(:)))
            [Err(iT),I(iT)] = min(D(:));
        end
    end
    OK = isOK(I);
    x0 = S.Zx(I(OK));
    y0 = S.Zy(I(OK));
    t0 = S.Zt(I(OK));
    Err0 = Err(I(OK));
    
    S.Err = tsd(t(OK),Err0);
    S.x = tsd(t(OK),x0);
    S.x = S.x.restrict(In,Out);
    S.y = tsd(t(OK),y0);
    S.y = S.y.restrict(In,Out);
    S.L = tsd(t(OK),t0);
    S.L = S.L.restrict(In,Out);
    
    l.(TrialTypes{iTrialType}) = S;
end
t = sd.x.range;
d = nan(length(t),length(TrialTypes));
for iF=1:length(TrialTypes)
    d(:,iF) = l.(TrialTypes{iF}).L.data(t);
end
d = nanmean(d,2);
l.All = tsd(t,d);
    