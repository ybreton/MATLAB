%% Summarize_Threshold_variability_acrossRats_sc
%  Summarizes effect of CNO on session-by-session zone threshold standard
%  deviation around session means across rats.
%% Summarize across rats.
ratlist = {'R266';
           'R271';
           'R277';
           'R279'};
vehicleStr = {'Saline';
              'Saline'
              'Vehicle'
              'Vehicle'};
cnoStr = {'Drug';
          'CNO';
          'CNO';
          'CNO'};
maxSess = 28;
maxPellets = 3;
maxZones = 4;
flavours = {'Cherry' 'Banana' 'Plain White' 'Chocolate'};

%% Prepare AllRats structure.
clear AllRats
for iRat = 1 : length(ratlist)
    pushdir([ratlist{iRat} '\Promotable']);
    disp([ratlist{iRat} '\Promotable'])
    
    % Get session list.
    fn = FindFiles('RR-*.mat');
    fd = cell(length(fn),1);
    for f = 1 : length(fn); 
        fd{f} = fileparts(fn{f}); 
    end
    fd = unique(fd);
    
    disp(['Collecting sessions for ' ratlist{iRat}])
    AllSessions = wrap_RR_collectSess(fd);
    VEH = wrap_RR_analysis(AllSessions,vehicleStr{iRat});
    CNO = wrap_RR_analysis(AllSessions,cnoStr{iRat});
    
    save([ratlist{iRat} '-VEH.mat'],'VEH')
    save([ratlist{iRat} '-CNO.mat'],'CNO')
    
    tempStruc.VEH = VEH;
    tempStruc.CNO = CNO;
    
    AllRats(iRat) = tempStruc;
    
    clear AllSessions VEH CNO tempStruc
    popdir;
end
save('AllRats.mat','AllRats');

%% Summarize effect of CNO on zone-to-zone threshold variance.

