function VTETable = getVTE_FPTAging(MasterSSNTable)
thresh = 2;
[uniqueSSN,id] = unique(MasterSSNTable.DATA(:,5));
MasterSSNTable.DATA = MasterSSNTable.DATA(id,:);

DATA = cell(0,13);
fh=figure;
% fh2=figure;
for r = 1 : length(uniqueSSN)
    pushdir(MasterSSNTable.DATA{r,5});
    disp(MasterSSNTable.DATA{r,4});
    fn=FindFile('R*-DD.mat');
    sd = FPTInit(fn,'Spikes',false);
    x = sd.x;
    y = sd.y;
    StartT = min(x.range);
    FinishT = max(x.range);
    FR = 1/30; % 30 fps.
    T = (StartT:FR:FinishT)';
    x0 = interp1(x.range,x.data,T);
    y0 = interp1(y.range,y.data,T);
%     idnan = isnan(x0)|isnan(y0);
%     x0(idnan) = interp1(T(~idnan),x0(~idnan),T(idnan));
%     y0(idnan) = interp1(T(~idnan),y0(~idnan),T(idnan));
    sd.x = tsd(T,x0);
    sd.y = tsd(T,y0);
    
    set(0,'currentfigure',fh)
    clf
    hold on
    plot(sd.x.data,sd.y.data);
    x = sd.x.data;
    y = sd.y.data;
    t = sd.x.range;
    idnan = isnan(t);
    x(idnan) = [];
    y(idnan) = [];
    t(idnan) = [];
    idnan = isnan(x)|isnan(y);
    x(idnan) = interp1(t(~idnan),x(~idnan),t(idnan));
    y(idnan) = interp1(t(~idnan),y(~idnan),t(idnan));
    x = tsd(t,x);
    y = tsd(t,y);
    xEntry = nan(length(sd.EnteringCPTime),1);
    yEntry = nan(length(sd.EnteringCPTime),1);
    for l = 1 : length(sd.EnteringCPTime)
        x0 = x.restrict(sd.EnteringCPTime(l)-x.dt,sd.EnteringCPTime(l)+x.dt);
        y0 = y.restrict(sd.EnteringCPTime(l)-y.dt,sd.EnteringCPTime(l)+y.dt);
        xEntry(l) = nanmean(x0.data);
        yEntry(l) = nanmean(y0.data);
    end
    CP(1) = nanmean(xEntry);
    if CP(1)>720/2
        CP(1) = CP(1)+sd.InZoneDistance(2);
    else
        CP(1) = CP(1)-sd.InZoneDistance(2);
    end
    CP(2) = nanmean(yEntry);
    plot(CP(1),CP(2),'rx');
    circle(CP,sd.InZoneDistance(2),100,'r-');
    hold off
    drawnow;
    
    id = sd.FeederTimes<min(sd.EnteringCPTime);
    FeederTimes = sd.FeederTimes(~id);
    EnteringCPTime = sd.EnteringCPTime;
    
    nL = min(length(EnteringCPTime),length(sd.ZoneIn));
    sd.TotalLaps = nL;
    
    tstart = EnteringCPTime(1:nL)-mean([sd.x.dt sd.y.dt]);
    tstart = tstart(:);
    tend = ones(length(tstart),1)*max(sd.x.range);
    for t = 1 : length(tstart)
        rids = 1:length(FeederTimes);
        id = FeederTimes>tstart(t);
        minRid = min(rids(id));
        if ~isempty(minRid)
            tend(t) = FeederTimes(minRid);
        else
            tend(t) = max(sd.x.range);
        end
    end
    
    upperY = CP(2)+sd.InZoneDistance(2);
    lowerY = CP(2)-sd.InZoneDistance(2);
    leftX = CP(1)-sd.InZoneDistance(2);
    rightX = CP(1)+sd.InZoneDistance(2);
    for l = 1 : length(tstart)
        y0 = sd.y.restrict(tstart(l),tend(l));
        x0 = sd.x.restrict(tstart(l),tend(l));
        yT = y0.range;
        yD = y0.data;
        xD = x0.data;
        rids = 1:length(yT);

        idnan = isnan(yD)|isnan(xD);
        n = length(unique(round(xD(~idnan))));
        if n>10
            xD(idnan) = interp1(yT(~idnan),xD(~idnan),yT(idnan));
            yD(idnan) = interp1(yT(~idnan),yD(~idnan),yT(idnan));
