%% Summarize_Threshold_overall_acrossRats_sc
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
pStat = nan(length(AllRats),maxPellets);
cmap = RRColorMap;
cmap(3,:) = zeros(1,3);
for iRat = 1 : length(AllRats)
    VEH = AllRats(iRat).VEH;
    CNO = AllRats(iRat).CNO;
    
    xFlavVeh = wrap_RR_summarizeThreshold(VEH);
    overallVeh = squeeze(nanmean(xFlavVeh,1));
    
    xFlavCNO = wrap_RR_summarizeThreshold(CNO);
    overallCNO = squeeze(nanmean(xFlavCNO,1));
    
    m(iRat,:,1) = nanmean(overallVeh,2);
    sem(iRat,:,1) = nanstderr(overallVeh');
    m(iRat,:,2) = nanmean(overallCNO,2);
    sem(iRat,:,2) = nanstderr(overallCNO');
    for nP=1:maxPellets
        pStat(iRat,nP) = kruskalwallis([overallVeh(nP,:)';overallCNO(nP,:)'],[zeros(length(overallVeh(nP,:)),1);ones(length(overallCNO(nP,:)),1)],'off');
    end
end

figure;
[bh,eh,ch]=barerrorbar(1:length(ratlist),squeeze(m(:,2,:)),squeeze(sem(:,2,:)));
set(gca,'ylim',[10 32.5])
set(gca,'ytick',[10:5:30])
ystar = mean([max(get(gca,'ylim')) max(max(m(:,2,:)))]);
hold on
for iRat=1:size(pStat,1)
    if pStat(iRat,2)<0.05
        plot(1,max(get(gca,'ylim')),'k*','markersize',12)
    end
end
hold off
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
set(gca,'box','off')
set(gca,'xtick',1:length(ratlist));
set(gca,'xticklabel',ratlist)
lh=legend(ch,{'Vehicle' 'CNO'});
ylabel(sprintf('Overall 2-pellet threshold\n(mean across sessions \\pm SEM)'))
saveas(gcf,'AllRats-overallThresh_at_Drug_acrossRats.fig','fig')
saveas(gcf,'AllRats-overallThresh_at_Drug_acrossRats.eps','epsc')

figure;
boxplot(m(:,2,2)-m(:,2,1));
removeBoxplotXtick(gcf)
h = ttest(m(:,2,2)-m(:,2,1));
ystar = mean([max(get(gca,'ylim')) max(m(:,2,2)-m(:,2,1))]);
hold on
plot(ones(size(m,1),1),m(:,2,2)-m(:,2,1),'ko','markerfacecolor','k','markersize',8)
if h
    plot(1,max(get(gca,'ylim')),'k*','markersize',12)
end
hold off
set(gca,'ylim',[-5 3])
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
set(gca,'box','off')
set(gca,'xcolor','w')
set(gca,'xtick',[])
ylabel(sprintf('\\Delta overall 2-pellet threshold\n(CNO - Vehicle)'))
saveas(gcf,'AllRats-Delta_overallThresh_acrossRats.fig','fig')
saveas(gcf,'AllRats-Delta_overallThresh_acrossRats.eps','epsc')