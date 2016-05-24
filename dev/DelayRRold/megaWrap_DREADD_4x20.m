function megaWrap_DREADD_4x20(ratname,experimentDir,VehicleStr,CNOStr)


pushdir([pwd '\' ratname]);
pushdir([pwd '\' experimentDir]);
curDir = pwd;
disp(curDir);

%% Produce RR structures.
CNO = wrap_RR_analysis(CNOStr);
VEH = wrap_RR_analysis(VehicleStr);

%% Plot session-by-session choices.

% Vehicle
for iSess = 1 : length(VEH.fn)
    fd=fileparts(VEH.fn{iSess});
    delim = regexpi(fd,'\');
    SSN = fd(max(delim)+1:end);
    
    pushdir(fd);
    RRplotSessionChoices(VEH,1,iSess);
    RRplotSessionChoices(VEH,3,iSess);
    close all
    
    fh=figure;
    set(gca,'fontsize',18);
    set(gca,'fontname','Arial');
    nPellets = VEH.pellets(iSess,:)==1;
    plot(VEH.delays(iSess,nPellets),VEH.staygo(iSess,nPellets)+randn(1,length(VEH.staygo(iSess,nPellets)))/100,'b.');
    hold on; 
    plot(1:30,1:30<=VEH.marginalZonebyPellet(iSess,1,1));
    hold off
    set(gca,'ylim',[-0.05 1.05]);set(gca,'ytick',[0:0.1:1])
    set(gca,'xlim',[0 30]);set(gca,'xtick',[0:5:30]);
    xlabel('Delay (secs)')
    ylabel('P[Stay]')
    title(sprintf('%s\nOverall',SSN))
    set(gca,'box','off')
    
    saveas(fh,[SSN sprintf('-nPellets%d-Overall-Choices.fig',1)],'fig')
    saveas(fh,[SSN sprintf('-nPellets%d-Overall-Choices.eps',1)],'epsc')
    close all
    
    fh=figure;
    set(gca,'fontsize',18);
    set(gca,'fontname','Arial');
    nPellets = VEH.pellets(iSess,:)==3;
    plot(VEH.delays(iSess,nPellets),VEH.staygo(iSess,nPellets)+randn(1,length(VEH.staygo(iSess,nPellets)))/100,'b.');
    hold on; 
    plot(1:30,1:30<=VEH.marginalZonebyPellet(iSess,1,3));
    hold off
    set(gca,'ylim',[-0.05 1.05]);set(gca,'ytick',[0:0.1:1])
    set(gca,'xlim',[0 30]);set(gca,'xtick',[0:5:30]);
    xlabel('Delay (secs)')
    ylabel('P[Stay]')
    title(sprintf('%s\nOverall',SSN))
    set(gca,'box','off')
    
    saveas(fh,[SSN sprintf('-nPellets%d-Overall-Choices.fig',3)],'fig')
    saveas(fh,[SSN sprintf('-nPellets%d-Overall-Choices.eps',3)],'epsc')
    close all
    
    popdir;
end
RRplotSessionChoices(VEH,1,[]);
RRplotSessionChoices(VEH,3,[]);
close all

% CNO
for iSess = 1 : length(CNO.fn)
    fd=fileparts(CNO.fn{iSess});
    delim = regexpi(fd,'\');
    SSN = fd(max(delim)+1:end);
    
    pushdir(fd);
    
    RRplotSessionChoices(CNO,1,iSess);
    RRplotSessionChoices(CNO,3,iSess);
    close all
    
    fh=figure;
    set(gca,'fontsize',18);
    set(gca,'fontname','Arial');
    nPellets = CNO.pellets(iSess,:)==1;
    plot(CNO.delays(iSess,nPellets),CNO.staygo(iSess,nPellets)+randn(1,length(CNO.staygo(iSess,nPellets)))/100,'b.');
    hold on; 
    plot(1:30,1:30<=CNO.marginalZonebyPellet(iSess,1,1));
    hold off
    set(gca,'ylim',[-0.05 1.05]);set(gca,'ytick',[0:0.1:1])
    set(gca,'xlim',[0 30]);set(gca,'xtick',[0:5:30]);
    xlabel('Delay (secs)')
    ylabel('P[Stay]')
    
    title(sprintf('%s\nOverall',SSN))
    set(gca,'box','off')
    
    saveas(fh,[SSN '-nPellets1-Overall-Choices.fig'],'fig')
    saveas(fh,[SSN '-nPellets1-Overall-Choices.eps'],'epsc')
    close all
    
    fh=figure;
    set(gca,'fontsize',18);
    set(gca,'fontname','Arial');
    nPellets = CNO.pellets(iSess,:)==3;
    plot(CNO.delays(iSess,nPellets),CNO.staygo(iSess,nPellets)+randn(1,length(CNO.staygo(iSess,nPellets)))/100,'b.');
    hold on; 
    plot(1:30,1:30<=CNO.marginalZonebyPellet(iSess,1,1));
    hold off
    set(gca,'ylim',[-0.05 1.05]);set(gca,'ytick',[0:0.1:1])
    set(gca,'xlim',[0 30]);set(gca,'xtick',[0:5:30]);
    xlabel('Delay (secs)')
    ylabel('P[Stay]')
    
    title(sprintf('%s\nOverall',SSN))
    set(gca,'box','off')
    
    saveas(fh,[SSN '-nPellets3-Overall-Choices.fig'],'fig')
    saveas(fh,[SSN '-nPellets3-Overall-Choices.eps'],'epsc')
    close all
    
    popdir
end
RRplotSessionChoices(CNO,1,[]);
RRplotSessionChoices(CNO,3,[]);

close all

%% Zone Entry Passes

[VEH.XatCP,VEH.YatCP,fh] = RRplotCPpasses(VEH.fn);
for iZ=1:4
    saveas(fh(iZ),sprintf('Vehicle-Zone%d-CP_passes.fig',iZ),'fig')
    saveas(fh(iZ),sprintf('Vehicle-Zone%d-CP_passes.eps',iZ),'epsc')
end
saveas(fh(5),'Vehicle-Overall-CP_passes.fig','fig')
saveas(fh(5),'Vehicle-Overall-CP_passes.eps','epsc')
close all
[CNO.XatCP,CNO.YatCP,fh] = RRplotCPpasses(CNO.fn);
for iZ=1:4
    saveas(fh(iZ),sprintf('CNO-Zone%d-CP_passes.fig',iZ),'fig')
    saveas(fh(iZ),sprintf('CNO-Zone%d-CP_passes.eps',iZ),'epsc')
end
saveas(fh(5),'CNO-Overall-CP_passes.fig','fig')
saveas(fh(5),'CNO-Overall-CP_passes.eps','epsc')
close all

%% Speed
CNO.Speed= RRGetVelocity(CNO.fn);
VEH.Speed = RRGetVelocity(VEH.fn);

%%
disp('Producing flavor preference plots.')
fh=wrap_RR_plotRMS(VEH,CNO,'plotAmount',true);
drawnow
saveas(fh(1),[ratname '-RMSD_flavor_vs_Drug.fig'],'fig')
saveas(fh(1),[ratname '-RMSD_flavor_vs_Drug.eps'],'epsc')
close all

%%
VEH = RRDecisionInstability(VEH);
CNO = RRDecisionInstability(CNO);

%% produce decision instability plots
fh=wrap_RR_plotPError(VEH,CNO,1);
saveas(fh(1),[ratname '-nPellets1-PError_vs_Drug_boxplot.fig'],'fig')
saveas(fh(1),[ratname '-nPellets1-PError_vs_Drug_boxplot.eps'],'epsc')
saveas(fh(2),[ratname '-nPellets1-PError_vs_Drug.fig'],'fig')
saveas(fh(2),[ratname '-nPellets1-PError_vs_Drug.eps'],'epsc')
close all

fh=wrap_RR_plotPError(VEH,CNO,3);
saveas(fh(1),[ratname '-nPellets3-PError_vs_Drug_boxplot.fig'],'fig')
saveas(fh(1),[ratname '-nPellets3-PError_vs_Drug_boxplot.eps'],'epsc')
saveas(fh(2),[ratname '-nPellets3-PError_vs_Drug.fig'],'fig')
saveas(fh(2),[ratname '-nPellets3-PError_vs_Drug.eps'],'epsc')
close all

%% produce overal skip plots
disp('Overall skipping.')
[VEH,fh]=wrap_RR_pSkip(VEH);
drawnow
saveas(fh(1),[ratname '-Vehicle-pSkip_vs_Zone_at_Pellets.fig'],'fig')
saveas(fh(1),[ratname '-Vehicle-pSkip_vs_Zone_at_Pellets.eps'],'epsc')
saveas(fh(2),[ratname '-Vehicle-pSkip_vs_Zone_or_Pellets.fig'],'fig')
saveas(fh(2),[ratname '-Vehicle-pSkip_vs_Zone_or_Pellets.eps'],'epsc')
[CNO,fh]=wrap_RR_pSkip(CNO);
drawnow
saveas(fh(1),[ratname '-Drug-pSkip_vs_Zone_at_Pellets.fig'],'fig')
saveas(fh(1),[ratname '-Drug-pSkip_vs_Zone_at_Pellets.eps'],'epsc')
saveas(fh(2),[ratname '-Drug-pSkip_vs_Zone_or_Pellets.fig'],'fig')
saveas(fh(2),[ratname '-Drug-pSkip_vs_Zone_or_Pellets.eps'],'epsc')
close all

%% produce 2D histogram of stay duration vs delay
disp('Producing stay duration histogram.')
fh = wrap_RR_stayDuration2DHist(VEH,'titleStr','Vehicle');
drawnow
fh2 = wrap_RR_stayDuration2DHist(CNO,'titleStr','CNO');
drawnow
saveas(fh,[ratname '-Vehicle-StayDuration_vs_Delay_2DHistogram.fig'],'fig')
saveas(fh,[ratname '-Vehicle-StayDuration_vs_Delay_2DHistogram.eps'],'epsc')
saveas(fh2,[ratname '-Drug-StayDuration_vs_Delay_2DHistogram.fig'],'fig')
saveas(fh2,[ratname '-Drug-StayDuration_vs_Delay_2DHistogram.eps'],'epsc')
close all

%% Flavor preference for each nPellets.
x = 1:3;
y = nan(3,2);
for nP = 1 : 2 : 3
    thVeh = squeeze(VEH.thresholds(:,:,nP));
    thOvr = nan(size(VEH.delays,1),1);
    for iSess=1:size(VEH.delays,1)
        thOvr(iSess) = RRheaviside(VEH.delays(iSess,:),VEH.staygo(iSess,:));
    end
    RMSDveh = sqrt(nanmean((thVeh-repmat(thOvr,1,size(thVeh,2))).^2,2));
    
    thCNO = squeeze(CNO.thresholds(:,:,nP));
    thOvr = nan(size(CNO.delays,1),1);
    for iSess=1:size(CNO.delays,1)
        thOvr(iSess) = RRheaviside(CNO.delays(iSess,:),CNO.staygo(iSess,:));
    end
    RMSDcno = sqrt(nanmean((thCNO-repmat(thOvr,1,size(thCNO,2))).^2,2));
    
    fh=figure;
    y(nP,:) = [nanmean(RMSDveh) nanmean(RMSDcno)];
    s(nP,:) = [nanstderr(RMSDveh) nanstderr(RMSDcno)];
    [bh,eh,ch]=barerrorbar([],y(nP,:),s(nP,:));
    set(eh,'color','k')
    set(gca,'xtick',1:2)
    set(gca,'xticklabel',{'Vehicle' 'CNO'})
    ylabel(sprintf('Degree of flavor preference\n(mean RMSD from session overall \\pm SEM)'))
    title(sprintf('%s\n%d pellets',ratname,nP))
    saveas(gcf,[ratname sprintf('-nPellets%d-RMSD_vs_Drug.fig',nP)],'fig')
    saveas(gcf,[ratname sprintf('-nPellets%d-RMSD_vs_Drug.eps',nP)],'epsc')
end

fh=figure;
[bh,eh,ch]=barerrorbar([],y(1:2:3,:),s(1:2:3,:));
set(eh,'color','k')
set(gca,'xtick',1:2)
set(gca,'xticklabel',{'1 pellet' '3 pellets'})
legend(ch,{'Vehicle' 'CNO'})
ylabel(sprintf('Degree of flavor preference\n(mean RMSD from session overall \\pm SEM)'))
title(sprintf('%s\n%d pellets',ratname,nP))
saveas(gcf,[ratname sprintf('-RMSD_vs_Drug.fig',nP)],'fig')
saveas(gcf,[ratname sprintf('-RMSD_vs_Drug.eps',nP)],'epsc')


%% Save CNO, VEH
save([ratname '-4x20-summary-CNO.mat'],'CNO')
save([ratname '-4x20-summary-Veh.mat'],'VEH')

popdir;
popdir;