%             rInZone = sqrt((xD-CP(1)).^2+(yD-CP(2)).^2)<=sd.InZoneDistance(2);
            yInZone = yD>=lowerY&yD<=upperY;
            
            if any(yInZone)
                rOutZone = rids(~(yInZone));
                rOutZone(rOutZone<min(rids(yInZone))) = [];
            else
                tstart(l) = nan;
                tend(l) = nan;
            end
        else
            rOutZone = [];
            tstart(l) = nan;
            tend(l) = nan;
        end

%         yInZone = yD<=upperY&yD>=lowerY;
%         xInZone = xD<=rightX&xD>=leftX;
        if ~isempty(rOutZone)&~isnan(tend(l))&~isnan(tstart(l))
            lastTime = min(rOutZone); % first time y leaves zone.
            tend(l) = yT(lastTime);
        elseif isempty(rOutZone)&~isnan(tend(l))&~isnan(tstart(l))
            lastTime = max(rids(yInZone));
            tend(l) = yT(lastTime);
        end
%         idin = rids(:)<=lastTime;
        
%         n = length(xD(~idnan&idin));
%         if n<=5
%             tstart(l) = nan;
%             tend(l) = nan;
%         end
    end
    idnan = isnan(tend)|isnan(tstart);
    timeInCP(1) = min(tend(~idnan)-tstart(~idnan));
    timeInCP(2) = max(tend(~idnan)-tstart(~idnan));
    
    sd = zIdPhi(sd,'tstart',tstart,'tend',tend);
    CPtime = tend - tstart;
    
    logIdPhi = log10(sd.IdPhi);
    if any(logIdPhi<=1)
        disp('DEBUG.')
    end
    z = sd.zIdPhi;
    lap = 1:length(logIdPhi);
    idLo = lap(logIdPhi<=thresh);
    idHi = lap(logIdPhi>thresh);
    idMax = lap(logIdPhi>thresh&logIdPhi==max(logIdPhi));
    idDBG = lap(logIdPhi<=1);
    idLoEx = min(lap(logIdPhi<=thresh & logIdPhi>1));
    
    set(0,'currentfigure',fh)
    clf
    title(sprintf('%s, %.1f to %.1f seconds of CP pass',MasterSSNTable.DATA{r,4},timeInCP(1),timeInCP(2)));
    hold on
    ph = [];
    for l = 1 : length(tstart)
        x0 = sd.x.restrict(tstart(l),tend(l));
        y0 = sd.y.restrict(tstart(l),tend(l));
        if ~isempty(x0.data) && ~isempty(y0.data)
            ph(1)=plot(-y0.data,-x0.data,'-','color',[0.8 0.8 0.8],'linewidth',0.5);
        end
    end
    for l = 1 : length(idLoEx)
        x0 = sd.x.restrict(tstart(idLoEx(l)),tend(idLoEx(l)));
        y0 = sd.y.restrict(tstart(idLoEx(l)),tend(idLoEx(l)));
        ph(2)=plot(-y0.data,-x0.data,'r-','linewidth',2);
    end
