%% Summarize_RMSD_acrossRats_sc
%  Summarizes the effect of CNO on threshold variability around overall
%  threshold across rats
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

%% Summarize effect of CNO on RMSDs
flavourVeh = nan(maxSess,maxPellets,length(AllRats));
amountVeh = nan(maxSess,maxZones,length(AllRats));
flavourCno = nan(maxSess,maxPellets,length(AllRats));
amountCno = nan(maxSess,maxZones,length(AllRats));
ratMeanFlavour = nan(length(AllRats),2,maxPellets);
ratMeanAmount = nan(length(AllRats),2,maxZones);
ratSEMFlavour = nan(length(AllRats),2,maxPellets);
ratSEMAmount = nan(length(AllRats),2,maxZones);
for iRat = 1 : length(AllRats)
    VEH = AllRats(iRat).VEH;
    for iSess = 1 : length(VEH)
        flavourVeh(iSess,:,iRat) = VEH(iSess).sd(1).WholeSession.RMSD.Flavour(:)';
        amountVeh(iSess,:,iRat) = VEH(iSess).sd(1).WholeSession.RMSD.Amount(:)';
    end
    CNO = AllRats(iRat).CNO;
    for iSess = 1 : length(VEH)
        flavourCno(iSess,:,iRat) = CNO(iSess).sd(1).WholeSession.RMSD.Flavour(:)';
        amountCno(iSess,:,iRat) = CNO(iSess).sd(1).WholeSession.RMSD.Amount(:)';
    end
    ratMeanFlavour(iRat,1,:) = nanmean(flavourVeh(:,:,iRat));
    ratMeanFlavour(iRat,2,:) = nanmean(flavourCno(:,:,iRat));
    ratSEMFlavour(iRat,1,:) = nanstderr(flavourVeh(:,:,iRat));
    ratSEMFlavour(iRat,2,:) = nanstderr(flavourCno(:,:,iRat));
    ratMeanAmount(iRat,1,:) = nanmean(amountVeh(:,:,iRat));
    ratMeanAmount(iRat,2,:) = nanmean(amountCno(:,:,iRat));
    ratSEMAmount(iRat,1,:) = nanstderr(amountVeh(:,:,iRat));
    ratSEMAmount(iRat,2,:) = nanstderr(amountCno(:,:,iRat));
    
    figure;
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    m = squeeze(ratMeanFlavour(iRat,:,:))';
    boxplot(m);
    removeBoxplotXtick(gcf);
    hold on
    plot(ones(size(m,1),1),m(:,1),'bd','markerfacecolor','b','markersize',8)
    plot(ones(size(m,1),1)*2,m(:,2),'rd','markerfacecolor','r','markersize',8)
    hold off
    xlabel('Number of pellets')
    ylabel('RMSD flavour')
    saveas(gcf,[ratlist{iRat} '\' ratlist{iRat} '-RMSD_flavour_vs_nPellets_at_Drug.fig'],'fig')
    saveas(gcf,[ratlist{iRat} '\' ratlist{iRat} '-RMSD_flavour_vs_nPellets_at_Drug.eps'],'epsc')
    
    figure;
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    m = squeeze(ratMeanAmount(iRat,:,:))';
    boxplot(m);
    removeBoxplotXtick(gcf);
    hold on
    plot(ones(size(m,1),1),m(:,1),'bd','markerfacecolor','b','markersize',8)
    plot(ones(size(m,1),1)*2,m(:,2),'rd','markerfacecolor','r','markersize',8)
    hold off
    xlabel('Zone number')
    ylabel('RMSD amount')
    saveas(gcf,[ratlist{iRat} '\' ratlist{iRat} '-RMSD_amount_vs_zone_at_Drug.fig'],'fig')
    saveas(gcf,[ratlist{iRat} '\' ratlist{iRat} '-RMSD_amount_vs_zone_at_Drug.eps'],'epsc')
end
close all
for nP=1:size(ratMeanFlavour,3)
    figure;
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    [bh,eh,ch]=barerrorbar(1:size(ratMeanFlavour,1),ratMeanFlavour(:,:,nP),ratSEMFlavour(:,:,nP));
    set(eh,'linestyle','none')
    set(eh,'color','k')
    set(eh,'linewidth',1)
    if nP>1
        title(sprintf('%d pellets',nP));
    else
        title(sprintf('%d pellet',nP));
    end
    legend(ch,{'Vehicle' 'CNO'});
    set(gca,'xtick',1:size(ratMeanFlavour))
    set(gca,'xticklabel',ratlist)
    ylabel(sprintf('Flavour RMSD\n(mean \\pm SEM)'))
    saveas(gcf,sprintf('RMSD_flavour_vs_rat_at_drug_nPellets%d.fig',nP),'fig')
    saveas(gcf,sprintf('RMSD_flavour_vs_rat_at_drug_nPellets%d.eps',nP),'epsc')
end
figure;
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
d = squeeze(ratMeanFlavour(:,2,:)-ratMeanFlavour(:,1,:));
% d is now nRats x maxPellets
boxplot(d)
removeBoxplotXtick(gcf)
set(gca,'xtick',1:size(d,2))
set(gca,'xticklabel',1:size(d,2))
set(gca,'ylim',[-5 5])
hold on
for nP=1:size(d,2)
    plot(ones(size(d,1),1)*nP,d(:,nP),'ko','markerfacecolor','k','markersize',8)
end
hold off
xlabel('Number of pellets')
ylabel(sprintf('\\Delta flavour RMSD\n(CNO - Vehicle)'));
saveas(gcf,sprintf('deltaRMSD_flavour_acrossRat_vs_nPellets.fig'),'fig')
saveas(gcf,sprintf('deltaRMSD_flavour_acrossRat_vs_nPellets.eps'),'epsc')

figure;
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
d = squeeze(ratMeanFlavour(:,2,:)-ratMeanFlavour(:,1,:));
% d is now nRats x maxPellets
boxplot(d(:))
hold on
plot(ones(numel(d),1),d(:),'ko','markerfacecolor','k','markersize',8)
hold off
removeBoxplotXtick(gcf)
set(gca,'xcolor','w')
set(gca,'xtick',[])
set(gca,'ylim',[-5 5])
ylabel(sprintf('\\Delta flavour RMSD\n(CNO - Vehicle)'));
saveas(gcf,sprintf('deltaRMSD_flavour_acrossRat_AllnPellets.fig'),'fig')
saveas(gcf,sprintf('deltaRMSD_flavour_acrossRat_AllnPellets.eps'),'epsc')

for iZ=1:size(ratMeanAmount,3)
    figure;
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    [bh,eh,ch]=barerrorbar(1:size(ratMeanAmount,1),ratMeanAmount(:,:,iZ),ratSEMAmount(:,:,iZ));
    set(eh,'linestyle','none')
    set(eh,'color','k')
    set(eh,'linewidth',1)
    title(sprintf('%s',flavours{iZ}));
    legend(ch,{'Vehicle' 'CNO'});
    set(gca,'xtick',1:size(ratMeanAmount))
    set(gca,'xticklabel',ratlist)
    ylabel(sprintf('Amount RMSD\n(mean \\pm SEM)'))
    saveas(gcf,sprintf('RMSD_amount_vs_rat_at_drug_Zone%d.fig',iZ),'fig')
    saveas(gcf,sprintf('RMSD_amount_vs_rat_at_drug_Zone%d.fig',iZ),'epsc')
end

figure;
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
d = squeeze(ratMeanAmount(:,2,:)-ratMeanAmount(:,1,:));
% d is now nRats x maxPellets
boxplot(d)
removeBoxplotXtick(gcf)
hold on
for iZ=1:size(d,2)
    plot(ones(size(d,1),1)*iZ,d(:,iZ),'ko','markerfacecolor','k','markersize',8);
end
hold off
set(gca,'xtick',1:size(d,2))
set(gca,'xticklabel',flavours)
set(gca,'ylim',[-5 5])
ylabel(sprintf('\\Delta amount RMSD\n(CNO - Vehicle)'));
saveas(gcf,sprintf('deltaRMSD_amount_acrossRat_vs_Zone.fig'),'fig')
saveas(gcf,sprintf('deltaRMSD_amount_acrossRat_vs_Zone.eps'),'epsc')

figure;
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
d = squeeze(ratMeanAmount(:,2,:)-ratMeanAmount(:,1,:));
% d is now nRats x maxPellets
boxplot(d(:))
removeBoxplotXtick(gcf)
hold on
plot(ones(numel(d),1),d(:),'ko','markerfacecolor','k','markersize',8)
hold off
set(gca,'xcolor','w')
set(gca,'xtick',[])
set(gca,'ylim',[-5 5])
ylabel(sprintf('\\Delta amount RMSD\n(CNO - Vehicle)'));
saveas(gcf,sprintf('deltaRMSD_amount_acrossRat_AllZones.fig'),'fig')
saveas(gcf,sprintf('deltaRMSD_amount_acrossRat_AllZones.eps'),'epsc')