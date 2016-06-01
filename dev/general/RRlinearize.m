function l = RRlinearize(sd,varargin)
% Linearize restaurant row for skips and stays separately. 
% l = RRlinearize(sd)
% where     l               is a structure with fields
%               .Stays
%               .Skips 
%                           each containing:
%                   .Zx     The x-values of the zone points
%                   .Zy     The y-values of the zone points
%                   .Zt     The normalized (zone:zone+1) linearization of
%                           the (x,y) values
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
debug = false;
process_varargin(varargin);

% Prepare x,y data so it's downsampled.
if isOK(nxbins)
    sd.x=downsampleDiscrete(sd.x,nxbins);
end
if isOK(nybins)
    sd.y=downsampleDiscrete(sd.y,nybins);
end
% Smooth x and y
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

x = sd.x;
y = sd.y;
vx = dxdt(sd.x);
vy = dxdt(sd.y);

CoM = [sd.World.MazeCenter.x, sd.World.MazeCenter.y];
Entry = [sd.World.ZoneLocations.x(:), sd.World.ZoneLocations.y(:)];
Feeder = [sd.World.FeederLocations.x(:), sd.World.FeederLocations.y(:)];
nextX = sd.World.ZoneLocations.x([2:end, 1]);
nextY = sd.World.ZoneLocations.y([2:end, 1]);
Exit = [nextX(:), nextY(:)];

T = x.range;
x0 = x.data(T);
y0 = y.data(T);
vx0 = vx.data(T);
vy0 = vy.data(T);
phi1 = nan(length(vx0),size(Feeder,1));
phi2 = nan(length(vx0),size(Feeder,1));
OutZone = nan(length(x0),size(Feeder,1));
for iZ=1:size(Feeder,1)
    TF = Feeder(iZ,:) - Entry(iZ,:);
    TX = Exit(iZ,:) - Feeder(iZ,:);
    phi1(:,iZ) = abs(wrapToPi(atan2(vy0,vx0) - atan2(TF(2),TF(1))))/pi;
    phi2(:,iZ) = abs(wrapToPi(atan2(vy0,vx0) - atan2(TX(2),TX(1))))/pi;
    
    PhiEntry = atan2(Entry(iZ,2)-CoM(2), Entry(iZ,1)-CoM(1));
    PhiXY = atan2(y0-CoM(2), x0-CoM(1));
    PhiExit = atan2(Exit(iZ,2)-CoM(2), Exit(iZ,1)-CoM(1));
    
    PhiExitEntry = wrapToPi(PhiExit-PhiEntry);
    PhiXYEntry = wrapToPi(PhiXY-PhiEntry);
    OutZone(:,iZ) = PhiXYEntry>PhiExitEntry | PhiXYEntry<0;
end

L = nan(length(T),1);
Err = nan(length(T),1);
IT = find(~isnan(x0)&~isnan(y0)&~isnan(vx0)&~isnan(vy0));
for iD=IT(:)'
    D = nan(size(Feeder,1),2);
    P = nan(size(Feeder,1),2);
    for iZ=1:size(Feeder,1)
        TF = Feeder(iZ,:) - Entry(iZ,:);
        N1 = TF/norm(TF);

        TX = Exit(iZ,:) - Feeder(iZ,:);
        N2 = TX/norm(TX);

        xy1 = [x0(iD) y0(iD)] - Entry(iZ,:);
        xy2 = [x0(iD) y0(iD)] - Feeder(iZ,:);

        p1 = xy1*N1';
        p2 = xy2*N2';

        r1 = xy1 - p1.*N1;
        r2 = xy2 - p2.*N2;
        % Angle between velocity and TF/TX will modulate the error.
        
        d1 = norm(r1)*phi1(iD);
        d2 = norm(r2)*phi2(iD);

        % Make distances infinite if angle of xy is not between entry angle
        % and exit angle with respect to CoM.
        if OutZone(iD,iZ)
            d1 = inf;
            d2 = inf;
        end

        A = (p1/norm(TF))*0.5+iZ;
        B = (p2/norm(TX))*0.5+0.5+iZ;

        if debug
            clf
            hold on
            plot(x0(iD),y0(iD),'ko','markerfacecolor','k')
            plot(Entry(iZ,1),Entry(iZ,2),'go','markerfacecolor','g')
            plot(Feeder(iZ,1),Feeder(iZ,2),'bx','markerfacecolor','b')
            plot(Exit(iZ,1),Exit(iZ,2),'rs','markerfacecolor','r')
            quiver(Entry(iZ,1),Entry(iZ,2),TF(1), TF(2), 'color', 'g')
            quiver(Feeder(iZ,1),Feeder(iZ,2), TX(1), TX(2), 'color', 'r')
            quiver(x0(iD),y0(iD),r1(1),r1(2), 'color', 'k', 'linestyle', '--')
            quiver(x0(iD),y0(iD),r2(1),r2(2), 'color', 'k', 'linestyle', '--')
            xlim([0 720])
            ylim([0 480])
            set(gca,'xtick',[])
            set(gca,'ytick',[])
            set(gca,'xcolor','w')
            set(gca,'ycolor','w')
            hold off
            drawnow
        end

        D(iZ,1) = d1;
        D(iZ,2) = d2;
        P(iZ,1) = A;
        P(iZ,2) = B;
    end
    D0 = D(:);
    P0 = P(:);
    [Err(iD),I] = min(D0);
    L(iD) = P0(I);
