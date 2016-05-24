%% Summarize_nTrials_acrossRats_sc:
%  Example script to summarize the effect of CNO on number of trials
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

Behav = 'StableRR';
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

%% Number of trials
mAcrossRats = nan(length(AllRats),2);
sAcrossRats = nan(length(AllRats),2);
pStat = nan(length(AllRats),1);
for iRat = 1 : length(AllRats)
    VEH = AllRats(iRat).VEH;
    CNO = AllRats(iRat).CNO;
    
    nTrialsVeh = wrap_RR_summarizeNTrials(VEH);
    nTrialsCNO = wrap_RR_summarizeNTrials(CNO);
    
    mAcrossRats(iRat,1) = nanmean(nTrialsVeh);
    mAcrossRats(iRat,2) = nanmean(nTrialsCNO);
    sAcrossRats(iRat,1) = nanstderr(nTrialsVeh);
    sAcrossRats(iRat,2) = nanstderr(nTrialsCNO);
    pStat(iRat) = kruskalwallis([nTrialsVeh; nTrialsCNO],[zeros(length(nTrialsVeh),1); ones(length(nTrialsCNO),1)],'off');
end

figure;
set(gca,'fontsize',18)
        set(gca,'fontname','Arial')
        set(gca,'box','off')
[bh,eh,ch]=barerrorbar(1:length(ratlist),mAcrossRats,sAcrossRats);
set(gca,'xtick',1:length(ratlist))
set(gca,'xticklabel',ratlist)
legend(ch,{'Vehicle' 'CNO'})
ylabel('Number of trials')
ystar = mean([max(get(gca,'ylim')) max(mAcrossRats(:))]);
hold on
for iRat=1:length(pStat)
    if pStat(iRat)<0.05
        plot(iRat,ystar,'k*','markersize',12)
    end
end
hold off
saveas(gcf,'AllRats-nTrials_at_Drug.fig','fig')
saveas(gcf,'AllRats-nTrials_at_Drug.eps','epsc')

figure;
set(gca,'fontsize',18)
        set(gca,'fontname','Arial')
        set(gca,'box','off')
boxplot((mAcrossRats(:,2)-mAcrossRats(:,1)));
removeBoxplotXtick(gcf);
hold on
plot(ones(size(mAcrossRats,1),1),(mAcrossRats(:,2)-mAcrossRats(:,1)),'ko','markerfacecolor','k','markersize',8);
hold off
h=ttest(d);
if h
    plot(1,mean([max(get(gca,'ylim')); max((mAcrossRats(:,2)-mAcrossRats(:,1)))]),'k*','markersize',12);
end
set(gca,'xcolor','w')
set(gca,'xtick',[])
ylabel(sprintf('\\Delta Number of trials\n(CNO - Vehicle)'))
saveas(gcf,'AllRats-Delta_nTrials_acrossRats.fig','fig')
saveas(gcf,'AllRats-Delta_nTrials_acrossRats.eps','epsc')