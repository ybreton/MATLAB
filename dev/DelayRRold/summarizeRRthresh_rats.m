function ThreshbyRat = summarizeRRthresh_rats(VehCNOlist,RatNames,varargin)
% summarizes restaurant row threshold data across rats.
% ThreshbyRat = summarizeRRthresh_rats(VehCNOlist,RatNames)
% where     ThreshbyRat          is a structure with fields
%                    .VEH,
%                    .CNO
%                              each are nRats x nSess x 4 matrices of
%                                   thresholds for each rat on each session
%                                   for each zone.
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
% ThreshbyRat = summarizeRRthresh_rats(VehCNOlist,RatNames)
%

maxSess = 28;
nPellets = 2;
process_varargin(varargin);

ThreshbyRat.VEH = nan(size(VehCNOlist,1),maxSess,4);
ThreshbyRat.CNO = nan(size(VehCNOlist,1),maxSess,4);
overallVeh = nan(size(VehCNOlist,1),maxSess);
overallCNO = nan(size(VehCNOlist,1),maxSess);
sessionNumbers.VEH = nan(size(VehCNOlist,1),maxSess);
sessionNumbers.CNO = nan(size(VehCNOlist,1),maxSess);
nIncl.VEH = nan(size(VehCNOlist,1),1);
nIncl.CNO = nan(size(VehCNOlist,1),1);
for iRat = 1 : size(VehCNOlist,1)
    fd = fileparts(VehCNOlist{iRat,1});
    
    
    pushdir(fd);
    load(VehCNOlist{iRat,1});
    load(VehCNOlist{iRat,2});
    
    thresholdsVeh = VEH.thresholds(:,:,nPellets);
    thresholdsCNO = CNO.thresholds(:,:,nPellets);
    fnList = cell(length(VEH.fn),1);
    for iF=1:length(VEH.fn)
        fd0 = fileparts(VEH.fn{iF});
        delim = regexpi(fd0,'\');
        fnList{iF} = fd0(max(delim)+1:end);
    end
    fns{iRat,1} = fnList(:);
    fnList = cell(length(CNO.fn),1);
    for iF=1:length(CNO.fn)
        fd0 = fileparts(CNO.fn{iF});
        delim = regexpi(fd0,'\');
        fnList{iF} = fd0(max(delim)+1:end);
    end
    fns{iRat,2} = fnList(:);
    
    ThreshbyRat.VEH(iRat,1:size(thresholdsVeh,1),:) = reshape(thresholdsVeh,[1 size(thresholdsVeh,1) size(thresholdsVeh,2)]);
    ThreshbyRat.CNO(iRat,1:size(thresholdsCNO,1),:) = reshape(thresholdsCNO,[1 size(thresholdsCNO,1) size(thresholdsCNO,2)]);
    nIncl.VEH(iRat) = size(thresholdsVeh,1);
    nIncl.CNO(iRat) = size(thresholdsCNO,1);
    overallVeh(iRat,1:length(VEH.marginalZonebyPellet(:,:,nPellets))) = VEH.marginalZonebyPellet(:,:,nPellets);
    overallCNO(iRat,1:length(CNO.marginalZonebyPellet(:,:,nPellets))) = CNO.marginalZonebyPellet(:,:,nPellets);
    popdir;
end

% Figure: for each zone, VEH and CNO session thresholds for each rat.
cmap = lines(size(ThreshbyRat.VEH,1));
flavours = {'Cherry' 'Banana' 'Plain White' 'Chocolate'};
for iZ=1:4
    figure;
    ph1 = nan(size(ThreshbyRat.VEH,1),1);
    ph2 = nan(size(ThreshbyRat.CNO,1),1);
    legendStr = cell(size(ThreshbyRat.VEH,1),2);
    for iRat=1:size(ThreshbyRat.VEH,1)
        fs = cat(1,fns{iRat,1},fns{iRat,2});
        [~,sessNums]=sort(fs);
        nVeh = nIncl.VEH(iRat);
        nCNO = nIncl.CNO(iRat);
        
        vehSess = sessNums(1:nVeh);
        cnoSess = sessNums(nVeh+1:end);
        
        yVeh = ThreshbyRat.VEH(iRat,1:nVeh,iZ);
        yCNO = ThreshbyRat.CNO(iRat,1:nCNO,iZ);
        
        subplot(2,1,1)
        set(gca,'fontname','Arial')
        set(gca,'fontsize',18)
        hold on
        title(sprintf('%s\n%d pellets',flavours{iZ},nPellets));
        [x,idSort] = sort(vehSess);
        ph1(iRat)=plot(x,yVeh(idSort),'o-','color',cmap(iRat,:),'markerfacecolor',cmap(iRat,:));
        legendStr{iRat,1} = sprintf('%s, Vehicle',RatNames{iRat});
        xlabel('Session number')
        ylabel(sprintf('Threshold delay \n(secs)'))
        hold off
        
        subplot(2,1,2)
        set(gca,'fontname','Arial')
        set(gca,'fontsize',18)
        hold on
        [x,idSort] = sort(cnoSess);
        ph2(iRat)=plot(x,yCNO(idSort),'s-','color',cmap(iRat,:),'markerfacecolor',cmap(iRat,:));
        legendStr{iRat,1} = sprintf('%s, Vehicle',RatNames{iRat});
        legendStr{iRat,2} = sprintf('%s, CNO',RatNames{iRat});
        xlabel('Session number')
        ylabel(sprintf('Threshold delay \n(secs)'))
        hold off
    end
    subplot(2,1,1)
    hold on
    lh=legend(ph1,legendStr(:,1));
    set(lh,'location','northeastoutside')
    hold off
    subplot(2,1,2)
    hold on
    lh=legend(ph2,legendStr(:,2));
    set(lh,'location','northeastoutside')
    hold off
end

figure;
ph1 = nan(size(overallVeh,1),1);
ph2 = nan(size(overallCNO,1),1);
legendStr = cell(size(overallVeh,1),2);
for iRat=1:size(overallVeh,1)
    fs = cat(1,fns{iRat,1},fns{iRat,2});
    [~,sessNums]=sort(fs);
    nVeh = nIncl.VEH(iRat);
    nCNO = nIncl.CNO(iRat);

    vehSess = sessNums(1:nVeh);
    cnoSess = sessNums(nVeh+1:end);

    yVeh = overallVeh(iRat,1:nVeh);
    yCNO = overallCNO(iRat,1:nCNO);

    subplot(2,1,1)
    set(gca,'fontname','Arial')
    set(gca,'fontsize',18)
    hold on
    title(sprintf('Overall\n%d pellets',nPellets));
    [x,idSort] = sort(vehSess);
    ph1(iRat)=plot(x,yVeh(idSort),'o-','color',cmap(iRat,:),'markerfacecolor',cmap(iRat,:));
    legendStr{iRat,1} = sprintf('%s, Vehicle',RatNames{iRat});
    xlabel('Session number')
    ylabel(sprintf('Threshold delay \n(secs)'))
    hold off

    subplot(2,1,2)
    set(gca,'fontname','Arial')
    set(gca,'fontsize',18)
    hold on
    [x,idSort] = sort(cnoSess);
    ph2(iRat)=plot(x,yCNO(idSort),'s-','color',cmap(iRat,:),'markerfacecolor',cmap(iRat,:));
    legendStr{iRat,1} = sprintf('%s, Vehicle',RatNames{iRat});
    legendStr{iRat,2} = sprintf('%s, CNO',RatNames{iRat});
    xlabel('Session number')
    ylabel(sprintf('Threshold delay \n(secs)'))
    hold off
end
subplot(2,1,1)
hold on
lh=legend(ph1,legendStr(:,1));
set(lh,'location','northeastoutside')
hold off
subplot(2,1,2)
hold on
lh=legend(ph2,legendStr(:,2));
set(lh,'location','northeastoutside')
hold off

x = 1:length(RatNames);
legendStr = {'Vehicle' 'CNO'};
% Figure: for each zone, mean threshold for each rat under Vehicle and CNO.
theta = nan(length(RatNames),2,4);
flavours = {'Cherry' 'Banana' 'Plain White' 'Chocolate'};
for iZ = 1 : 4
    figure;
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    
    y = [nanmean(ThreshbyRat.VEH(:,:,iZ),2) nanmean(ThreshbyRat.CNO(:,:,iZ),2)];
    s = [nanstderr(ThreshbyRat.VEH(:,:,iZ)') nanstderr(ThreshbyRat.CNO(:,:,iZ)')];
    theta(:,:,iZ) = y;
    [bh,eh,ch]=barerrorbar(x,y,s);
    set(eh,'color','k')
    set(ch,'linewidth',2)
    set(eh,'linewidth',2)
    set(gca,'xtick',x)
    set(gca,'xticklabel',RatNames)
    legend(ch,legendStr)
    xlabel('Rat number')
    ylabel(sprintf('Threshold\n(mean secs \\pm SEM)'))
    title(sprintf('%s',flavours{iZ}))
    set(gca,'box','off')
    saveas(gcf,sprintf('SummaryThresh_zone%d_rats.fig',iZ),'fig')
    saveas(gcf,sprintf('SummaryThresh_zone%d_rats.eps',iZ),'epsc')
end

% Figure: overall threshold change
figure;
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
y = [nanmean(overallVeh,2) nanmean(overallCNO,2)];
s = [nanstderr(overallVeh') nanstderr(overallCNO')];
[bh,eh,ch]=barerrorbar(x,y,s);
set(eh,'color','k')
set(ch,'linewidth',2)
set(eh,'linewidth',2)
set(gca,'xtick',x)
set(gca,'xticklabel',RatNames)
legend(ch,legendStr)
xlabel('Rat number')
ylabel(sprintf('Threshold\n(mean secs \\pm SEM)'))
title('Overall')
set(gca,'box','off')
saveas(gcf,sprintf('SummaryThresh_overall_rats.fig',iZ),'fig')
saveas(gcf,sprintf('SummaryThresh_overall_rats.eps',iZ),'epsc')

% Figure: for each zone, mean difference in threshold between Vehicle and
% CNO across rats.

figure;
set(gca,'fontsize',16)
set(gca,'fontname','Arial')
d = squeeze(theta(:,2,:)-theta(:,1,:));
boxplot(d);
hold on
plot(repmat([1 2 3 4],size(d,1),1),d,'ko','markerfacecolor','k')
hold off
set(gca,'xtick',1:4)
set(gca,'xticklabel',{'Cherry' 'Banana' 'Plain' 'Chocolate'})
xlabel('Zone')
ylabel(sprintf('\\Delta threshold\n(CNO - Vehicle)'));
set(gca,'box','off')
saveas(gcf,sprintf('SummaryThresh_byZone_acrossRats.fig'),'fig')
saveas(gcf,sprintf('SummaryThresh_byZone_acrossRats.eps'),'epsc')

% Figure: overall, mean difference in threshold.

figure;
set(gca,'fontsize',16)
set(gca,'fontname','Arial')
d = nanmean(overallVeh,2)-nanmean(overallCNO,2);
boxplot(d);
hold on
plot(ones(length(d(:)),1),d(:),'ko','markerfacecolor','k')
hold off
ylabel(sprintf('\\Delta overall threshold\n(CNO - Vehicle)'));
removeBoxplotXtick(gcf)
set(gca,'xcolor','w');
set(gca,'xtick',[]);
set(gca,'box','off')
saveas(gcf,sprintf('SummaryThresh_overall_acrossRats.fig'),'fig')
saveas(gcf,sprintf('SummaryThresh_overall_acrossRats.eps'),'epsc')