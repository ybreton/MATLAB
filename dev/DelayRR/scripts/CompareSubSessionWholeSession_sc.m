%% Script to produce histogram of 1-pellet thresholds by zone.
%%
AssembleAllSess_sc;
%%
subsessThresh = nan(4,length(VEH)*4);
k=0;
for iSess = 1 : length(VEH)
    sd = VEH(iSess).sd;
    for s = 1 : length(sd);
        k = k+1;
        th = sd(s).Subsession.Thresholds.FlavourAmount(:,1);
        subsessThresh(:,k) = th;
    end
end
wholeThresh = nan(4,length(VEH));
for iSess = 1 : length(VEH)
    sd = VEH(iSess).sd;
    th = sd(1).WholeSession.Thresholds.FlavourAmount(:,1);
    wholeThresh(:,iSess) = th;
end

flavour = {'Cherry' 'Banana' 'Plain White' 'Chocolate'};

figure
for iZ=1:4
    subplot(2,2,iZ)
    hold on
    [f,bin]=hist(subsessThresh(iZ,:),linspace(0,30,16));
    bar(bin,f/sum(f),1)
    title(flavour{iZ})
    hold off
    xlabel('Sub-session threshold')
    ylabel('Proportion of sub-sessions')
    set(gca,'xlim',[0 30])
end
saveas(gcf,'SubsessionThresholdDistributions.fig','fig')
saveas(gcf,'SubsessionThresholdDistributions.eps','epsc')

figure
for iZ=1:4
    subplot(2,2,iZ)
    hold on
    [f,bin]=hist(wholeThresh(iZ,:),linspace(0,30,16));
    bar(bin,f/sum(f),1)
    title(flavour{iZ})
    hold off
    xlabel('Whole-session threshold')
    ylabel('Proportion of whole sessions')
    set(gca,'xlim',[0 30])
end
saveas(gcf,'WholeSessionThresholdDistributions.fig','fig')
saveas(gcf,'WholeSessionThresholdDistributions.eps','epsc')