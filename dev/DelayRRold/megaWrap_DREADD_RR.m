function megaWrap_DREADD_RR(ratname,experimentDir,Vehicle,Drug)

VTEtime = 2;
pushdir([pwd '\' ratname]);
pushdir([pwd '\' experimentDir]);
curDir = pwd;
disp(curDir);
%% produce structures for each condition
disp('Producing condition analysis structures.')
CNO = wrap_RR_analysis(Drug);
VEH = wrap_RR_analysis(Vehicle);
close all
%% Plot session-by-session choices
disp('Plotting session-by-session choice.')
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
RRplotSessionChoices(VEH,2,[]);
close all

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
RRplotSessionChoices(CNO,2,[]);
close all
%%
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
%% IdPhi and velocity.
% CNO.Speed= RRGetVelocity(CNO.fn);
% CPSpeed = nan(size(CNO.IdPhi));
% for iSess = 1 : size(CPSpeed,1)
%     for iTrl = 1 : size(CPSpeed,2)
%         if ~isnan(CNO.EnteringZoneTime(iSess,iTrl))
%             Vcp = CNO.Speed{iSess}.restrict(CNO.EnteringZoneTime(iSess,iTrl),CNO.EnteringZoneTime(iSess,iTrl)+VTEtime);
%             CPSpeed(iSess,iTrl) = nanmean(Vcp.data);
%         end
%     end
% end
% gmobj = gmmfit([log10(CNO.IdPhi(:)) CPSpeed(:)],3);
% IdPhiEdges = linspace(1,3,50);
% SpeedEdges = linspace(0,max(CPSpeed(:)),50);
% 
% H = histcn([log10(CNO.IdPhi(:)) CPSpeed(:)],IdPhiEdges,SpeedEdges);
% subplot(2,2,1)
% imagesc(IdPhiEdges,SpeedEdges,H);
% axis xy
% hold on
% title('CNO')
% plot(gmobj.mu(:,1),gmobj.mu(:,2),'w.')
% hold off
% subplot(2,2,2)
% [f,bin]=hist(CPSpeed(:),SpeedEdges);
% bar(bin,f/sum(f),1);
% set(gca,'xlim',[min(SpeedEdges) max(SpeedEdges)])
% xlabel('Average speed')
% subplot(2,2,3)
% [f,bin]=hist(log10(CNO.IdPhi(:)),IdPhiEdges);
% bar(bin,f/sum(f),1);
% set(gca,'xlim',[min(IdPhiEdges) max(IdPhiEdges)])
% xlabel(sprintf('Log_{10}[I d\\phi]'))
% 
% VEH.Speed = RRGetVelocity(VEH.fn);


%% produce threshold plots
disp('Producing threshold plots.')
fh=wrap_RR_plotThresholds(VEH,1,'titleStr','Vehicle');
wrap_RR_plotThresholds(CNO,2,'fh',fh,'titleStr', 'CNO');
drawnow
saveas(fh,[ratname '-Choice_vs_Delay_at_Drug.fig'],'fig')
saveas(fh,[ratname '-Choice_vs_Delay_at_Drug.eps'],'epsc')
close all
%% produce flavor preference plots
disp('Producing flavor preference plots.')
fh=wrap_RR_plotRMS(VEH,CNO,'plotAmount',false);
drawnow
saveas(fh(1),[ratname '-RMSD_flavor_vs_Drug.fig'],'fig')
saveas(fh(1),[ratname '-RMSD_flavor_vs_Drug.eps'],'epsc')
close all
%% produce decision instability plots
fh=wrap_RR_plotPError(VEH,CNO,2);
saveas(fh(1),[ratname '-PError_vs_Drug_boxplot.fig'],'fig')
saveas(fh(1),[ratname '-PError_vs_Drug_boxplot.eps'],'epsc')
saveas(fh(2),[ratname '-PError_vs_Drug.fig'],'fig')
saveas(fh(2),[ratname '-PError_vs_Drug.eps'],'epsc')
close all

%% produce skip plots
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
%% IdPhi
disp('Producing VTE plots.')
fh = wrap_RR_plotVTEhists(VEH,CNO);
drawnow
saveas(fh,[ratname '-LogIdPhi_Histogram_at_Drug.fig'],'fig')
saveas(fh,[ratname '-LogIdPhi_Histogram_at_Drug.eps'],'epsc')
fh = wrap_RR_plotVTEdiffs(VEH,CNO);
drawnow
saveas(fh,[ratname '-LogIdPhi_HistDiff.fig'],'fig')
saveas(fh,[ratname '-LogIdPhi_HistDiff.eps'],'epsc')
fh = wrap_RR_plotVTEviaThresh(VEH,CNO);
drawnow
saveas(fh,[ratname '-pVTEbyThresh_vs_Drug.fig'],'fig')
saveas(fh,[ratname '-pVTEbyThresh_vs_Drug.eps'],'epsc')
fh = wrap_RR_plotVTEviaGMM(VEH,CNO);
drawnow
saveas(fh,[ratname '-pVTEbyGMM_vs_Drug.fig'],'fig')
saveas(fh,[ratname '-pVTEbyGMM_vs_Drug.eps'],'epsc')
close all

fh = wrap_RR_plotVTEviaCommonGMM(VEH,CNO,'k',3);
drawnow
saveas(fh(1),[ratname '-Overall3GMMfit_Histogram.fig'],'fig')
saveas(fh(1),[ratname '-Overall3GMMfit_Histogram.eps'],'epsc')
saveas(fh(2),[ratname '-pVTEbyCommon3GMM_vs_Drug.fig'],'fig')
saveas(fh(2),[ratname '-pVTEbyCommon3GMM_vs_Drug.eps'],'epsc')

fh = wrap_RR_plotVTEviaCommonGMM(VEH,CNO);
drawnow
saveas(fh(1),[ratname '-Overall2GMMfit_Histogram.fig'],'fig')
saveas(fh(1),[ratname '-Overall2GMMfit_Histogram.eps'],'epsc')
saveas(fh(2),[ratname '-pVTEbyCommon2GMM_vs_Drug.fig'],'fig')
saveas(fh(2),[ratname '-pVTEbyCommon2GMM_vs_Drug.eps'],'epsc')
close all
%% Regret, disappointment and rejoice
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

close all
%% 
VEH = RRDecisionInstability(VEH);
CNO = RRDecisionInstability(CNO);

%% Save CNO, VEH
save([ratname '-StableRR-summary-CNO.mat'],'CNO')
save([ratname '-StableRR-summary-Veh.mat'],'VEH')

%%
popdir;

popdir;