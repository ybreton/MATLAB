%% Initialize
VEHstr = 'Saline';
CNOstr = 'CNO';
%%
fn = FindFiles('RR-*.mat');
fd = cell(length(fn),1);
for f = 1 : length(fn); 
    fd{f} = fileparts(fn{f}); 
end
fd = unique(fd);
%% Accumulate sessions.
AllSessions = wrap_RR_collectSess(fd);

%% Divide them into conditions.

VEH = wrap_RR_analysis(AllSessions,VEHstr);
CNO = wrap_RR_analysis(AllSessions,CNOstr);

%% Find flavour and amount effect.
flavours = {'Cherry' 'Banana' 'Plain White' 'Chocolate'};

[FlavourVEH,AmountVEH,OverallVEH] = wrap_RR_getWholeSessThresh(VEH);
[FlavourCNO,AmountCNO,OverallCNO] = wrap_RR_getWholeSessThresh(CNO);

mFlavour = nan(3,2);
mFlavour(:,1) = nanmean(FlavourVEH)';
sFlavour(:,1) = nanstderr(FlavourVEH)';
mFlavour(:,2) = nanmean(FlavourCNO)';
sFlavour(:,2) = nanstderr(FlavourCNO)';

figure;
[bh,eh,ch]=barerrorbar(1:3,mFlavour,sFlavour);
set(eh,'linestyle','none')
set(eh,'color','k')
legend(ch,{'Vehicle' 'CNO'})
xlabel('Number of pellets')
ylabel('RMSD of flavour thresholds from across-flavour threshold\n(mean \\pm SEM)')
saveas(gcf,'RMSD_flavour_vs_Amount_at_Drug.fig','fig')
saveas(gcf,'RMSD_flavour_vs_Amount_at_Drug.eps','epsc')

mAmount = nan(4,2);
mAmount(:,1) = nanmean(AmountVEH)';
sAmount(:,1) = nanstderr(AmountVEH)';
mAmount(:,2) = nanmean(AmountCNO)';
sAmount(:,2) = nanstderr(AmountCNO)';

figure;
[bh,eh,ch]=barerrorbar(1:4,mAmount,sAmount);
set(eh,'linestyle','none')
set(eh,'color','k')
legend(ch,{'Vehicle' 'CNO'})
xlabel('Zone')
set(gca,'xticklabel',flavours)
ylabel('RMSD of amount thresholds from across-amount threshold\n(mean \\pm SEM)')
saveas(gcf,'RMSD_amount_vs_Flavour_at_Drug.fig','fig')
saveas(gcf,'RMSD_amount_vs_Flavour_at_Drug.eps','epsc')
