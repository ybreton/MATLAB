%% Summarize_DecisionInstability_acrossRats_sc
%  Summarizes the effect of CNO on P[Error] across rats
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

%% Summarize effect of CNO on decision instability
pErrorVeh = nan(maxSess,maxZones,maxPellets);
pErrorCno = nan(maxSess,maxZones,maxPellets);
ratMeanDI = nan(length(AllRats),2,maxZones,maxPellets);
ratSEMDI= nan(length(AllRats),2,maxZones,maxPellets);
nCorrect = nan(length(AllRats),2,maxSess,maxZones,maxPellets);
nErrors = nan(length(AllRats),2,maxSess,maxZones,maxPellets);
overallNCorrect = nan(length(AllRats),2,maxSess,maxPellets);
overallNErrors = nan(length(AllRats),2,maxSess,maxPellets);
pStat = nan(length(AllRats),maxPellets);
for iRat = 1 : length(AllRats)
    VEH = AllRats(iRat).VEH;
    for iSess = 1 : length(VEH)
        sd = VEH(iSess).sd;
        [threshVeh,correct,incorrect] = RRThresholds(sd);
        pErrorVeh(iSess,:,:) = incorrect./(correct+incorrect);
        nCorrect(iRat,1,iSess,:,:) = correct;
        nErrors(iRat,1,iSess,:,:) = incorrect;
    end
    CNO = AllRats(iRat).CNO;
    for iSess = 1 : length(CNO)
        sd = CNO(iSess).sd;
        [threshCno,correct,incorrect] = RRThresholds(sd);
        pErrorCno(iSess,:,:) = incorrect./(correct+incorrect);
        nCorrect(iRat,2,iSess,:,:) = correct;
        nErrors(iRat,2,iSess,:,:) = incorrect;
    end
    ratMeanDI(iRat,1,:,:) = nanmean(pErrorVeh);
    ratMeanDI(iRat,2,:,:) = nanmean(pErrorCno);
    for r = 1 : size(pErrorVeh,2)
        for c = 1 : size(pErrorVeh,3)
            ratSEMDI(iRat,1,r,c) = nanstderr(squeeze(pErrorVeh(:,r,c)));
        end
    end
    for r = 1 : size(pErrorCno,2)
        for c = 1 : size(pErrorCno,3)
            ratSEMDI(iRat,2,r,c) = nanstderr(squeeze(pErrorCno(:,r,c)));
        end
    end
    
    overallNCorrect(iRat,:,:,:) = squeeze(nansum(nCorrect(iRat,:,:,:,:),4));
    overallNErrors(iRat,:,:,:) = squeeze(nansum(nErrors(iRat,:,:,:,:),4));
    p = squeeze(overallNErrors(iRat,:,:,:)./(overallNCorrect(iRat,:,:,:)+overallNErrors(iRat,:,:,:)));
    % p is 2 x nSess x nP.
    for nP = 1 : maxPellets
        m = (p(:,:,nP));
        figure;
        set(gca,'fontsize',18)
        set(gca,'fontname','Arial')
        set(gca,'box','off')
        boxplot(m');
        removeBoxplotXtick(gcf);
        set(gca,'xtick',1:2)
        set(gca,'xticklabel',{'Vehicle' 'CNO'})
        hold on
        plot(ones(size(m,2),1),m(1,:)','bd','markerfacecolor','b','markersize',8)
        plot(ones(size(m,2),1)*2,m(2,:)','rd','markerfacecolor','r','markersize',8)
        hold off
        ylabel(sprintf('Decision instability\n(mean P[error] \\pm SEM)'));
        title(sprintf('%s,\nAll flavours, %d pellets',ratlist{iRat},nP))
        saveas(gcf,[ratlist{iRat} '\' ratlist{iRat} sprintf('-DecisionInstability_at_Drug_allZones_nPellets%d.fig',nP)],'fig')
        saveas(gcf,[ratlist{iRat} '\' ratlist{iRat} sprintf('-DecisionInstability_at_Drug_allZones_nPellets%d.eps',nP)],'epsc')
        pStat(iRat,nP) = kruskalwallis([m(1,:)';m(2,:)'],[zeros(size(m,2),1);ones(size(m,2),1)],'off');
    end
    
    for iZ = 1 : maxZones
        m = nan(size(ratMeanDI,4),2);
        sem = nan(size(ratSEMDI,4),2);
        m(:,1) = ratMeanDI(iRat,1,iZ,:);
        m(:,2) = ratMeanDI(iRat,2,iZ,:);
        sem(:,1) = ratSEMDI(iRat,1,iZ,:);
        sem(:,2) = ratSEMDI(iRat,2,iZ,:);
        figure;
        set(gca,'fontsize',18)
        set(gca,'fontname','Arial')
        set(gca,'box','off')
        [bh,eh,ch] = barerrorbar(1:size(m,1),m,sem);
        set(eh,'linestyle','none')
        set(eh,'color','k')
        set(eh,'linewidth',1)
        xlabel('Number of pellets')
        ylabel(sprintf('Decision instability\n(mean P[error] \\pm SEM)'));
        title(sprintf('%s,\n%s',ratlist{iRat},flavours{iZ}))
        legend(ch,{'Vehicle' 'CNO'})
        saveas(gcf,[ratlist{iRat} '\' ratlist{iRat} sprintf('-DecisionInstability_vs_nPellets_at_Drug_in_Zone%d.fig',iZ)],'fig')
        saveas(gcf,[ratlist{iRat} '\' ratlist{iRat} sprintf('-DecisionInstability_vs_nPellets_at_Drug_in_Zone%d.eps',iZ)],'epsc')
    end
    close all
end
figure;
p = overallNErrors./(overallNCorrect+overallNErrors);
% p is nRats x 2 x nSess x nP
for nP = 1 : maxPellets
    m = squeeze(nanmean(p(:,:,:,nP),3));
    n = sum(double(~isnan(p(:,:,:,nP))),3);
    sem = nanstd(p(:,:,:,nP),1,3)./sqrt(n);
    figure;
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    set(gca,'box','off')
    [bh,eh,ch] = barerrorbar(1:size(m,1),m,sem);
    set(eh,'linestyle','none')
    set(eh,'color','k')
    set(eh,'linewidth',1)
    set(gca,'xtick',1:size(m,1))
    set(gca,'xticklabel',ratlist)
    ystar = mean([max(m(:)) max(get(gca,'ylim'))]);
    hold on
    for iRat=1:size(pStat,1)
        if pStat(iRat,nP)<0.05
            plot(iRat,ystar,'k*','markersize',12)
        end
    end
    hold off
    ylabel(sprintf('Decision instability\n(mean P[error] \\pm SEM)'));
    if nP>1
        title(sprintf('All flavours\n%d pellets',nP))
    else
        title(sprintf('All flavours\n%d pellet',nP))
    end
    lh=legend(ch,{'Vehicle' 'CNO'});
    set(lh,'location','northwest')
    
    saveas(gcf,sprintf('AllRats-DecisionInstability_at_Drug_allZones_nPellets%d.fig',nP),'fig')
    saveas(gcf,sprintf('AllRats-DecisionInstability_at_Drug_allZones_nPellets%d.eps',nP),'epsc')
end

for iZ = 1 : maxZones
m = nan(size(ratMeanDI,1),size(ratMeanDI,4),2);
m(:,:,1) = ratMeanDI(:,1,iZ,:);
m(:,:,2) = ratMeanDI(:,2,iZ,:);
d = squeeze(m(:,:,2)-m(:,:,1));

figure;
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
set(gca,'box','off')
boxplot(d)
removeBoxplotXtick(gcf)
set(gca,'xtick',1:size(d,2))
set(gca,'xticklabel',1:size(d,2))
hold on
for nP=1:size(d,2)
    plot(ones(size(d,1),1)*nP,d(:,nP),'ko','markerfacecolor','k','markersize',8)
end
hold off

    
    xlabel('Number of pellets')
    ylabel(sprintf('\\Delta P[Error]\n(CNO - Vehicle)'));
    title(sprintf('%s',flavours{iZ}))
    
    saveas(gcf,sprintf('AllRats-deltaDecisionInstability_vs_nPellets_at_Drug_in_Zone%d.fig',iZ),'fig')
    saveas(gcf,sprintf('AllRats-deltaDecisionInstability_vs_nPellets_at_Drug_in_Zone%d.eps',iZ),'epsc')
end
d = squeeze(ratMeanDI(:,2,:,:)-ratMeanDI(:,1,:,:));


% overallNCorrect => nRats x 2 x nSess x nPellets
% overallNErrors  => nRats x 2 x nSess x nPellets

ratP = squeeze(nanmean(overallNErrors./(overallNErrors+overallNCorrect),3));

% ratP => nRats x 2 x nPellets

ratD = squeeze(ratP(:,2,:) - ratP(:,1,:));

% ratD => nRats x nPellets
for nP = 1 : size(d,3)
    figure;
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    set(gca,'box','off')
    d0 = ratD(:,nP);
    boxplot(d0)
    h=ttest(d0);
    removeBoxplotXtick(gcf)
    hold on
    plot(ones(length(d0),1),d0,'ko','markerfacecolor','k','markersize',8)
    set(gca,'xcolor','w')
    set(gca,'xtick',[])
    set(gca,'ylim',[-.1 .1])
    
    ystar = mean([max(d0) max(get(gca,'ylim'))]);
    if h
        plot(1,ystar,'k*','markersize',12)
    end
    hold off
    ylabel(sprintf('\\Delta Decision Instability\n(CNO - Vehicle)'));
    if nP>1
        title(sprintf('%d pellets',nP))
    else
        title(sprintf('%d pellet',nP))
    end
    saveas(gcf,sprintf('AllRats-deltaDecisionInstability_at_Drug_for_nPellets%d.fig',nP),'fig')
    saveas(gcf,sprintf('AllRats-deltaDecisionInstability_at_Drug_for_nPellets%d.eps',nP),'epsc')
end
