function RMSD4x20byRat = summarizeRRrmsd4x20_rats(VehCNOlist,RatNames,varargin)
% summarizes restaurant row flavour-preference data across rats.
% RMSD4x20byRat = summarizeRRrmsd_rats(VehCNOlist,RatNames)
% where     RMSDbyRat          is a structure with fields
%               .Flavour
%                    .VEH,
%                    .CNO
%                              each are nRats x nSess x nPellets matrices of root-mean
%                                   squared deviation of zone/amount thresholds
%                                   from overall amount, for each rat, each
%                                   session, and each amount.
%               .Amount
%                   .VEH,
%                   .CNO
%                              each are nRats x nSess x nZones matrices of root-mean 
%                                   squared deviation of zone/amount thresholds
%                                   from overall zone, for each rat, each
%                                   session, and each zone.
%
%           VehCNOlist         is nRats x 2 cell array of VEH and CNO
%                                   structures produced by wrap_RR_analysis
%                                   containing restaurant row data for each
%                                   rat in Vehicle (column 1) and CNO
%                                   (column 2) conditions.
%                                   
% Example:
% vehicleStructs = FindFiles('*-StableRR-summary-Veh.mat')
% cnoStructs = FindFiles('*-StableRR-summary-CNO.mat')
% VehCNOlist = cell(length(vehicleStructs),2); 
% VehCNOlist(:,1) = vehicleStructs; 
% VehCNOlist(:,2) = cnoStructs;
% RatNames = {'R266' 'R271' 'R277' 'R279'}
% RMSD4x20byRat = summarizeRRrmsd4x20_rats(VehCNOlist,RatNames)
%

maxSess = 28;
nP = [1 3];
flavours = {'Cherry' 'Banana' 'Plain White' 'Chocolate'};
process_varargin(varargin);

RMSD4x20byRat.Flavour.VEH = nan(size(VehCNOlist,1),maxSess,max(nP));
RMSD4x20byRat.Flavour.CNO = nan(size(VehCNOlist,1),maxSess,max(nP));
RMSD4x20byRat.Amount.VEH = nan(size(VehCNOlist,1),maxSess,4);
RMSD4x20byRat.Amount.CNO = nan(size(VehCNOlist,1),maxSess,4);
for iRat = 1 : size(VehCNOlist,1)
    fd = fileparts(VehCNOlist{iRat,1});
    
    
    pushdir(fd);
    load(VehCNOlist{iRat,1});
    load(VehCNOlist{iRat,2});
    
    for nPellets=nP
        % amount preference at each zone is
        % RMSD of amounts at zone to any amount at zone
        threshOverVeh = VEH.marginalPelletbyZone;
        threshOverCNO = CNO.marginalPelletbyZone;
        
        thresholdsCNO = CNO.thresholds(:,:,nPellets);
        thresholdsVeh = VEH.thresholds(:,:,nPellets);

        dVeh = thresholdsVeh-threshOverVeh;
        dCNO = thresholdsCNO-threshOverCNO;
        MSveh = nanmean(dVeh.^2,2);
        MScno = nanmean(dCNO.^2,2);
        RMSveh = sqrt(MSveh);
        RMScno = sqrt(MScno);

        RMSD4x20byRat.Flavour.VEH(iRat,1:length(RMSveh),nPellets) = RMSveh;
        RMSD4x20byRat.Flavour.CNO(iRat,1:length(RMScno),nPellets) = RMScno;
    end
    for iZ=1:4
        % flavour preference at each zone is
        % RMSD of zone to any zone at amount
        threshOverVeh = squeeze(VEH.marginalZonebyPellet(:,1,:));
        threshOverCNO = squeeze(CNO.marginalZonebyPellet(:,1,:));
        
        thresholdsCNO = squeeze(CNO.thresholds(:,iZ,:));
        thresholdsVeh = squeeze(VEH.thresholds(:,iZ,:));

        dVeh = thresholdsVeh-threshOverVeh;
        dCNO = thresholdsCNO-threshOverCNO;
        MSveh = nanmean(dVeh.^2,2);
        MScno = nanmean(dCNO.^2,2);
        RMSveh = sqrt(MSveh);
        RMScno = sqrt(MScno);

        RMSD4x20byRat.Amount.VEH(iRat,1:length(RMSveh),iZ) = RMSveh;
        RMSD4x20byRat.Amount.CNO(iRat,1:length(RMScno),iZ) = RMScno;
    end
    
    popdir;