%     for l = 1 : length(idHi)
%         x0 = sd.x.restrict(tstart(idHi(l)),tend(idHi(l)));
%         y0 = sd.y.restrict(tstart(idHi(l)),tend(idHi(l)));
%         plot(x0.data,y0.data,'c-','linewidth',1)
%     end
    if ~isempty(idMax)
        x0 = sd.x.restrict(tstart(idMax),tend(idMax));
        y0 = sd.y.restrict(tstart(idMax),tend(idMax));
        ph(3)=plot(-y0.data,-x0.data,'b-','linewidth',2);
        lh = legend(ph,{sprintf('All passes') sprintf('Log_{10}[Id\\phi] = %.2f',logIdPhi(idLoEx)) sprintf('Log_{10}[Id\\phi] = %.2f',logIdPhi(idMax))});
    else
        lh = legend(ph,{sprintf('All laps') sprintf('Log_{10}[Id\\phi] = %.2f',logIdPhi(idLoEx))});
    end
    set(lh,'location','north')
    axis image
    set(gca,'xlim',[(-upperY)-10 (-lowerY)+10])
    set(gca,'ylim',[(-rightX)-10 (-leftX)+10])
    set(gca,'xtick', [])
    set(gca,'ytick', [])
    set(gca,'xcolor',[1 1 1])
    set(gca,'ycolor',[1 1 1])
    hold off
    
    if length(logIdPhi)>sd.TotalLaps
        logIdPhi = logIdPhi(1:sd.TotalLaps);
        z = z(1:sd.TotalLaps);
    end
    
    d = DelayOnDelayedSide(sd);
    c = sd.ZoneIn == sd.DelayZone;
    d = d(1:nL);
    c = c(1:nL);
    lap = lap(1:length(logIdPhi));
    sd.ZoneDelay = sd.ZoneDelay(1:sd.TotalLaps);
    sd.ZoneIn = sd.ZoneIn(1:sd.TotalLaps);
    
    TA = DD_getLapType(sd,'nL',sd.TotalLaps);
    [Inv0,Inv,Tit,Expl] = FPT_getPhases(sd,'nL',nL);
    % Assemble.
    newCols = mat2can(cat(2,lap(:),d(:),c(:),logIdPhi(:),z(:),CPtime(:),TA(:)));
    repRows = repmat(MasterSSNTable.DATA(r,:),size(newCols,1),1);
    newBlock = cat(2,repRows,newCols);
    DATA = cat(1,DATA,newBlock);
    
%     subplot(1,2,1)
%     [f,bin] = hist(log10(sd.IdPhi),linspace(0,5,41));
%     title(sprintf('%s',sd.ExpKeys.SSN))
%     hold on
%     plot(bin,f/sum(f),'b-')
%     hold off
    drawnow
    fn = [MasterSSNTable.DATA{r,4} '-CP_passes'];
    saveas(fh,[fn '.fig'],'fig')
    saveas(fh,[fn '.eps'],'epsc')
    