end
l.All = tsd(T,L);
l.Err = tsd(T,Err);
for iTrialType=1:length(uniqueSG)
    In = sd.EnteringZoneTime(sg==uniqueSG(iTrialType));
    Out = sd.NextZoneTime(sg==uniqueSG(iTrialType));
    
    S.Err = l.Err.restrict(In,Out);
    S.L = l.All.restrict(In,Out);
    
    l.(TrialTypes{iTrialType}) = S;
end

% for iTrialType=1:length(uniqueSG)
%     % start with skips
%     ZoneIn = sd.ZoneIn(sg==uniqueSG(iTrialType));
%     In = sd.EnteringZoneTime(sg==uniqueSG(iTrialType));
%     Out = sd.NextZoneTime(sg==uniqueSG(iTrialType));
%     uniqueZones = unique(ZoneIn(isOK(ZoneIn)));
%     Zx = nan(nT,max(uniqueZones));
%     Zy = Zx;
%     Zt = Zx;
%     for zone=uniqueZones(:)';
%         idZ = ZoneIn==zone;
%         t1 = In(idZ);
%         t2 = Out(idZ);
% 
%         X = nan(length(t1),nT);
%         Y = nan(length(t1),nT);
%         for iTrl=1:length(t1)
%             x = sd.x.restrict(t1(iTrl),t2(iTrl));
%             y = sd.y.restrict(t1(iTrl),t2(iTrl));
%             t = (x.range-t1(iTrl))./(t2(iTrl)-t1(iTrl));
% 
% 
%             X(iTrl,:) = interp1(t, x.data, tm(:));
%             Y(iTrl,:) = interp1(t, y.data, tm(:));
%         end
%         xm = nanmedian(X,1);
%         ym = nanmedian(Y,1);
%         
%         d = [0 sqrt((xm(2:end)-(xm(1:end-1))).^2+(ym(2:end)-ym(1:end-1)).^2)];
%         d(~isOK(d)) = 0;
%         c = cumsum(d);
%         [~,I] = unique(c);
%         c0 = c(I);
%         tm0 = tm(I);
%         OK = isOK(c0) & isOK(tm0);
%         c0 = c0(OK);
%         tm0 = tm0(OK);
% 
%         C = interp1(c0,tm0,floor(min(c)):ceil(max(c)));
%         L = (C-min(C))/max(C);
%         x0 = interp1(tm,xm,L);
%         y0 = interp1(tm,ym,L);
% 
%         Zx(1:length(x0),zone) = x0;
%         Zy(1:length(y0),zone) = y0;
%         Zt(1:length(L),zone) = L+zone;
%     end
%     OK = any(~isnan(Zx),2);
%     S.Zx = Zx(OK,:);
%     OK = any(~isnan(Zy),2);
%     S.Zy = Zy(OK,:);
%     OK = any(~isnan(Zt),2);
%     S.Zt = Zt(OK,:);
% 
%     % Now we move x,y to the closest point Zx,Zy.
%     x = sd.x.data;
%     y = sd.y.data;
%     t = sd.x.range;
%     OK = isOK(x)&isOK(y)&isOK(t);
%     x = x(OK);
%     y = y(OK);
%     t = t(OK);
% 
%     I = nan(length(x),1);
%     Err = I;
%     for iT=1:length(x)
%         D = (x(iT)-S.Zx).^2+(y(iT)-S.Zy).^2;
%         if any(~isnan(D(:)))
%             [Err(iT),I(iT)] = min(D(:));
%         end
%     end
%     OK = isOK(I);
%     x0 = S.Zx(I(OK));
%     y0 = S.Zy(I(OK));
%     t0 = S.Zt(I(OK));
%     Err0 = Err(I(OK));
%     
%     S.Err = tsd(t(OK),Err0);
%     S.x = tsd(t(OK),x0);
%     S.x = S.x.restrict(In,Out);
%     S.y = tsd(t(OK),y0);
%     S.y = S.y.restrict(In,Out);
%     S.L = tsd(t(OK),t0);
%     S.L = S.L.restrict(In,Out);
%     
%     l.(TrialTypes{iTrialType}) = S;
% end
% t = sd.x.range;
% d = nan(length(t),length(TrialTypes));
% for iF=1:length(TrialTypes)
%     d(:,iF) = l.(TrialTypes{iF}).L.data(t);
% end
% d = nanmean(d,2);
% l.All = tsd(t,d);
    