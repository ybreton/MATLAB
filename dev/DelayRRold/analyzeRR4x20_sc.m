%% analyzeRR4x20_sc
%% Script template for analyzing 4x20 (nPellets = [3 1 1 1]) restaurant row data.
%  Sessions must be in promoted format.

Drug = 'CNO';
Vehicle = 'Saline';
ratname = 'R266';

pushdir([pwd '\' ratname]);
pushdir([pwd '\' experimentDir]);
curDir = pwd;
disp(curDir);

%% Produce RR structures.
CNO = wrap_RR_analysis(Drug);
VEH = wrap_RR_analysis(Vehicle);

CNO.Speed= RRGetVelocity(CNO.fn);
VEH.Speed = RRGetVelocity(VEH.fn);

VEH = RRDecisionInstability(VEH);
CNO = RRDecisionInstability(CNO);

%% Plot session-by-session choices, vehicle.

for iSess = 1 : length(VEH.fn)
    fd=fileparts(VEH.fn{iSess});
    delim = regexpi(fd,'\');
    SSN = fd(max(delim)+1:end);
    
    pushdir(fd);
    % 1-pellet choices
    RRplotSessionChoices(VEH,1,iSess);
    % 3-pellet choices
    RRplotSessionChoices(VEH,3,iSess);
    close all
    
    % 1-pellet choices overall
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
    
    % 3-pellet choices overall
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
% all 1-pellet choices superimposed
RRplotSessionChoices(VEH,1,[]);
% all 3-pellet choices superimposed
RRplotSessionChoices(VEH,3,[]);
close all

%% Plot session-by-session choices, CNO.
for iSess = 1 : length(CNO.fn)
    fd=fileparts(CNO.fn{iSess});
    delim = regexpi(fd,'\');
    SSN = fd(max(delim)+1:end);
    
    pushdir(fd);
    % 1-pellet choices
    RRplotSessionChoices(CNO,1,iSess);
    % 3-pellet choices
    RRplotSessionChoices(CNO,3,iSess);
    close all
    
    % 1-pellet choices overall
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
    
    % 3-pellet choices overall
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
% 1-pellet choices superimposed
RRplotSessionChoices(CNO,1,[]);
% 3-pellet choices superimposed
RRplotSessionChoices(CNO,3,[]);

close all

%% Flavour preference plots, each number of pellets; amount preference plots, each flavour

fh=wrap_RR_plotRMS(VEH,CNO,'plotAmount',true);
drawnow
saveas(fh(1),[ratname '-RMSD_flavor_vs_Drug.fig'],'fig')
saveas(fh(1),[ratname '-RMSD_flavor_vs_Drug.eps'],'epsc')
saveas(fh(1),[ratname '-RMSD_amount_vs_Drug.fig'],'fig')
saveas(fh(1),[ratname '-RMSD_amount_vs_Drug.eps'],'epsc')
close all

%% Decision instability (CNO vs Vehicle) plots, each number of pellets
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

%% Save CNO, VEH
save([ratname '-4x20-summary-CNO.mat'],'CNO')
save([ratname '-4x20-summary-Veh.mat'],'VEH')

popdir;
popdir;