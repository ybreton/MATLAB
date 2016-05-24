%% Script template for analyzing StableRR (nPellets =[2 2 2 2]) DREADD sessions.
%  Sessions must be in promoted format.

%% Define Drug and Vehicle conditions.
Drug = 'CNO';
Vehicle = 'Saline';
ratname = 'R266';

%% Produce initial structures.
VEH = wrap_RR_analysis(Vehicle);
CNO = wrap_RR_analysis(Drug);
close all

%% Decision instability calculation.
VEH = RRDecisionInstability(VEH);
CNO = RRDecisionInstability(CNO);

%% Session-by-session vehicle choices: each zone and overall.
for iSess = 1 : length(VEH.fn)
    fd=fileparts(VEH.fn{iSess});
    delim = regexpi(fd,'\');
    SSN = fd(max(delim)+1:end);
    
    pushdir(fd);
    RRplotSessionChoices(VEH,2,iSess);
    close all
    fh=figure;
    set(gca,'fontsize',18);
    set(gca,'fontname','Arial');
    plot(VEH.delays(iSess,:),VEH.staygo(iSess,:)+randn(1,length(VEH.staygo(iSess,:)))/100,'b.');
    hold on; 
    plot(1:30,1:30<=VEH.marginalZonebyPellet(iSess,1,2));
    hold off
    set(gca,'ylim',[-0.05 1.05]);set(gca,'ytick',[0:0.1:1])
    set(gca,'xlim',[0 30]);set(gca,'xtick',[0:5:30]);
    xlabel('Delay (secs)')
    ylabel('P[Stay]')
    title(sprintf('%s\nOverall',SSN))
    set(gca,'box','off')
    
    saveas(fh,[SSN '-Overall-Choices.fig'],'fig')
    saveas(fh,[SSN '-Overall-Choices.eps'],'epsc')
    close all
    popdir;
end

%% Session-by-session CNO choices: each zone and overall.
for iSess = 1 : length(CNO.fn)
    fd=fileparts(CNO.fn{iSess});
    delim = regexpi(fd,'\');
    SSN = fd(max(delim)+1:end);
    
    pushdir(fd);
    
    RRplotSessionChoices(CNO,2,iSess);
    close all
    
    fh=figure;
    set(gca,'fontsize',18);
    set(gca,'fontname','Arial');
    plot(CNO.delays(iSess,:),CNO.staygo(iSess,:)+randn(1,length(CNO.staygo(iSess,:)))/100,'b.');
    hold on; 
    plot(1:30,1:30<=CNO.marginalZonebyPellet(iSess,1,2));
    hold off
    set(gca,'ylim',[-0.05 1.05]);set(gca,'ytick',[0:0.1:1])
    set(gca,'xlim',[0 30]);set(gca,'xtick',[0:5:30]);
    xlabel('Delay (secs)')
    ylabel('P[Stay]')
    
    title(sprintf('%s\nOverall',SSN))
    set(gca,'box','off')
    
    saveas(fh,[SSN '-Overall-Choices.fig'],'fig')
    saveas(fh,[SSN '-Overall-Choices.eps'],'epsc')
    close all
    popdir
end

%% Mean thresholds, vehicle and CNO.
fh=wrap_RR_plotThresholds(VEH,1,'titleStr','Vehicle');
wrap_RR_plotThresholds(CNO,2,'fh',fh,'titleStr', 'CNO');
drawnow
saveas(fh,[ratname '-Choice_vs_Delay_at_Drug.fig'],'fig')
saveas(fh,[ratname '-Choice_vs_Delay_at_Drug.eps'],'epsc')
close all

%% Degree of flavour preferences, vehicle vs. CNO.
fh=wrap_RR_plotRMS(VEH,CNO,'plotAmount',false);
drawnow
saveas(fh(1),[ratname '-RMSD_flavor_vs_Drug.fig'],'fig')
saveas(fh(1),[ratname '-RMSD_flavor_vs_Drug.eps'],'epsc')

%% Decision instability, vehicle vs. CNO.
fh=wrap_RR_plotPError(VEH,CNO,2);
saveas(fh(1),[ratname '-PError_vs_Drug_boxplot.fig'],'fig')
saveas(fh(1),[ratname '-PError_vs_Drug_boxplot.eps'],'epsc')
saveas(fh(2),[ratname '-PError_vs_Drug.fig'],'fig')

%% Stay duration vs. delay 2D histogram, vehicle and CNO.
fh = wrap_RR_stayDuration2DHist(VEH,'titleStr','Vehicle');
drawnow
fh2 = wrap_RR_stayDuration2DHist(CNO,'titleStr','CNO');
drawnow
saveas(fh,[ratname '-Vehicle-StayDuration_vs_Delay_2DHistogram.fig'],'fig')
saveas(fh,[ratname '-Vehicle-StayDuration_vs_Delay_2DHistogram.eps'],'epsc')
saveas(fh2,[ratname '-Drug-StayDuration_vs_Delay_2DHistogram.fig'],'fig')
saveas(fh2,[ratname '-Drug-StayDuration_vs_Delay_2DHistogram.eps'],'epsc')
saveas(fh(2),[ratname '-PError_vs_Drug.eps'],'epsc')
close all

%% Regret, Disappointments and Rejoice, vehicle and CNO.
[VEH,fh] = wrap_RR_regret(VEH,'plotFlag',true);
saveas(fh(1),[ratname '-Vehicle-pStay_vs_Regret_BoxWhisker.fig'],'fig')
saveas(fh(1),[ratname '-Vehicle-pStay_vs_Regret_BoxWhisker.eps'],'epsc')
saveas(fh(2),[ratname '-Vehicle-zIdPhi_Histogram_at_Regret.fig'],'fig')
saveas(fh(2),[ratname '-Vehicle-zIdPhi_Histogram_at_Regret.eps'],'epsc')
saveas(fh(3),[ratname '-Vehicle-HandlingTime_Histogram_at_Regret.fig'],'fig')
saveas(fh(3),[ratname '-Vehicle-HandlingTime_Histogram_at_Regret.eps'],'epsc')
saveas(fh(4),[ratname '-Vehicle-StayDuration_Histogram_at_Regret.fig'],'fig')
saveas(fh(4),[ratname '-Vehicle-StayDuration_Histogram_at_Regret.eps'],'epsc')

[CNO,fh] = wrap_RR_regret(CNO,'plotFlag',true);
saveas(fh(1),[ratname '-Drug-pStay_vs_Regret_BoxWhisker.fig'],'fig')
saveas(fh(1),[ratname '-Drug-pStay_vs_Regret_BoxWhisker.eps'],'epsc')
saveas(fh(2),[ratname '-Drug-zIdPhi_Histogram_at_Regret.fig'],'fig')
saveas(fh(2),[ratname '-Drug-zIdPhi_Histogram_at_Regret.eps'],'epsc')
saveas(fh(3),[ratname '-Drug-HandlingTime_Histogram_at_Regret.fig'],'fig')
saveas(fh(3),[ratname '-Drug-HandlingTime_Histogram_at_Regret.eps'],'epsc')
saveas(fh(4),[ratname '-Drug-StayDuration_Histogram_at_Regret.fig'],'fig')
saveas(fh(4),[ratname '-Drug-StayDuration_Histogram_at_Regret.eps'],'epsc')

%% Backwards, vehicle and CNO.
VEH = RRIdentifyBackwards(VEH); 
CNO = RRIdentifyBackwards(CNO);

%% Save VEH and CNO structures.
save([ratname '-StableRR-summary-CNO.mat'],'CNO')
save([ratname '-StableRR-summary-Veh.mat'],'VEH')