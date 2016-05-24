%% Summarize_LnIdPhi_acrossRats_sc:
%  Example script to summarize the effect of CNO on P[LnIdPhi>4.5] across rats
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
VTEthresh = [5.0;
             5.0;
             5.0;
             5.0];

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

%% P[LnIdPhi>thresh]
mVTEacrossRats = nan(length(AllRats),2);
sVTEacrossRats = nan(length(AllRats),2);
pStat = nan(length(AllRats),1);
for iRat = 1 : length(AllRats)
    VEH = AllRats(iRat).VEH;
    CNO = AllRats(iRat).CNO;
    
    pVTEveh = nan(length(VEH),4);
    LnIdPhiListVeh = [];
    for iSess = 1 : length(VEH)
        sd = VEH(iSess).sd;
        VTE = nan(length(sd),length(sd(1).LogIdPhi));
        for iSubsess = 1 : length(sd)
            LnIdPhiVeh = log(10.^sd(iSubsess).LogIdPhi);
            LnIdPhiVeh(LnIdPhiVeh<=1) = nan;
            LnIdPhiListVeh = cat(1,LnIdPhiListVeh,LnIdPhiVeh(:));
            idnan = isnan(LnIdPhiVeh);
            VTE(iSubsess,~idnan) = LnIdPhiVeh(~idnan)>VTEthresh(iRat);
        end
        VTE = VTE(:);
        idnan = isnan(VTE);
        pVTEveh(iSess) = nansum(double(VTE(~idnan)==1))./nansum(double(VTE(~idnan)==0)+double(VTE(~idnan)==1));
    end
    pVTEcno = nan(length(CNO),4);
    LnIdPhiListCNO = [];
    for iSess = 1 : length(CNO)
        sd = CNO(iSess).sd;
        VTE = nan(length(sd),length(sd(1).LogIdPhi));
        for iSubsess = 1 : length(sd)
            LnIdPhiCNO = log(10.^sd(iSubsess).LogIdPhi);
            LnIdPhiCNO(LnIdPhiCNO<=1) = nan;
            LnIdPhiListCNO = cat(1,LnIdPhiListCNO,LnIdPhiCNO(:));
            idnan = isnan(LnIdPhiCNO);
            VTE(iSubsess,~idnan) = LnIdPhiCNO(~idnan)>VTEthresh(iRat);
        end
        VTE = VTE(:);
        idnan = isnan(VTE);
        pVTEcno(iSess) = nansum(double(VTE(~idnan)==1))./nansum(double(VTE(~idnan)==0)+double(VTE(~idnan)==1));
    end
    
    mVTEacrossRats(iRat,1) = nanmean(pVTEveh(:));
    mVTEacrossRats(iRat,2) = nanmean(pVTEcno(:));
    sVTEacrossRats(iRat,1) = nanstderr(pVTEveh(:));
    sVTEacrossRats(iRat,2) = nanstderr(pVTEcno(:));
    figure;
    subplot(2,1,1)
    [f,bin]=hist(LnIdPhiListVeh,linspace(2,8,100));
    bh=bar(bin,f/sum(f));
    ch=get(bh,'children');
    set(bh,'facecolor','b')
    set(ch,'facealpha',0.3)
    hold on
    plot([VTEthresh(iRat) VTEthresh(iRat)],[0 1],'k-','linewidth',2)
    hold off
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    set(gca,'box','off')
    title(sprintf('%s\nVehicle',ratlist{iRat}))
    xlabel(sprintf('Ln[Id\\phi]'));
    ylabel(sprintf('Proportion of all laps'))
    set(gca,'ylim',[0 0.1])
    
    subplot(2,1,2)
    [f,bin]=hist(LnIdPhiListCNO,linspace(2,8,100));
    bh=bar(bin,f/sum(f));
    ch=get(bh,'children');
    set(bh,'facecolor','r')
    set(ch,'facealpha',0.3)
    hold on
    plot([VTEthresh(iRat) VTEthresh(iRat)],[0 1],'k-','linewidth',2)
    hold off
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    set(gca,'box','off')
    title(sprintf('%s\nCNO',ratlist{iRat}))
    xlabel(sprintf('Ln[Id\\phi]'));
    ylabel(sprintf('Proportion of all laps'))
    set(gca,'ylim',[0 0.1])
    saveas(gcf,[ratlist{iRat} '-pLnIdPhiThresh_at_Drug.fig'],'fig')
    saveas(gcf,[ratlist{iRat} '-pLnIdPhiThresh_at_Drug.eps'],'epsc')
    
    figure;
    [fVeh,binVeh]=hist(LnIdPhiListVeh,linspace(2,8,100));
    [fCNO,binCNO]=hist(LnIdPhiListCNO,linspace(2,8,100));
    ph = nan(2,1);
    hold on
    ph(1)=plot(binVeh,fVeh/sum(fVeh),'b-','linewidth',2);
    ph(2)=plot(binCNO,fCNO/sum(fCNO),'r-','linewidth',2);
    plot([VTEthresh(iRat) VTEthresh(iRat)],[0 1],'k-','linewidth',2)
    hold off
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    set(gca,'box','off')
    title(sprintf('%s\nVehicle',ratlist{iRat}))
    xlabel(sprintf('Ln[Id\\phi]'));
    ylabel(sprintf('Proportion of all laps'))
    legend(ph,{'Vehicle' 'CNO'});
    set(gca,'ylim',[0 0.1])
    saveas(gcf,[ratlist{iRat} '-pLnIdPhiThresh_at_Drug_lines.fig'],'fig')
    saveas(gcf,[ratlist{iRat} '-pLnIdPhiThresh_at_Drug_lines.eps'],'epsc')
    
    figure;
    hold on
    [fVeh,binVeh,loVeh,upVeh]=ecdf(LnIdPhiListVeh,'function','survivor');
    [fCNO,binCNO,loCNO,upCNO]=ecdf(LnIdPhiListCNO,'function','survivor');
    eh=errorbar(binVeh,fVeh,fVeh-loVeh,upVeh-fVeh);
    set(eh,'linestyle','none','linewidth',0.5,'color','c')
    eh=errorbar(binCNO,fCNO,fCNO-loCNO,upCNO-fCNO);
    set(eh,'linestyle','none','linewidth',0.5,'color','m')
    sh=nan(2,1);
    sh(1)=stairs(binVeh,fVeh,'b-','linewidth',3);
    sh(2)=stairs(binCNO,fCNO,'r-','linewidth',3);
    hold off
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    set(gca,'box','off')
    xlabel(sprintf('Ln[Id\\phi]'))
    ylabel(sprintf('Surviving proportion of trials\n(\\pm 95%% confidence interval)'))
    legend(sh,{'Vehicle' 'CNO'})
    title(ratlist{iRat})
    saveas(gcf,[ratlist{iRat} '-pLnIdPhi_ECDF_at_Drug.fig'],'fig')
    saveas(gcf,[ratlist{iRat} '-pLnIdPhi_ECDF_at_Drug.eps'],'epsc')
    
    pStat(iRat) = kruskalwallis([LnIdPhiListVeh;LnIdPhiListCNO],[zeros(length(LnIdPhiListVeh),1);ones(length(LnIdPhiListCNO),1)],'off');