m = nan(length(AllRats),maxPellets,2);
sem = nan(length(AllRats),maxPellets,2);
cmap = RRColorMap;
cmap(3,:) = zeros(1,3);
ratMeanRMS = nan(length(AllRats),2);
ratSEMRMS = nan(length(AllRats),2);
pStat = nan(length(AllRats),1);
for iRat = 1 : length(AllRats)
    VEH = AllRats(iRat).VEH;
    CNO = AllRats(iRat).CNO;
    
    xFlavVeh = wrap_RR_summarizeThreshold(VEH);
    overallVeh = squeeze(nanmean(xFlavVeh,1));
    DevVeh = xFlavVeh-repmat(nanmean(xFlavVeh,1),[4 1 1]);
    DevAbsVeh = abs(DevVeh);
    
    xFlavCNO = wrap_RR_summarizeThreshold(CNO);
    overallCNO = squeeze(nanmean(xFlavCNO,1));
    DevCNO = xFlavCNO-repmat(nanmean(xFlavCNO,1),[4 1 1]);
    DevAbsCNO = abs(DevCNO);
    
    % Plot only 2pellets.
    for nP = 2
        figure;
        subplot(2,2,1)
        set(gca,'fontsize',18)
        set(gca,'fontname','Arial')
        set(gca,'box','off')
        ph=plot(squeeze(xFlavVeh(:,nP,:))','o');
        for iP = 1 : length(ph)
            set(ph(iP),'markerfacecolor',cmap(iP,:));
            set(ph(iP),'markeredgecolor',cmap(iP,:));
        end
        firstSess = find(~isnan(overallVeh(nP,:)),1,'first');
        lastSess = find(~isnan(overallVeh(nP,:)),1,'last');
        hold on
        plot([firstSess lastSess],[nanmean(nanmean(xFlavVeh(:,nP,:),3),1) nanmean(nanmean(xFlavVeh(:,nP,:),3),1)],'k-')
        hold off
        ylabel(sprintf('Threshold, %d pellets', nP))
        xlabel('session')
        set(gca,'xlim',[firstSess-1 lastSess+1])
        set(gca,'ylim',[0 30])
        
        subplot(2,2,3)
        set(gca,'fontsize',18)
        set(gca,'fontname','Arial')
        set(gca,'box','off')
        ph=plot(squeeze(xFlavCNO(:,nP,:))','s');
        for iP = 1 : length(ph)
            set(ph(iP),'markerfacecolor',cmap(iP,:));
            set(ph(iP),'markeredgecolor',cmap(iP,:));
        end
        firstSess = find(~isnan(overallCNO(nP,:)),1,'first');
        lastSess = find(~isnan(overallCNO(nP,:)),1,'last');
        hold on
        plot([firstSess lastSess],[nanmean(nanmean(xFlavCNO(:,nP,:),3),1) nanmean(nanmean(xFlavCNO(:,nP,:),3),1)],'k-')
        hold off
        ylabel(sprintf('Threshold, %d pellets', nP))
        xlabel('session')
        set(gca,'xlim',[firstSess-1 lastSess+1])
        set(gca,'ylim',[0 30])
        
        subplot(2,2,2)
        set(gca,'fontsize',18)
        set(gca,'fontname','Arial')
        set(gca,'box','off')
        ph=plot(squeeze(DevAbsVeh(:,nP,:))','ob');
        hold on
        plot([0 maxSess],[nanmean(nanmean(DevAbsVeh(:,nP,:),1),3) nanmean(nanmean(DevAbsVeh(:,nP,:),1),3)],'b-')
        hold off
        firstSess = find(~isnan(overallVeh(nP,:)),1,'first');
        lastSess = find(~isnan(overallVeh(nP,:)),1,'last');
        ylabel(sprintf('Standard deviation of thresholds, %d pellets', nP))
        set(gca,'xlim',[firstSess-1 lastSess+1])
        set(gca,'ylim',[0 12])
        
        subplot(2,2,4)
        set(gca,'fontsize',18)
        set(gca,'fontname','Arial')
        set(gca,'box','off')
        ph=plot(squeeze(DevAbsCNO(:,nP,:))','sr');
        hold on
        plot([0 maxSess],[nanmean(nanmean(DevAbsCNO(:,nP,:),1),3) nanmean(nanmean(DevAbsCNO(:,nP,:),1),3)],'r-')
        hold off
        firstSess = find(~isnan(overallCNO(nP,:)),1,'first');
        lastSess = find(~isnan(overallCNO(nP,:)),1,'last');
        set(gca,'xlim',[firstSess-1 lastSess+1])
        set(gca,'ylim',[0 12])
        
        ylabel(sprintf('Standard deviation of thresholds, %d pellets', nP))
        saveas(gcf,[ratlist{iRat} sprintf('-ThresholdVariance_nPellets%d.fig',nP)],'fig')
        saveas(gcf,[ratlist{iRat} sprintf('-ThresholdVariance_nPellets%d.eps',nP)],'epsc')
    end
    x0 = DevAbsVeh(:,2,:);
    x0 = x0(:);
    x1 = DevAbsCNO(:,2,:);
    x1 = x1(:);
    ratMeanRMS(iRat,1) = nanmean(x0);
    ratMeanRMS(iRat,2) = nanmean(x1);
    ratSEMRMS(iRat,1) = nanstderr(x0);
    ratSEMRMS(iRat,2) = nanstderr(x1);
    %pStat(iRat) = kruskalwallis([sqrt(vFlavVeh(2,:)');sqrt(vFlavCNO(2,:)')],[zeros(length(vFlavVeh(2,:)),1);ones(length(vFlavCNO(2,:)),1)],'off');
    %pStat(iRat) = anova1([x0;x1],[zeros(length(x0),1);ones(length(x1),1)],'off');
    pStat(iRat) = kruskalwallis([x0;x1],[zeros(length(x0),1);ones(length(x1),1)],'off');
end

figure;
[bh,eh,ch]=barerrorbar(1:length(ratlist),ratMeanRMS,ratSEMRMS);
set(gca,'xtick',1:length(ratlist));
set(gca,'xticklabel',ratlist)
set(gca,'ylim',[1 8])
ystar=mean([max(get(gca,'ylim')) max(ratMeanRMS(:))]);
hold on
for iRat = 1 : length(pStat)
    if pStat(iRat)<0.05
        plot(iRat,max(get(gca,'ylim')),'k*','markersize',12)
    end
end
hold off
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
set(gca,'box','off')
legend(ch,{'Vehicle' 'CNO'})

ylabel(sprintf('Absolute deviation of zone thresholds\n(overall mean \\pm SEM)'))
saveas(gcf,'AllRats-SDthresh_at_Drug_acrossRats.fig','fig')
saveas(gcf,'AllRats-SDthresh_at_Drug_acrossRats.eps','epsc')

figure;
boxplot(ratMeanRMS(:,2)-ratMeanRMS(:,1));
set(gca,'ylim',[-2 2])
h = ttest(ratMeanRMS(:,2)-ratMeanRMS(:,1));
removeBoxplotXtick(gcf)
ylim = get(gca,'ylim');
ylim(1) = min(ylim(1),0);
ylim(2) = max(ylim(2),0);
hold on
plot(ones(size(ratMeanRMS,1),1),ratMeanRMS(:,2)-ratMeanRMS(:,1),'ko','markerfacecolor','k','markersize',8)
if h
    plot(1,max(get(gca,'ylim')),'k*','markersize',12)
end
hold off
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
set(gca,'box','off')
set(gca,'xcolor','w')
set(gca,'xtick',[])
ylabel(sprintf('\\Delta absolute deviation of zone thresholds\n(CNO - Vehicle)'))
saveas(gcf,'AllRats-Delta_SDthresh_acrossRats.fig','fig')
saveas(gcf,'AllRats-Delta_SDthresh_acrossRats.eps','epsc')