%     set(0,'currentfigure',fh2)
%     clf
%     subplot(3,2,1)
%     hold on
%     [f,bin]=hist(can2mat(DATA(:,10)),linspace(0,3));
%     plot(bin,f/sum(f),'k-','linewidth',2);
%     xlabel(sprintf('Log_{10}[I d\\phi]'));
%     ylabel(sprintf('Proportion of laps'));
%     idnan = isnan(can2mat(DATA(:,10)));
%     try
%         mixfit = gmdistribution.fit(can2mat(DATA(~idnan,10)),2);
%         plot(linspace(0,3),pdf(mixfit,linspace(0,3)')./sum(pdf(mixfit,linspace(0,3)')),'r-')
%         MU = squeeze(mixfit.mu);
%         SIGMA = squeeze(mixfit.Sigma);
%         TAU = squeeze(mixfit.PComponents);
%         Y = max(pdf(mixfit,linspace(0,3)')./sum(pdf(mixfit,linspace(0,3)')));
%         plot(MU(:),ones(length(MU),1)*Y,'bx','markersize',12)
%         for k = 1 : length(MU)
%             plot([MU(k)-SIGMA(k) MU(k)+SIGMA(k)],[Y Y],'b-','linewidth',2);
%             text(MU(k),0,sprintf('%.0f%%',TAU(k)*100),'horizontalalignment','center','verticalalignment','bottom');
%         end
%     end
%     hold off
%     subplot(3,2,2)
%     hold on
%     [f,bin]=ecdf(can2mat(DATA(:,10)),'function','survivor');
%     stairs(bin,f,'k-','linewidth',2);
%     xlabel(sprintf('Log_{10}[I d\\phi]'));
%     ylabel(sprintf('Surviving fraction'));
%     hold off
%     
%     subplot(3,2,3)
%     hold on
%     [f,bin]=hist(can2mat(DATA(:,11)),linspace(-5,15));
%     plot(bin,f/sum(f),'k-','linewidth',2);
%     xlabel(sprintf('Z[I d\\phi]'));
%     ylabel(sprintf('Proportion of laps'));
%     idnan = isnan(can2mat(DATA(:,11)));
%     try
%         mixfit = gmdistribution.fit(can2mat(DATA(~idnan,11)),2);
%         plot(linspace(-5,15),pdf(mixfit,linspace(-5,15)')./sum(pdf(mixfit,linspace(-5,15)')),'r-')
%         MU = squeeze(mixfit.mu);
%         SIGMA = squeeze(mixfit.Sigma);
%         TAU = squeeze(mixfit.PComponents);
%         Y = max(pdf(mixfit,linspace(-5,15)')./sum(pdf(mixfit,linspace(-5,15)')));
%         plot(MU(:),ones(length(MU),1)*Y,'bx','markersize',12)
%         for k = 1 : length(MU)
%             plot([MU(k)-SIGMA(k) MU(k)+SIGMA(k)],[Y Y],'b-','linewidth',2);
%             text(MU(k),0,sprintf('%.0f%%',TAU(k)*100),'horizontalalignment','center','verticalalignment','bottom');
%         end
%     end
%     hold off
%     subplot(3,2,4)
%     hold on
%     [f,bin]=ecdf(can2mat(DATA(:,11)),'function','survivor');
%     stairs(bin,f,'k-','linewidth',2);
%     xlabel(sprintf('Z[I d\\phi]'));
%     ylabel(sprintf('Surviving fraction'));
%     hold off
%     
%     subplot(3,2,5)
%     hold on
%     idOK = ~isnan(logIdPhi)&~isinf(logIdPhi);
%     [f,bin]=hist(logIdPhi(idOK),linspace(1,3));
%     plot(bin,f/sum(f),'k-','linewidth',2);
%     xlabel(sprintf('Session Log_{10}[I d\\phi]'));
%     ylabel(sprintf('Proportion of laps'));
%     try
%         mixfit = gmdistribution.fit(logIdPhi(idOK),2);
%         plot(linspace(1,3),pdf(mixfit,linspace(1,3)')./sum(pdf(mixfit,linspace(1,3)')),'r-')
%         MU = squeeze(mixfit.mu);
%         SIGMA = squeeze(mixfit.Sigma);
%         TAU = squeeze(mixfit.PComponents);
%         Y = max(pdf(mixfit,linspace(1,3)')./sum(pdf(mixfit,linspace(1,3)')));
%         plot(MU(:),ones(length(MU),1)*Y,'bx','markersize',12)
%         for k = 1 : length(MU)
%             plot([MU(k)-SIGMA(k) MU(k)+SIGMA(k)],[Y Y],'b-','linewidth',2);
%         end
%     end
%     hold off
%     subplot(3,2,6)
%     hold on
%     [f,bin]=ecdf(logIdPhi(idOK),'function','survivor');
%     stairs(bin,f,'k-','linewidth',2);
%     xlabel(sprintf('Session Log_{10}[I d\\phi]'));
%     ylabel(sprintf('Surviving fraction'));
%     hold off
%     
%     drawnow
    popdir;
end
uniqueRats = unique(can2mat(DATA(:,1)));
newCol = nan(size(DATA,1),1);
clf
cmap = hsv(3);
clear ph
for r = 1 : length(uniqueRats)
    id = can2mat(DATA(:,1)) == uniqueRats(r);
    logIdPhi = can2mat(DATA(id,10));
    NormLogIdPhi = (logIdPhi-nanmean(logIdPhi))./nanstd(logIdPhi);
    newCol(id) = NormLogIdPhi;
    [f,bin] = hist(NormLogIdPhi,linspace(0,10,41));
end
DATA = cat(2,DATA,mat2can(newCol));
VTETable.HEADER = cat(2,MasterSSNTable.HEADER,{'Lap' 'Delay' 'Choice' 'LogIdPhi' 'zIdPhi' 'Time in CP' 'Titration/Alternation' 'Z-LogIdPhi'});
VTETable.DATA = DATA;