function fh = RRplotRegretDecodingXY(sd,TC,B)

sd.Thresholds = RRThresholds(sd);
sd = zIdPhi(sd);
[~,sd] = RRGetRegret(sd);
RegretLaps = find(sd.isRegret==1);

sd.VTE = log(sd.IdPhi)>5;
sd.SAll = cat(1,sd.S,sd.S_t);
sd.fnAll = cat(2,sd.fn,sd.fn_t);
sd.fcAll = cat(1,sd.fc,sd.fc_t);

nBins = 64;
xPos = linspace(TC.All.min(1),TC.All.max(1),TC.All.nBin(1));
yPos = linspace(TC.All.min(2),TC.All.max(2),TC.All.nBin(2));
[xMesh,yMesh] = meshgrid(xPos,yPos);
flavours = {'Cherry' 'Banana' 'Plain White' 'Chocolate'};

set(gcf,'position',[1921       57      1280    	948])
for iLap = RegretLaps(:)'
    B0.HC = B.HC.pxs.restrict(sd.EnteringCPTime(iLap),sd.EnteringCPTime(iLap)+3);
    B0.vStr = B.vStr.pxs.restrict(sd.EnteringCPTime(iLap),sd.EnteringCPTime(iLap)+3);
    B0.OFC = B.OFC.pxs.restrict(sd.EnteringCPTime(iLap),sd.EnteringCPTime(iLap)+3);
    D.HC = B0.HC.data;
    D.vStr = B0.vStr.data;
    D.OFC = B0.OFC.data;
    
    zone = sd.ZoneIn(iLap);
    delay = sd.ZoneDelay(iLap);
    pellets = sd.nPellets(iLap);
    threshold = sd.Thresholds(zone,pellets);
    
    clf
    imagesc(zeros(480,720,3))
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    set(gca,'xcolor','w')
    set(gca,'ycolor','w')
    th=text(720/2,480/2,sprintf('Regret, trial %d\n(Approaching %s)\n %ds delay, threshold of %.1fs',iLap,flavours{zone},delay,threshold));
    set(th,'color','w')
    set(th,'fontsize',16)
    set(th,'verticalalignment','middle')
    set(th,'horizontalalignment','center')
    pause;
    for iFr = 1 : size(D.HC,1)
        clf
        subplot(1,3,1)
        imagesc(xPos,yPos,squeeze(D.HC(iFr,:,:))')
        hold on
        contour(xMesh,yMesh,TC.HC.Occ', [0 0], 'w');
        plot(sd.x.data(sd.EnteringCPTime(iLap)+(iFr-1)*B.HC.pxs.dt),sd.y.data(sd.EnteringCPTime(iLap)+(iFr-1)*B.HC.pxs.dt),'wo')
        th3=text(min(TC.vStr.min(1)),mean([TC.vStr.min(2) TC.vStr.max(2)]),'HC');
        hold off
        axis xy
        title(sprintf('Ln[IdPhi] = %.2f',log(sd.IdPhi(iLap))))
        set(th3,'verticalalignment','middle')
        set(th3,'horizontalalignment','left')
        set(th3,'color','w')
        set(th3,'fontsize',10)
        set(gca,'xlim',[TC.HC.min(1),TC.HC.max(1)])
        set(gca,'ylim',[TC.HC.min(2),TC.HC.max(2)])
        
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        set(gca,'xcolor','w')
        set(gca,'ycolor','w')
        
        subplot(1,3,2)
        imagesc(xPos,yPos,squeeze(D.vStr(iFr,:,:))')
        hold on
        contour(xMesh,yMesh,TC.vStr.Occ', [0 0], 'w');
        plot(sd.x.data(sd.EnteringCPTime(iLap)+(iFr-1)*B.vStr.pxs.dt),sd.y.data(sd.EnteringCPTime(iLap)+(iFr-1)*B.vStr.pxs.dt),'wo')
        th=text(mean([TC.vStr.min(1) TC.HC.max(1)]),TC.vStr.max(2),sprintf('Trial %d\n(Approaching %s)', iLap,flavours{zone}));
        th2=text(mean([TC.vStr.min(1) TC.vStr.max(1)]),TC.vStr.min(2),sprintf('%ds delay\n(threshold %.1f)',delay,threshold));
        th3=text(min(TC.vStr.min(1)),mean([TC.vStr.min(2) TC.vStr.max(2)]),'vStr');
        hold off
        axis xy
        set(gca,'xlim',[TC.vStr.min(1),TC.vStr.max(1)])
        set(gca,'ylim',[TC.vStr.min(2),TC.vStr.max(2)])
        set(th,'color','w')
        set(th,'fontsize',10)
        set(th,'verticalalignment','top')
        set(th,'horizontalalignment','center')
        set(th2,'verticalalignment','bottom')
        set(th2,'horizontalalignment','center')
        set(th2,'color','w')
        set(th2,'fontsize',10)
        set(th3,'verticalalignment','middle')
        set(th3,'horizontalalignment','left')
        set(th3,'color','w')
        set(th3,'fontsize',10)
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        set(gca,'xcolor','w')
        set(gca,'ycolor','w')
        
        subplot(1,3,3)
        imagesc(xPos,yPos,squeeze(D.OFC(iFr,:,:))')
        hold on
        contour(xMesh,yMesh,TC.OFC.Occ', [0 0], 'w');
        plot(sd.x.data(sd.EnteringCPTime(iLap)+(iFr-1)*B.OFC.pxs.dt),sd.y.data(sd.EnteringCPTime(iLap)+(iFr-1)*B.OFC.pxs.dt),'wo')
        th3=text(min(TC.vStr.min(1)),mean([TC.vStr.min(2) TC.vStr.max(2)]),'OFC');
        hold off
        axis xy
        title(['t=' num2str(sd.EnteringCPTime(iLap)+(iFr-1)*B.HC.pxs.dt)])
        set(gca,'xlim',[TC.OFC.min(1),TC.OFC.max(1)])
        set(gca,'ylim',[TC.OFC.min(2),TC.OFC.max(2)])
        set(th3,'verticalalignment','middle')
        set(th3,'horizontalalignment','left')
        set(th3,'color','w')
        set(th3,'fontsize',10)
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        set(gca,'xcolor','w')
        set(gca,'ycolor','w')
        
        drawnow
        disp(['t=' num2str(sd.EnteringCPTime(iLap)+(iFr-1)*B.HC.pxs.dt) '...'])
        pause
    end
    
end
