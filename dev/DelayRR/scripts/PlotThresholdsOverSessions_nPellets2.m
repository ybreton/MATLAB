%% 
threshVeh = nan(4,3,length(VEH));
for iSess = 1 : length(VEH)
    sd = VEH(iSess).sd;
    threshVeh(:,:,iSess) = sd(1).WholeSession.Thresholds.FlavourAmount;
    
end
threshCNO = nan(4,3,length(CNO));
for iSess = 1 : length(CNO)
    sd = CNO(iSess).sd;
    threshCNO(:,:,iSess) = sd(1).WholeSession.Thresholds.FlavourAmount;
end

    figure;
    subplot(2,2,1)
    title('Vehicle')
    thresh = squeeze(threshVeh(:,2,:));
    cmap = RRColorMap;
    cmap(3,:) = zeros(1,3);
    for r = 1 : size(thresh,1)
        hold on
        plot(1:size(threshVeh,3),thresh(r,:),'bo','markerfacecolor',cmap(r,:),'markersize',8)
        hold off
    end
    set(gca,'ylim',[0 30])
    ylabel(sprintf('Threshold'))
    set(gca,'xtick',[])
    xlabel('Sessions')
    
    subplot(2,2,3)
    title('CNO')
    thresh = squeeze(threshCNO(:,2,:));
    cmap = RRColorMap;
    cmap(3,:) = zeros(1,3);
    for r = 1 : size(thresh,1)
        hold on
        plot(1:size(threshCNO,3),thresh(r,:),'rs','markerfacecolor',cmap(r,:),'markersize',8)
        hold off
    end
    set(gca,'ylim',[0 30])
    ylabel(sprintf('Threshold'))
    set(gca,'xtick',[])
    xlabel('Sessions')
    
    subplot(2,2,2)
    title('Vehicle')
    thresh = squeeze(threshVeh(:,2,:));
    v = nanstd(thresh);
    plot(1:size(thresh,2),v,'bo','markerfacecolor','b','markersize',8)
    hold on
    plot([find(~isnan(v),1,'first') find(~isnan(v),1,'last')],[nanmean(v) nanmean(v)],'b-','linewidth',2)
    hold off
    set(gca,'ylim',[0 10])
    ylabel(sprintf('SD of threshold'))
    set(gca,'xtick',[])
    xlabel('Sessions')
    
    
    subplot(2,2,4)
    title('CNO')
    thresh = squeeze(threshCNO(:,2,:));
    v = nanstd(thresh);
    plot(1:size(thresh,2),v,'rs','markerfacecolor','r','markersize',8)
    hold on
    plot([find(~isnan(v),1,'first') find(~isnan(v),1,'last')],[nanmean(v) nanmean(v)],'r-','linewidth',2)
    hold off
    set(gca,'ylim',[0 10])
    ylabel(sprintf('SD of threshold'))
    set(gca,'xtick',[])
    xlabel('Sessions')
    