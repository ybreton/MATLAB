maxSessions = 28;
maxZones = 4;
maxLaps = 200;
%%
Hveh = nan(30,30,length(AllRats));
Hcno = nan(30,30,length(AllRats));
VEHzd = nan(maxSessions,maxLaps*maxZones,length(AllRats));
CNOzd = nan(maxSessions,maxLaps*maxZones,length(AllRats));
VEHtiz = nan(maxSessions,maxLaps*maxZones,length(AllRats));
CNOtiz = nan(maxSessions,maxLaps*maxZones,length(AllRats));
m = nan(length(AllRats),2);
sem = nan(length(AllRats),2);
pStat = nan(length(AllRats),1);
for iRat=1:length(AllRats)
    VEH = AllRats(iRat).VEH;
    CNO = AllRats(iRat).CNO;
    [zd,tiz] = wrap_RR_summarizeStayDurations(VEH);
    VEHzd(1:length(VEH),:,iRat) = zd;
    VEHtiz(1:length(VEH),:,iRat) = tiz;
    vehDat = nanmedian(tiz(tiz<zd),2);
    m(iRat,1) = nanmean(vehDat);
    sem(iRat,1) = nanstderr(vehDat);
    
    [zd,tiz] = wrap_RR_summarizeStayDurations(CNO);
    CNOzd(1:length(CNO),:,iRat) = zd;
    CNOtiz(1:length(CNO),:,iRat) = tiz;
    cnoDat = nanmedian(tiz(tiz<zd),2);
    m(iRat,2) = nanmean(nanmedian(tiz(tiz<zd),2));
    sem(iRat,2) = nanstderr(nanmedian(tiz(tiz<zd),2));
    
    pStat(iRat) = kruskalwallis([vehDat;cnoDat],[zeros(length(vehDat),1);ones(length(cnoDat),1)],'off');
end
%%
figure;
[bh,eh,ch]=barerrorbar(1:length(ratlist),m,sem);
set(eh,'linewidth',1)
set(gca,'ylim',[2 7])
ystar = mean([max(get(gca,'ylim')) max(m(:))]);
hold on
for iRat=1:length(pStat)
    if pStat(iRat)<0.05
        plot(iRat,max(get(gca,'ylim')),'k*','markersize',12)
    end
end
hold off
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
set(gca,'box','off')
ylabel(sprintf('Median hesitation time\n(Mean across sessions \\pm SEM)'))
set(gca,'xtick',1:length(ratlist))
set(gca,'xticklabel',ratlist)
saveas(gcf,'AllRats-MedianTimeInZone.fig','fig')
saveas(gcf,'AllRats-MedianTimeInZone.eps','epsc')
%%
medianDiff = nan(length(AllRats),1);
pStat = nan(length(AllRats),1);
for iRat=1:length(AllRats)
    figure
    VzdRat = VEHzd(:,:,iRat); 
    VtizRat = VEHtiz(:,:,iRat);
    V0=VtizRat(:); V0(VtizRat(:)>=VzdRat(:)) = nan;
    CzdRat = CNOzd(:,:,iRat);
    CtizRat = CNOtiz(:,:,iRat);
    C0 = CtizRat(:); C0(CtizRat(:)>=CzdRat(:)) = nan;
    HV = hist(V0, 1:30); HV = HV/sum(HV);
    HC = hist(C0, 1:30); HC = HC/sum(HC);
    
    ph=plot(1:30, cumsum(HV), 'b', 1:30, cumsum(HC), 'r', 'LineWidth', 2); legend('Vehicle','CNO');
%     [p,table] = kruskalwallis([V0;C0],[zeros(length(V0),1);ones(length(C0),1)],'off');
    [h,pStat(iRat),kstat]=kstest2(V0(:),C0(:));
    N=sum(double(~isnan([V0(:);C0(:)])));
    sigStr = sprintf('K_{stat}(N=%d)=%.2f, p=%.3f',N,kstat,pStat(iRat));
    th=text(30,0,sigStr);set(th,'VerticalAlignment','bottom','HorizontalAlignment','right');
    set(th,'fontsize',16)
    set(th,'fontname','Arial')
    set(gca,'ylim',[0 1])
    set(gca,'xlim',[1 30])
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    set(gca,'box','off')
    xlabel('Time in zone before skipping (secs)')
    ylabel('Cumulative proportion of trials')
    saveas(gcf,[ratlist{iRat} '-CumulativeProportion_TimeInZone_at_Drug.fig'],'fig')
    saveas(gcf,[ratlist{iRat} '-CumulativeProportion_TimeInZone_at_Drug.eps'],'epsc')
    medianDiff(iRat) = nanmedian(C0)-nanmedian(V0);
end
figure;
boxplot(medianDiff)
removeBoxplotXtick(gcf);
set(gca,'xcolor','w')
set(gca,'xtick',[])
hold on
plot(ones(length(medianDiff),1),medianDiff,'ko','markerfacecolor','k','markersize',8)
hold off
[h,p]=ttest(medianDiff);
if h
    plot(1,mean([max(get(gca,'ylim')); max(medianDiff)]),'k*','markersize',12);
end
set(gca,'ylim',[-1 1])
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
set(gca,'box','off')
ylabel(sprintf('\\Delta median stay duration before skip\n(CNO - Vehicle)'));
saveas(gcf,'AllRats-DeltaMedianTimeInZone.fig','fig')
saveas(gcf,'AllRats-DeltaMedianTimeInZone.eps','epsc')

%%
for iRat=1:length(AllRats)
    VzdRat = VEHzd(:,:,iRat); 
    VtizRat = VEHtiz(:,:,iRat);
    CzdRat = CNOzd(:,:,iRat);
    CtizRat = CNOtiz(:,:,iRat);
    Hveh(:,:,iRat) = histcn([VzdRat(:) VtizRat(:)],linspace(1,30,30),linspace(1,30,30));
    for iZ = 1:30
        Hveh(iZ,:,iRat) = Hveh(iZ,:,iRat)./repmat(nansum(Hveh(iZ,:,iRat),2),[1,size(Hveh,2),1]);
    end
    Hcno(:,:,iRat) = histcn([CzdRat(:) CtizRat(:)],linspace(1,30,30),linspace(1,30,30));
    for iZ = 1:30
        Hcno(iZ,:,iRat) = Hcno(iZ,:,iRat)./repmat(nansum(Hcno(iZ,:,iRat),2),[1,size(Hcno,2),1]);
    end   
    figure;
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    imagesc(Hveh(:,:,iRat)')
    axis xy
    title([ratlist{iRat} ' Vehicle'])
    xlabel('Delay (secs)')
    ylabel('Stay duration (secs)')
    caxis([0 0.125])
    colorbar;
    saveas(gcf,[ratlist{iRat} '-StayDuration_vs_Delay_Vehicle.fig'],'fig')
    saveas(gcf,[ratlist{iRat} '-StayDuration_vs_Delay_Vehicle.eps'],'epsc')
    figure
    imagesc(Hcno(:,:,iRat)')
    axis xy
    title([ratlist{iRat} ' CNO'])
    caxis([0 0.125])
    colorbar;
    xlabel('Delay (secs)')
    ylabel('Stay duration (secs)')
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    set(gca,'box','off')
    saveas(gcf,[ratlist{iRat} '-StayDuration_vs_Delay_CNO.fig'],'fig')
    saveas(gcf,[ratlist{iRat} '-StayDuration_vs_Delay_CNO.eps'],'epsc')
end


