function PErrorbyRat = summarizeRRpError_rats(VehCNOlist,RatNames,varargin)
% summarizes restaurant row decision instability data across rats.
% PErrorbyRat = summarizeRRvte_rats(VehCNOlist,RatNames)
% where     PErrorbyRat          is a structure with fields
%                    .VEHbyZone,
%                    .CNObyZone
%                              each are nRats x nSess x 4 matrices of
%                                   P[Error] for each rat on each session
%                                   for each zone.
%                    .VEH,
%                    .CNO
%                              each are nRats x nSess matrices of P[Error]
%                                   for each rat on each session for all
%                                   zones.
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
% PErrorbyRat = summarizeRRpError_rats(VehCNOlist,RatNames)
%

maxSess = 28;
maxTrls = 200*4;
nPellets = 2;
k=3;
flavors = {'Cherry' 'Banana' 'Plain White' 'Chocolate'};
process_varargin(varargin);

PErrorbyRat.VEH = nan(size(VehCNOlist,1),maxSess,4);
PErrorbyRat.CNO = nan(size(VehCNOlist,1),maxSess,4);
for iRat = 1 : size(VehCNOlist,1)
    fd = fileparts(VehCNOlist{iRat,1});
    pushdir(fd);
    load(VehCNOlist{iRat,1})
    VEH = RRDecisionInstability(VEH);
    
    zones = VEH.zones;
    isError = VEH.isError;
    isCorrect = VEH.isCorrect;
    pellets = VEH.pellets;
    for iSess = 1:size(zones,1)
        idP = pellets(iSess,:)==nPellets;
        for iZ = 1 : 4
            idZ = zones(iSess,:)==iZ;
            PErrorbyRat.VEHbyZone(iRat,iSess,iZ) = nansum(isError(iSess,idZ&idP))./(nansum(isError(iSess,idZ&idP))+nansum(isCorrect(iSess,idZ&idP)));
        end
        PerrorbyRat.VEH(iRat,iSess) = nansum(isError(iSess,idP),2)./(nansum(isError(iSess,idP),2)+nansum(isCorrect(iSess,idP),2));
    end
    popdir;
    
    fd = fileparts(VehCNOlist{iRat,2});
    pushdir(fd);
    load(VehCNOlist{iRat,2})
    CNO = RRDecisionInstability(CNO);
    
    pellets = CNO.pellets;
    zones = CNO.zones;
    isError = CNO.isError;
    isCorrect = CNO.isCorrect;
    for iSess = 1:size(zones,1)
        idP = pellets(iSess,:)==nPellets;
        for iZ = 1 : 4
            idZ = zones(iSess,:)==iZ;
            
            PErrorbyRat.CNObyZone(iRat,iSess,iZ) = nansum(isError(iSess,idZ&idP))./(nansum(isError(iSess,idZ&idP))+nansum(isCorrect(iSess,idZ&idP)));
        end
        PerrorbyRat.CNO(iRat,iSess) = nansum(isError(iSess,idP),2)./(nansum(isError(iSess,idP),2)+nansum(isCorrect(iSess,idP),2));
    end
    popdir;
end