end

% Figure 1: bar graph for each rat of effect of CNO on flavour preference for each nPellets.
for nPellets=nP
    figure;
    set(gca,'fontsize',16)
    set(gca,'fontname','Arial')

    x = 1:length(RatNames);
    y = [nanmean(RMSD4x20byRat.Flavour.VEH(:,:,nPellets),2) nanmean(RMSD4x20byRat.Flavour.CNO(:,:,nPellets),2)];
    s = [nanstderr(RMSD4x20byRat.Flavour.VEH(:,:,nPellets)') nanstderr(RMSD4x20byRat.Flavour.CNO(:,:,nPellets)')];
    [bh,eh,ch]=barerrorbar(x,y,s);
    set(eh,'color','k')
    set(ch,'linewidth',2)
    set(eh,'linewidth',2)
    set(gca,'xtick',x)
    set(gca,'xticklabel',RatNames)
    legendStr = {'Vehicle' 'CNO'};
    legend(ch,legendStr)
    xlabel('Rat number')
    ylabel(sprintf('Degree of flavour preference\n(RMSD, flavour from session overall \\pm SEM)'))
    set(gca,'box','off')
    if nPellets==1
        title(sprintf('%d pellet',nPellets));
    else
        title(sprintf('%d pellets',nPellets));
    end
    saveas(gcf,sprintf('SummaryFlavourPref4x20_nPellets%d_rats.fig',nPellets),'fig')
    saveas(gcf,sprintf('SummaryFlavourPref4x20_nPellets%d_rats.eps',nPellets),'epsc')
end

% Figure: bar graph for each rat of effect of CNO on amount preference for
% each flavour
for iZ=1:4
    figure;
    set(gca,'fontsize',16)
    set(gca,'fontname','Arial')

    x = 1:length(RatNames);
    y = [nanmean(RMSD4x20byRat.Amount.VEH(:,:,iZ),2) nanmean(RMSD4x20byRat.Flavour.CNO(:,:,nPellets),2)];
    s = [nanstderr(RMSD4x20byRat.Amount.VEH(:,:,iZ)') nanstderr(RMSD4x20byRat.Amount.CNO(:,:,iZ)')];
    [bh,eh,ch]=barerrorbar(x,y,s);
    set(eh,'color','k')
    set(ch,'linewidth',2)
    set(eh,'linewidth',2)
    set(gca,'xtick',x)
    set(gca,'xticklabel',RatNames)
    legendStr = {'Vehicle' 'CNO'};
    legend(ch,legendStr)
    xlabel('Rat number')
    ylabel(sprintf('Degree of amount preference\n(RMSD, amount from session overall \\pm SEM)'))
    set(gca,'box','off')
    title(sprintf('%s',flavours{iZ}));
    saveas(gcf,sprintf('SummaryAmountPref4x20_Zone%d_rats.fig',iZ),'fig')
    saveas(gcf,sprintf('SummaryAmountPref4x20_Zone%d_rats.eps',iZ),'epsc')
end

% Figure: overall effect of CNO on flavour preference for each nPellets.
d = nan(length(RatNames),max(nP));
for nPellets = nP
    y = [nanmean(RMSD4x20byRat.Flavour.VEH(:,:,nPellets),2) nanmean(RMSD4x20byRat.Flavour.CNO(:,:,nPellets),2)];
    d(:,nPellets) = y(:,2)-y(:,1);
