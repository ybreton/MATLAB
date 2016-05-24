for iRat = 1 : length(AllRats)
    VEH = AllRats(iRat).VEH;
    CNO = AllRats(iRat).CNO;
    
    xFlavVeh = wrap_RR_summarizeThreshold(VEH);
    overallVeh = squeeze(nanmean(xFlavVeh,1));
    
    xFlavCNO = wrap_RR_summarizeThreshold(CNO);
    overallCNO = squeeze(nanmean(xFlavCNO,1));
    
    mThresh(iRat,1) = nanmean(overallVeh(2,:),2);
    mThresh(iRat,2) = nanmean(overallCNO(2,:),2);
    
    nTrialsVeh = wrap_RR_summarizeNTrials(VEH);
    nTrialsCNO = wrap_RR_summarizeNTrials(CNO);
    
    mTrls(iRat,1) = nanmean(nTrialsVeh);
    mTrls(iRat,2) = nanmean(nTrialsCNO);
    
end
figure;
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
d(:,1) = mThresh(:,2)-mThresh(:,1);
d(:,2) = mTrls(:,2)-mTrls(:,1);
plot(d(:,1),d(:,2),'ko')
hold on
for iRat=1:length(d)
    th=text(d(iRat,1),d(iRat,2),ratlist{iRat});
    set(th,'fontsize',12)
    set(th,'VerticalAlignment','bottom')
    set(th,'HorizontalAlignment','left')
end
hold off
xlabel(sprintf('Mean change in overall threshold\n(CNO - Vehicle)'))
ylabel(sprintf('Mean change in number of trials run\n(CNO - Vehicle)'))
saveas(gcf,'AllRats-DeltaNTrials_vs_DeltaThresh.fig','fig')
saveas(gcf,'AllRats-DeltaNTrials_vs_DeltaThresh.eps','epsc')