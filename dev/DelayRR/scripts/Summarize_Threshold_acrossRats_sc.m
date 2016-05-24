%% Summarize_Threshold_acrossRats_sc
%  Summarizes the effect of CNO on across-session zone thresholds across
%  rats.
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

%% Summarize effect of CNO on thresholds
threshVeh = nan(maxSess,maxZones,maxPellets);
threshCno = nan(maxSess,maxZones,maxPellets);
ratMeanThresh = nan(length(AllRats),2,maxZones,maxPellets);
ratSEMThresh = nan(length(AllRats),2,maxZones,maxPellets);
for iRat = 1 : length(AllRats)
    VEH = AllRats(iRat).VEH;
    for iSess = 1 : length(VEH)
        threshVeh(iSess,:,:) = VEH(iSess).sd(1).WholeSession.Thresholds.FlavourAmount;
    end
    CNO = AllRats(iRat).CNO;
    for iSess = 1 : length(VEH)
        threshCno(iSess,:,:) = CNO(iSess).sd(1).WholeSession.Thresholds.FlavourAmount;
    end
    ratMeanThresh(iRat,1,:,:) = nanmean(threshVeh);
    ratMeanThresh(iRat,2,:,:) = nanmean(threshCno);
    for r = 1 : size(threshVeh,2)
        for c = 1 : size(threshVeh,3)
            ratSEMThresh(iRat,1,r,c) = nanstderr(squeeze(threshVeh(:,r,c)));
        end
    end
    for r = 1 : size(threshCno,2)
        for c = 1 : size(threshCno,3)
            ratSEMThresh(iRat,2,r,c) = nanstderr(squeeze(threshCno(:,r,c)));
        end
    end
    
    for iZ = 1 : maxZones
        m = nan(size(ratMeanThresh,4),2);
        sem = nan(size(ratSEMThresh,4),2);
        m(:,1) = ratMeanThresh(iRat,1,iZ,:);
        m(:,2) = ratMeanThresh(iRat,2,iZ,:);
        sem(:,1) = ratSEMThresh(iRat,1,iZ,:);
        sem(:,2) = ratSEMThresh(iRat,2,iZ,:);
        figure;
        set(gca,'fontsize',18)
        set(gca,'fontname','Arial')
        set(gca,'box','off')
        [bh,eh,ch] = barerrorbar(1:size(m,1),m,sem);
        set(eh,'linestyle','none')
        set(eh,'color','k')
        set(eh,'linewidth',1)
        xlabel('Number of pellets')
        ylabel(sprintf('Mean threshold\n(secs \\pm SEM)'));
        title(sprintf('%s,\n%s',ratlist{iRat},flavours{iZ}))
        legend(ch,{'Vehicle' 'CNO'})
        saveas(gcf,[ratlist{iRat} '\' ratlist{iRat} sprintf('-Threshold_vs_nPellets_at_Drug_in_Zone%d.fig',iZ)],'fig')
        saveas(gcf,[ratlist{iRat} '\' ratlist{iRat} sprintf('-Threshold_vs_nPellets_at_Drug_in_Zone%d.eps',iZ)],'epsc')
    end
end

for iZ = 1 : maxZones
    m = nan(size(ratMeanThresh,1),size(ratMeanThresh,4),2);
    m(:,:,1) = ratMeanThresh(:,1,iZ,:);
    m(:,:,2) = ratMeanThresh(:,2,iZ,:);
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
    ylabel(sprintf('\\Delta Threshold\n(CNO - Vehicle)'));
    title(sprintf('%s',flavours{iZ}))
    
    saveas(gcf,sprintf('AllRats-deltaThreshold_vs_nPellets_at_Drug_in_Zone%d.fig',iZ),'fig')
    saveas(gcf,sprintf('AllRats-deltaThreshold_vs_nPellets_at_Drug_in_Zone%d.eps',iZ),'epsc')
end

d = squeeze(ratMeanThresh(:,2,:,:)-ratMeanThresh(:,1,:,:));
for nP = 1 : size(d,3)
    figure;
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    set(gca,'box','off')
    d0 = d(:,:,nP);
    boxplot(d0(:))
    removeBoxplotXtick(gcf)
    hold on
    plot(ones(numel(d0),1),d0(:),'ko','markerfacecolor','k','markersize',8)
    hold off
    set(gca,'xcolor','w')
    set(gca,'xtick',[])
    set(gca,'ylim',[-15 15])
    ylabel(sprintf('\\Delta Threshold\n(CNO - Vehicle)'));
    if nP>1
        title(sprintf('%d pellets',nP))
    else
        title(sprintf('%d pellet',nP))
    end
    saveas(gcf,sprintf('AllRats-deltaThreshold_at_Drug_for_nPellets%d.fig',nP),'fig')
    saveas(gcf,sprintf('AllRats-deltaThreshold_at_Drug_for_nPellets%d.eps',nP),'epsc')
end