end
figure;
set(gca,'fontsize',16)
set(gca,'fontname','Arial')
boxplot(d);
hold on
for nPellets=1:size(d,2)
    plot(ones(size(d,1),1)*nPellets,d(:,nPellets),'ko','markerfacecolor','k')
end
hold off
ylabel(sprintf('\\Delta flavour preference\n(mean CNO-mean Vehicle)'))
xlabel('Number of pellets')
set(gca,'box','off')
saveas(gcf,sprintf('SummaryFlavourPref4x20_EachAmount_acrossRats.fig'),'fig')
saveas(gcf,sprintf('SummaryFlavourPref4x20_EachAmount_acrossRats.eps'),'epsc')

% Figure: overall effect of CNO on flavour preference at all nPellets.
d = nan(length(RatNames),max(nP));
for nPellets = nP
    y = [nanmean(RMSD4x20byRat.Flavour.VEH(:,:,nPellets),2) nanmean(RMSD4x20byRat.Flavour.CNO(:,:,nPellets),2)];
    d(:,nPellets) = y(:,2)-y(:,1);
end
figure;
set(gca,'fontsize',16)
set(gca,'fontname','Arial')
boxplot(d(:));
hold on
plot(1,d(:),'ko','markerfacecolor','k')
hold off
ylabel(sprintf('\\Delta flavour preference, all amounts together\n(mean CNO-mean Vehicle)'))
removeBoxplotXtick(gcf)
set(gca,'xcolor','w');
set(gca,'xtick',[]);
set(gca,'box','off')
saveas(gcf,sprintf('SummaryFlavourPref4x20_acrossRats.fig'),'fig')
saveas(gcf,sprintf('SummaryFlavourPref4x20_acrossRats.eps'),'epsc')


% Figure: overall effect of CNO on amount preference for each zone.
d = nan(length(RatNames),length(flavours));
for iZ = 1:4
    y = [nanmean(RMSD4x20byRat.Amount.VEH(:,:,iZ),2) nanmean(RMSD4x20byRat.Amount.CNO(:,:,iZ),2)];
    d(:,iZ) = y(:,2)-y(:,1);
end
figure;
set(gca,'fontsize',16)
set(gca,'fontname','Arial')
boxplot(d);
hold on
for iZ=1:4
    plot(ones(size(d,1))*iZ,d(:,iZ),'ko','markerfacecolor','k')
end
hold off
ylabel(sprintf('\\Delta amount preference\n(mean CNO-mean Vehicle)'))
set(gca,'box','off')
set(gca,'xtick',1:4)
set(gca,'xticklabel',flavours)
xlabel('Zone')
saveas(gcf,sprintf('SummaryAmountPref4x20_EachZone_acrossRats.fig'),'fig')
saveas(gcf,sprintf('SummaryAmountPref4x20_EachZone_acrossRats.eps'),'epsc')

% Figure: overall effect of CNO on amount preference at all zones.
d = nan(length(RatNames),4);
for iZ = 1:4
    y = [nanmean(RMSD4x20byRat.Amount.VEH(:,:,iZ),2) nanmean(RMSD4x20byRat.Amount.CNO(:,:,iZ),2)];
    d(:,iZ) = y(:,2)-y(:,1);
end
figure;
set(gca,'fontsize',16)
set(gca,'fontname','Arial')
boxplot(d(:));
hold on
plot(1,d(:),'ko','markerfacecolor','k')
hold off
ylabel(sprintf('\\Delta amount preference, all zones together\n(mean CNO-mean Vehicle)'))
removeBoxplotXtick(gcf)
set(gca,'xcolor','w');
set(gca,'xtick',[]);
set(gca,'box','off')
saveas(gcf,sprintf('SummaryAmountPref4x20_acrossRats.fig',iZ),'fig')
saveas(gcf,sprintf('SummaryAmountPref4x20_acrossRats.eps',iZ),'epsc')