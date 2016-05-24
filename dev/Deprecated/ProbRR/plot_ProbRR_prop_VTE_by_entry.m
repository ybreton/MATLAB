function fh = plot_ProbRR_prop_VTE_by_entry(VTE,thresh)
%
%
%
%


overalldat = [];
for f = 1 : length(VTE)
    overalldat = [overalldat; VTE(f).DATA];
end
idEx = overalldat(:,6)<=0;
overalldat(idEx,:) = [];
overalldat(:,6) = log10(overalldat(:,6));

uniqueP = unique(overalldat(:,2));

entryDat = overalldat(overalldat(:,4)==1,:);
skipDat = overalldat(overalldat(:,5)==1,:);

clf

%% entries
t = zeros(length(uniqueP),1); % total
n = zeros(length(uniqueP),1); % number above threshold

for p = 1 : length(uniqueP)
    idp = uniqueP(p) == entryDat(:,2);
    pDat = entryDat(idp,:);
    idthresh = pDat(:,6)>thresh;
    threshDat = pDat(idthresh,:);
    t(p) = size(pDat,1);
    n(p) = size(threshDat,1);
end
[m,l,u]=binocis(n,t-n,2,0.05);
subplot(1,2,1)
cla
hold on
ph=plot(uniqueP(:),m,'ko');
eh=errorbar(uniqueP(:),m,m-l,u-m);
set(eh,'linestyle','none')
set(eh,'color','k')
title('Feeder Arm Entries')
xh=xlabel(sprintf('Probability of reinforcement'));
yh=ylabel(sprintf('Proportion of entries with Log_{10} [Id\\phi] > %.1f\n( \\pm 95%% CI )',thresh));
set([xh yh],'fontname','Arial')
set([xh yh],'fontweight','bold')
set(gca,'xlim',[-0.05 1.05])
set(gca,'ylim',[-0.05 1.05])
set(gca,'xtick',[0:0.1:1])
set(gca,'ytick',[0:0.1:1])

hold off

%% skips

t = zeros(length(uniqueP),1); % total
n = zeros(length(uniqueP),1); % number above threshold

for p = 1 : length(uniqueP)
    idp = uniqueP(p) == skipDat(:,2);
    pDat = skipDat(idp,:);
    idthresh = pDat(:,6)>thresh;
    threshDat = pDat(idthresh,:);
    t(p) = size(pDat,1);
    n(p) = size(threshDat,1);
end
[m,l,u]=binocis(n,t-n,2,0.05);
subplot(1,2,2)
cla
hold on
ph=plot(uniqueP(:),m,'ko');
eh=errorbar(uniqueP(:),m,m-l,u-m);
set(eh,'linestyle','none')
set(eh,'color','k')
title('Feeder Arm Skips')
xh=xlabel(sprintf('Probability of reinforcement'));
yh=ylabel(sprintf('Proportion of skips with Log_{10} [Id\\phi] > %.1f\n( \\pm 95%% CI )',thresh));
set([xh yh],'fontname','Arial')
set([xh yh],'fontweight','bold')
set(gca,'xlim',[-0.05 1.05])
set(gca,'ylim',[-0.05 1.05])
set(gca,'xtick',[0:0.1:1])
set(gca,'ytick',[0:0.1:1])
hold off

%% Outputs
if nargout>0
    fh = gcf;
end