end

figure;
[bh,eh,ch]=barerrorbar(1:length(ratlist),mVTEacrossRats,sVTEacrossRats);
set(gca,'xtick',1:length(ratlist))
set(gca,'xticklabel',ratlist)
set(gca,'ylim',[0.025 .325])
set(gca,'ytick',[0.05:0.05:0.3]);
hold on
for iRat=1:length(pStat)
    if pStat(iRat)<0.05
        plot(iRat,max(get(gca,'ylim')),'k*','markersize',12)
    end
end
hold off
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
set(gca,'box','off')
ylabel(sprintf('P[Ln[Id\\phi]>threshold]\n(mean across sessions \\pm SEM)'))
saveas(gcf,'AllRats-pLnIdPhiThresh_at_Drug.fig','fig')
saveas(gcf,'AllRats-pLnIdPhiThresh_at_Drug.eps','epsc')

figure
boxplot(mVTEacrossRats(:,2)-mVTEacrossRats(:,1));
removeBoxplotXtick(gcf)
h = ttest(mVTEacrossRats(:,2)-mVTEacrossRats(:,1));

hold on
plot(ones(size(mVTEacrossRats,1),1),mVTEacrossRats(:,2)-mVTEacrossRats(:,1),'ko','markerfacecolor','k','markersize',8);
if h
    plot(1,max(get(gca,'ylim')),'k*','markersize',12)
end
hold off
set(gca,'ylim',[-0.07 0.07])
set(gca,'xcolor','w')
set(gca,'xtick',[])
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
set(gca,'box','off')
ylabel(sprintf('\\DeltaP[Ln[Id\\phi]>threshold]\n(CNO - Vehicle)'))
saveas(gcf,'AllRats-Delta_pLnIdPhiThresh_acrossRats.fig','fig')
saveas(gcf,'AllRats-Delta_pLnIdPhiThresh_acrossRats.eps','epsc')