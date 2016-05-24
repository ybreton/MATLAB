function VTEbyRat = summarizeRRvte_rats(VehCNOlist,RatNames,varargin)
% summarizes restaurant row VTE data across rats.
% VTEbyRat = summarizeRRvte_rats(VehCNOlist,RatNames)
% where     ThreshbyRat          is a structure with fields
%                    .VEH,
%                    .CNO
%                              each are nRats x nSess x nTrials matrices of
%                                   LogIdPhi's for each rat on each session
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
% VTEbyRat = summarizeRRvte_rats(VehCNOlist,RatNames)
%

maxSess = 28;
maxTrls = 200*4;
nPellets = 2;
k=3;
process_varargin(varargin);

VTEbyRat.VEH = nan(size(VehCNOlist,1),maxSess,maxTrls);
VTEbyRat.CNO = nan(size(VehCNOlist,1),maxSess,maxTrls);
LogIdPhiVeh = nan(size(VehCNOlist,1),maxSess);
LogIdPhiCNO = nan(size(VehCNOlist,1),maxSess);
legendStr = {'Vehicle' 'CNO'};
for iRat = 1 : size(VehCNOlist,1)
    fd = fileparts(VehCNOlist{iRat,1});
    
    
    pushdir(fd);
    disp(fd);
    load(VehCNOlist{iRat,1});
    load(VehCNOlist{iRat,2});
    IdPhiVeh = reshape(VEH.IdPhi,[1 size(VEH.IdPhi,1) size(VEH.IdPhi,2)]);
    IdPhiVeh(IdPhiVeh<=0) = nan;
    VTEbyRat.VEH(iRat,1:size(VEH.IdPhi,1),1:size(VEH.IdPhi,2)) = log10(IdPhiVeh);
    IdPhiCNO=reshape(CNO.IdPhi,[1 size(CNO.IdPhi,1) size(CNO.IdPhi,2)]);
    IdPhiCNO(IdPhiCNO<=0) = nan;
    VTEbyRat.CNO(iRat,1:size(CNO.IdPhi,1),1:size(CNO.IdPhi,2)) = log10(IdPhiCNO);
    x0 = VTEbyRat.VEH(iRat,:);
    x1 = VTEbyRat.CNO(iRat,:);
    x0 = x0(:);
    x1 = x1(:);
    idnan = isnan(x0)|isinf(x0);
    x0 = x0(~idnan);
    idnan = isnan(x1)|isinf(x1);
    x1 = x1(~idnan);
    
    
    [f0,bin] = hist(x0,linspace(0,3,100));
    [f1,bin] = hist(x1,linspace(0,3,100));
    
    figure;
    subplot(2,1,1)
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    bh=bar(bin(:),f0(:)/sum(f0),1);
    ch=get(bh,'children');
    set(ch,'facecolor',[0 0 1])
    lh=legend(ch,'Vehicle');
    set(lh,'location','northwest')
    xlabel(sprintf('Log_{10}[Id\\phi]'))
    ylabel('Proportion of laps')
    set(gca,'xlim',[0 4])
    fdFirst = fileparts(VEH.fn{1});
    fdLast = fileparts(VEH.fn{end});
    delim = regexpi(fdFirst,'\');
    SSNfirst = fdFirst(max(delim)+1:end);
    delim = regexpi(fdLast,'\');
    SSNlast = fdLast(max(delim)+1:end);
    title(sprintf('%s -- %s',SSNfirst,SSNlast));
    set(gca,'box','off')
    
    subplot(2,1,2)
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    bh=bar(bin(:),f1(:)/sum(f1),1);
    ch=get(bh,'children');
    set(ch,'facecolor',[1 0 0])
    lh=legend(ch,'CNO');
    set(lh,'location','northwest')
    xlabel(sprintf('Log_{10}[Id\\phi]'))
    ylabel('Proportion of laps')
    set(gca,'xlim',[0 4])
    fdFirst = fileparts(CNO.fn{1});
    fdLast = fileparts(CNO.fn{end});
    delim = regexpi(fdFirst,'\');
    SSNfirst = fdFirst(max(delim)+1:end);
    delim = regexpi(fdLast,'\');
    SSNlast = fdLast(max(delim)+1:end);
    title(sprintf('%s -- %s',SSNfirst,SSNlast));
    set(gca,'box','off')
    saveas(gcf,[RatNames{iRat} '-LogIdPhiHistogram.fig'],'fig')
    saveas(gcf,[RatNames{iRat} '-LogIdPhiHistogram.eps'],'epsc')
    
    figure;
    [f0,bin0,f0lo,f0up]=ecdf(x0);
    [f1,bin1,f1lo,f1up]=ecdf(x1);
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    hold on
    ph=stairs(bin0,f0,'-b','linewidth',2);
    ph(2)=stairs(bin0,f0lo,':b','linewidth',1);
    stairs(bin0,f0up,':b','linewidth',1)
    
    ph(3)=stairs(bin1,f1,'-r','linewidth',2);
    ph(4)=stairs(bin1,f1lo,':r','linewidth',1);
    stairs(bin1,f1up,':r','linewidth',1)
    lh=legend(ph,{'Vehicle CDF' 'Vehicle 95% CI' 'CNO CDF' 'CNO 95% CI'});
    set(lh,'location','southeast')
    xlabel(sprintf('Log_{10}[Id\\phi]'))
    ylabel(sprintf('Cumulative proportion of laps'))
    set(gca,'xlim',[0 4])
    fn = sort(cat(1,VEH.fn,CNO.fn));
    fdFirst = fileparts(fn{1});
    fdLast = fileparts(fn{end});
    delim = regexpi(fdFirst,'\');
    SSNfirst = fdFirst(max(delim)+1:end);
    delim = regexpi(fdLast,'\');
    SSNlast = fdLast(max(delim)+1:end);
    title(sprintf('%s -- %s',SSNfirst,SSNlast));
    set(gca,'box','off')
    saveas(gcf,[RatNames{iRat} '-LogIdPhiECDF.fig'],'fig')
    saveas(gcf,[RatNames{iRat} '-LogIdPhiECDF.eps'],'epsc')
    popdir;
    
    LogIdPhiVeh(iRat,:) = nanmean(VTEbyRat.VEH(iRat,:,:),3);
    LogIdPhiCNO(iRat,:) = nanmean(VTEbyRat.CNO(iRat,:,:),3);
end

% Figure: LogIdPhi for each rat, Vehicle and CNO
x = 1:length(RatNames);
y = [nanmedian(LogIdPhiVeh,2) nanmedian(LogIdPhiCNO,2)];
% s = [nanstderr(LogIdPhiVeh') nanstderr(LogIdPhiCNO')];
l = [prctile(LogIdPhiVeh,25,2) prctile(LogIdPhiCNO,25,2)];
u = [prctile(LogIdPhiVeh,75,2) prctile(LogIdPhiCNO,75,2)];
figure;
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
[bh,eh,ch]=barerrorbar(x,y,y-l,u-y);
set(eh,'color','k')
set(ch,'linewidth',2)
set(eh,'linewidth',2)
set(gca,'xtick',x)
set(gca,'xticklabel',RatNames)
set(gca,'ylim',[1.6 2.1])
set(gca,'ytick',[1.6:0.1:2.0])
legend(ch,legendStr)
xlabel('Rat number')
ylabel(sprintf('Log_{10}[Id\\phi]\n(median of session means\\pm inter-quartile range)'))
set(gca,'box','off')
saveas(gcf,['SummaryLogIdPhi_rats.fig'],'fig')
saveas(gcf,['SummaryLogIdPhi_rats.eps'],'epsc')

% Figure: diff in LogIdPhi across rats
figure;
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
d = nanmedian(LogIdPhiCNO,2)-nanmedian(LogIdPhiVeh,2);
boxplot(d)
hold on
plot(ones(length(d),1),d,'ko','markerfacecolor','k');
hold off
ylabel(sprintf('\\Delta Log_{10}[Id\\phi]\n(median CNO - median Vehicle)'));
removeBoxplotXtick(gcf)
set(gca,'xcolor','w');
set(gca,'xtick',[]);
set(gca,'box','off')
saveas(gcf,['SummaryLogIdPhi_acrossRats.fig'],'fig')
saveas(gcf,['SummaryLogIdPhi_acrossRats.eps'],'epsc')