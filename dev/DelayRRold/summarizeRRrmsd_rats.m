function RMSDbyRat = summarizeRRrmsd_rats(VehCNOlist,RatNames,varargin)
% summarizes restaurant row flavour-preference data across rats.
% RMSDbyRat = summarizeRRrmsd_rats(VehCNOlist,RatNames)
% where     RMSDbyRat          is a structure with fields
%                    .VEH,
%                    .CNO
%                              each are nRats x nSess matrices of root-mean
%                                   squared deviation of zone thresholds
%                                   from overall, for each rat and each
%                                   session.
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
% RMSDbyRat = summarizeRRrmsd_rats(VehCNOlist,RatNames)
%

maxSess = 28;
nPellets = 2;
cmap = RRColorMap;
cmap(3,:) = [0 0 0];
process_varargin(varargin);

RMSDbyRat.VEH = nan(size(VehCNOlist,1),maxSess);
RMSDbyRat.CNO = nan(size(VehCNOlist,1),maxSess);
for iRat = 1 : size(VehCNOlist,1)
    fd = fileparts(VehCNOlist{iRat,1});
    
    
    pushdir(fd);
    load(VehCNOlist{iRat,1});
    load(VehCNOlist{iRat,2});
    thresholdsVeh = VEH.thresholds(:,:,nPellets);
    
    thresholdsCNO = CNO.thresholds(:,:,nPellets);
    
    threshOverVeh = repmat(VEH.marginalZonebyPellet(:,1,nPellets),1,4);
    threshOverCNO = repmat(CNO.marginalZonebyPellet(:,1,nPellets),1,4);
    
    dVeh = thresholdsVeh-threshOverVeh;
    dCNO = thresholdsCNO-threshOverCNO;
    MSveh = nanmean(dVeh.^2,2);
    MScno = nanmean(dCNO.^2,2);
    RMSveh = sqrt(MSveh);
    RMScno = sqrt(MScno);
    
    RMSDbyRat.VEH(iRat,1:length(RMSveh)) = RMSveh;
    RMSDbyRat.CNO(iRat,1:length(RMScno)) = RMScno;
    % for each rat, plot mean threshold for each zone, superimposed, and mean
    % overall.
    figure;
    hold on
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    predX = 1:30;
    ph = nan(5,1);
    for iZ=1:4
        predY = double(predX<nanmean(thresholdsVeh(:,iZ)));
        predY(predX==nanmean(thresholdsVeh(:,iZ)))=0.5;
        plot(VEH.delays(VEH.zones==iZ),VEH.staygo(VEH.zones==iZ)+randn(length(VEH.staygo(VEH.zones==iZ)),1)/50,'o','markerfacecolor',cmap(iZ,:),'markeredgecolor',cmap(iZ,:))
        ph(iZ)=plot(predX,predY,'-','color',cmap(iZ,:),'linewidth',1);
    end
    predY = double(predX<nanmean(threshOverVeh(:,1)));
    predY(predX==nanmean(threshOverVeh(:,1))) = 0.5;
    ph(5)=plot(predX,predY,'-b','linewidth',2);
    legend(ph,{'Cherry' 'Banana' 'Plain white' 'Chocolate' 'Overall'})
    hold off
    fn = VEH.fn;
    SSN = cell(length(fn),1);
    for iF=1:length(fn)
        fd = fileparts(fn{iF});
        delim = regexpi(fd,'\');
        SSN{iF} = fd(max(delim)+1:end);
    end
    set(gca,'ylim',[-0.05 1.05])
    set(gca,'ytick',[0 1])
    set(gca,'yticklabel',{'skip' 'stay'})
    xlabel('Delay (secs)')
    title(sprintf('%s -- %s\nVehicle',SSN{1},SSN{end}))
    saveas(gcf,sprintf('%s--%s-Vehicle-meanChoices.fig',SSN{1},SSN{end}),'fig')
    saveas(gcf,sprintf('%s--%s-Vehicle-meanChoices.eps',SSN{1},SSN{end}),'epsc')
    
    figure;
    hold on
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    predX = 1:30;
    ph = nan(5,1);
    for iZ=1:4
        predY = double(predX<nanmean(thresholdsCNO(:,iZ)));
        predY(predX==nanmean(thresholdsCNO(:,iZ)))=0.5;
        plot(CNO.delays(CNO.zones==iZ),CNO.staygo(CNO.zones==iZ)+randn(length(CNO.staygo(CNO.zones==iZ)),1)/50,'o','markerfacecolor',cmap(iZ,:),'markeredgecolor',cmap(iZ,:))
        ph(iZ)=plot(predX,predY,'-','color',cmap(iZ,:),'linewidth',1);
    end
    predY = double(predX<nanmean(threshOverCNO(:,1)));
    predY(predX==nanmean(threshOverCNO(:,1))) = 0.5;
    ph(5)=plot(predX,predY,'-b','linewidth',2);
    legend(ph,{'Cherry' 'Banana' 'Plain white' 'Chocolate' 'Overall'})
    hold off
    fn = CNO.fn;
    SSN = cell(length(fn),1);
    for iF=1:length(fn)
        fd = fileparts(fn{iF});
        delim = regexpi(fd,'\');
        SSN{iF} = fd(max(delim)+1:end);
    end
    set(gca,'ylim',[-0.05 1.05])
    set(gca,'ytick',[0 1])
    set(gca,'yticklabel',{'skip' 'stay'})
    xlabel('Delay (secs)')
    title(sprintf('%s -- %s\nCNO',SSN{1},SSN{end}))
    saveas(gcf,sprintf('%s--%s-CNO-meanChoices.fig',SSN{1},SSN{end}),'fig')
    saveas(gcf,sprintf('%s--%s-CNO-meanChoices.eps',SSN{1},SSN{end}),'epsc')
    
    
    popdir;
end


% Figure 1: bar graph for each rat.
figure;
set(gca,'fontsize',16)
set(gca,'fontname','Arial')
x = 1:length(RatNames);
y = [nanmean(RMSDbyRat.VEH,2) nanmean(RMSDbyRat.CNO,2)];
s = [nanstderr(RMSDbyRat.VEH') nanstderr(RMSDbyRat.CNO')];
[bh,eh,ch]=barerrorbar(x,y,s);
set(eh,'color','k')
set(ch,'linewidth',2)
set(eh,'linewidth',2)
set(gca,'xtick',x)
set(gca,'xticklabel',RatNames)
legendStr = {'Vehicle' 'CNO'};
legend(ch,legendStr)
xlabel('Rat number')
ylabel(sprintf('Degree of flavour preference\n(RMSD, flavour from overall \\pm SEM)'))
set(gca,'box','off')
saveas(gcf,sprintf('SummaryFlavourPref_rats.fig'),'fig')
saveas(gcf,sprintf('SummaryFlavourPref_rats.eps'),'epsc')

% Figure 2: overall effect of CNO of flavour preference.
figure;
set(gca,'fontsize',16)
set(gca,'fontname','Arial')
d = y(:,2)-y(:,1);
boxplot(d);
hold on
plot(1,d,'ko','markerfacecolor','k')
hold off
ylabel(sprintf('\\Delta flavour preference\n(mean CNO-mean Vehicle)'))
removeBoxplotXtick(gcf)
set(gca,'xcolor','w');
set(gca,'xtick',[]);
set(gca,'box','off')
saveas(gcf,sprintf('SummaryFlavourPref_acrossRats.fig'),'fig')
saveas(gcf,sprintf('SummaryFlavourPref_acrossRats.eps'),'epsc')