% Figure: for each rat, find P[Error] under Vehicle and CNO for each zone.
y = nan(4,0);
s = nan(4,0);
legendStr = cell(1,0);
for iZ = 1 : 4
    Veh = nanmean(squeeze(PErrorbyRat.VEHbyZone(:,:,iZ)),2);
    CNO = nanmean(squeeze(PErrorbyRat.CNObyZone(:,:,iZ)),2);
    VehSEM = nanstderr(squeeze(PErrorbyRat.VEHbyZone(:,:,iZ))');
    CNOSEM = nanstderr(squeeze(PErrorbyRat.CNObyZone(:,:,iZ))');
    y = cat(2,y,Veh,CNO);
    legendStr{end+1} = sprintf('Vehicle zone %d',iZ);
    legendStr{end+1} = sprintf('CNO zone %d',iZ);
    s = cat(2,s,VehSEM,CNOSEM);
end
x = 1:length(RatNames);
figure;
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
[bh,eh,ch]=barerrorbar(x,y,s);
set(eh,'color','k')
set(eh,'linewidth',1)
set(ch(1:2:end),'facecolor','b')
set(ch(2:2:end),'facecolor','r')
cmap = RRColorMap;
set(ch,'linewidth',2);
set(ch(1:2),'edgecolor',cmap(1,:))
set(ch(3:4),'edgecolor',cmap(2,:))
set(ch(5:6),'edgecolor','k')
set(ch(7:8),'edgecolor',cmap(4,:))
set(gca,'xtick',x)
set(gca,'xticklabel',RatNames)
xlabel('Rat number')
ylabel(sprintf('Decision instability\n(mean P[Error] \\pm SEM)'));
set(gca,'ylim',[0.02 0.20])
lh=legend(ch,legendStr);
set(lh,'location','northwest')
saveas(gcf,['SummaryPError_EachZone_rats.fig'],'fig')
saveas(gcf,['SummaryPError_EachZone_rats.eps'],'epsc')

% Figure: As above, separated by zone.
x = 1:length(RatNames);
for iZ = 1 : 4
    Veh = nanmean(squeeze(PErrorbyRat.VEHbyZone(:,:,iZ)),2);
    CNO = nanmean(squeeze(PErrorbyRat.CNObyZone(:,:,iZ)),2);
    VehSEM = nanstderr(squeeze(PErrorbyRat.VEHbyZone(:,:,iZ))');
    CNOSEM = nanstderr(squeeze(PErrorbyRat.CNObyZone(:,:,iZ))');
    y = [Veh CNO];
    s = [VehSEM CNOSEM];
    legendStr = cell(1,2);
    legendStr{1} = sprintf('Vehicle');
    legendStr{2} = sprintf('CNO');
    figure;
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    [bh,eh,ch]=barerrorbar(x,y,s);
    set(eh,'color','k')
    set(eh,'linewidth',1)
    set(ch,'linewidth',2)
    set(gca,'xtick',x)
    set(gca,'xticklabel',RatNames)
    legend(ch,legendStr);
    xlabel('Rat number')
    ylabel(sprintf('Decision instability\n(mean P[Error] \\pm SEM)'))
    set(gca,'ylim',[0.02 0.20])
    title(sprintf('%s',flavors{iZ}))
    set(gca,'box','off')
    saveas(gcf,sprintf('SummaryPError_Zone%d_rats.fig',iZ),'fig')
    saveas(gcf,sprintf('SummaryPError_Zone%d_rats.eps',iZ),'epsc')
end

% Figure: boxplot for each zone across rats
x = 1:4;
d = nan(size(PErrorbyRat.VEHbyZone,1),4);
for iZ=1:4
    d(:,iZ) = [nanmean(PErrorbyRat.CNObyZone(:,:,iZ),2)-nanmean(PErrorbyRat.VEHbyZone(:,:,iZ),2)];
end
figure;
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
boxplot(d);
hold on
for iZ=1:4
    plot(ones(size(d,1),1)*iZ,d(:,iZ),'ko','markerfacecolor','k');
end
hold off
ylabel(sprintf('\\Delta decision instability\n(P[Error] CNO - P[Error] Vehicle)'));
xlabel('Zone')
set(gca,'xtick',x)
set(gca,'xticklabel',flavors)
set(gca,'box','off')
saveas(gcf,'SummaryPError_EachZone_acrossRats.fig','fig')
saveas(gcf,'SummaryPError_EachZone_acrossRats.eps','epsc')


% Figure: for each rat, find P[Error] under Vehicle and CNO
figure;
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
x = 1:length(RatNames);
y = [nanmean(PerrorbyRat.VEH,2) nanmean(PerrorbyRat.CNO,2)];
s = [nanstderr(PerrorbyRat.VEH') nanstderr(PerrorbyRat.CNO')];
[bh,eh,ch]=barerrorbar(x,y,s);
set(eh,'color','k')
lh=legend(ch,{'Vehicle' 'CNO'});
set(gca,'xtick',x)
set(gca,'xticklabel',RatNames)
xlabel('Rat number')
ylabel(sprintf('Decision instability\n(mean P[Error] \\pm SEM)'));
set(gca,'ylim',[0.02 0.20])
set(gca,'box','off')
saveas(gcf,['SummaryPError_rats.fig'],'fig')
saveas(gcf,['SummaryPError_rats.eps'],'epsc')

% Figure: boxplot across rats.
figure;
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
d = [nanmean(PerrorbyRat.CNO,2)-nanmean(PerrorbyRat.VEH,2)];
boxplot(d);
hold on
plot(ones(length(d),1),d,'ko','markerfacecolor','k')
hold off
removeBoxplotXtick(gcf)
set(gca,'xcolor','w');
set(gca,'xtick',[]);
set(gca,'box','off')
ylabel(sprintf('\\Delta decision instability\n(P[Error] CNO - P[Error] Vehicle)'));
saveas(gcf,'SummaryPError_acrossRats.fig','fig')
saveas(gcf,'SummaryPError_acrossRats.eps','epsc')