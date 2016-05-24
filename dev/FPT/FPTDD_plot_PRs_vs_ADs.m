function [AllRatsADs,AllRatsPRs,AllRatsExs] = FPTDD_plot_PRs_vs_ADs(GroupPolicy)
title('Delay Discounting Function')
hold on
AllRatsADs = [];
AllRatsPRs = [];
AllRatsInf = [];
AllRatsExs = [];
cmap = jet(length(GroupPolicy));
for r = 1 : length(GroupPolicy)
    bD = GroupPolicy(r).data.DDall;
    ADs = double(GroupPolicy(r).data.ADs);
    PRs = double(GroupPolicy(r).data.PRs);
    Ex = logical(GroupPolicy(r).data.badSSN);
    idInf = logical(GroupPolicy(r).data.infAD);
    bDAll = glmfit(ADs(~idInf),PRs(~idInf),'normal');
    plot(ADs(~idInf),PRs(~idInf),'o','markeredgecolor',cmap(r,:),'markersize',10,'markerfacecolor','w')
    plot(ADs(~idInf),PRs(~idInf),'.','markeredgecolor',cmap(r,:))
    plot(sort(ADs),glmval(bDAll,sort(ADs),'identity'),':','color',cmap(r,:));
    AllRatsADs = [AllRatsADs;
            ADs(:)];
    AllRatsPRs = [AllRatsPRs;
            PRs(:)];
    AllRatsInf = [AllRatsInf;
            idInf(:)];
    AllRatsExs = [AllRatsExs;
            Ex(:)];
end
% idFin = ~AllRatsInf(:);
% bOverall = glmfit(AllRatsADs(idFin),AllRatsPRs(idFin),'normal');
% plot(unique(AllRatsADs(idFin)),glmval(bOverall,unique(AllRatsADs(idFin)),'identity'),'k-')
xlabel('Inferred Adjusting Delay')
ylabel('Pellet Ratio')
set(gca,'xlim',[0 60])
set(gca,'ylim',[0 5])
hold off