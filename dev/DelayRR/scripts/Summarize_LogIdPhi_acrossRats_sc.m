%% Summarize_LogIdPhi_acrossRats_sc:
%  Example script to summarize the effect of CNO on LogIdPhi across rats
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

%% LogIdPhi
ratPVTE = nan(length(AllRats),2);
ratVTECI = nan(length(AllRats),2,2);
for iRat = 1 : length(AllRats)
    VEH = AllRats(iRat).VEH;
    CNO = AllRats(iRat).CNO;
    LogIdPhiVeh = wrap_RR_summarizeLogIdPhi(VEH);
    LogIdPhiCNO = wrap_RR_summarizeLogIdPhi(CNO);
    [gmobjVehicle,gmobjCNO] = wrap_RR_summarizeGMMFit(LogIdPhiVeh,LogIdPhiCNO);
    ratPVTE(iRat,1) = gmobjVehicle.tau(end);
    ratPVTE(iRat,2) = gmobjCNO.tau(end);
    ratVTECI(iRat,1,1) = gmobjVehicle.tauCIlo(end);
    ratVTECI(iRat,2,1) = gmobjCNO.tauCIlo(end);
    ratVTECI(iRat,1,2) = gmobjVehicle.tauCIhi(end);
    ratVTECI(iRat,2,2) = gmobjCNO.tauCIhi(end);
    
    gmobjVehicle = gmobjVehicle.gmobj;
    gmobjCNO = gmobjCNO.gmobj;
    
    figure;
    subplot(2,1,1)
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    set(gca,'box','off')
    [f,bin] = hist(LogIdPhiVeh,linspace(0,4,100));
    bh=bar(bin,f/sum(f),1);
    set(bh,'facecolor','b')
    set(get(bh,'children'),'facealpha',0.3)
    hold on
    ph=gmmplot(gmobjVehicle,bin);
    set(ph,'linewidth',2)
    hold off
    set(gca,'xlim',[0 4])
    xlabel(sprintf('Log_{10}[Id\\phi]'))
    ylabel('Proportion of laps')
    title(sprintf('%s,\nVehicle',ratlist{iRat}))
    
    subplot(2,1,2)
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    set(gca,'box','off')
    [f,bin] = hist(LogIdPhiCNO,linspace(0,4,100));
    bh=bar(bin,f/sum(f),1);
    set(bh,'facecolor','r')
    set(get(bh,'children'),'facealpha',0.3)
    title(sprintf('%s,\nVehicle',ratlist{iRat}))
    hold on
    ph=gmmplot(gmobjCNO,bin);
    set(ph,'linewidth',2)
    hold off
    set(gca,'xlim',[0 4])
    xlabel(sprintf('Log_{10}[Id\\phi]'))
    ylabel('Proportion of laps')
    title(sprintf('%s,\nCNO',ratlist{iRat}))
    saveas(gcf,[ratlist{iRat} '-LogIdPhi_histogram_at_Drug.fig'],'fig')
    saveas(gcf,[ratlist{iRat} '-LogIdPhi_histogram_at_Drug.eps'],'epsc')
end
figure
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
set(gca,'box','off')
hold on
[bh,eh,ch]=barerrorbar(1:size(ratPVTE,1),ratPVTE,ratPVTE-ratVTECI(:,:,1),ratVTECI(:,:,2)-ratPVTE);
set(eh,'color','k')
set(eh,'linewidth',1)
set(eh,'linestyle','none')
legend(ch,{'Vehicle' 'CNO'})
set(gca,'xticklabel',ratlist)
ylabel(sprintf('P[VTE]\n(high-mean coefficient \\pm 95%% bootstrap CI)'))
hold off
saveas(gcf,'AllRats-pVTE_at_Drug.fig','fig')
saveas(gcf,'AllRats-pVTE_at_Drug.eps','epsc')

figure
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
set(gca,'box','off')
hold on
boxplot(ratPVTE(:,2)-ratPVTE(:,1))
removeBoxplotXtick(gcf)
plot(ones(size(ratPVTE,1),1),ratPVTE(:,2)-ratPVTE(:,1),'ko','markerfacecolor','k','markersize',8)
set(gca,'xcolor','w')
set(gca,'xtick',[])
ylabel(sprintf('P[VTE]\n(high-mean coefficient \\pm 95%% bootstrap CI)'))
hold off
saveas(gcf,'AllRats-pVTE_vs_Drug.fig','fig')
saveas(gcf,'AllRats-pVTE_vs_Drug.eps','epsc')
