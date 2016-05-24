function fh = plot_linesegment_KLP_hists(K,L,P)

cmap = hsv(max(K)+2);
cmap = cmap(2:size(cmap,1)-1,:);
fh = gcf;
clf
subplot(2,3,1)
hold on

for k = 1 : 10
    n = sum(double(K==k));
    X = [k-0.5 k-0.5 k+0.5 k+0.5];
    Y = [0 n n 0];
    patch(X,Y,[0 0 0],'edgecolor',[0.7 0.7 0.7],'facecolor',[0.8 0.8 0.8])
end
xlabel('Number of segments extracted')
ylabel('Number of sessions')
set(gca,'xlim',[0 10])
set(gca,'xtick',[1:9])

hold off
subplot(2,3,2)
hold on
for k = 1 : max(K);
    id = ~isnan(L(:,k));
    [f,bin]=hist(L(id,k),ceil(sqrt(numel(L(id,k)))));
    w = mean(diff(bin));
    bin = [bin(1)-w bin bin(end)+w];
    f = [0 f 0];
    plot(bin,f,'-','color',cmap(k,:),'linewidth',3);
end
xlabel('Number of laps')
xlim = get(gca,'xlim');
xlim(1) = max(0,xlim(1));
xlim(2) = min(max(L(:)),xlim(2));
set(gca,'xlim',xlim)
hold off
subplot(2,3,3)
hold on
for k = 2 : 2 : max(K);
    id = ~isnan(P(:,k));
    [f,bin]=hist(P(id,k),ceil(sqrt(numel(P(id,k)))));
    w = mean(diff(bin));
    bin = [bin(1)-w bin bin(end)+w];
    f = [0 f 0];
    plot(bin,f,'-','color',cmap(k,:),'linewidth',3)
end
xlabel(sprintf('Probability of choosing delayed\nduring titration segment'))
set(gca,'xlim',[0 1])
set(gca,'xtick',[0:0.1:1])
hold off

subplot(2,1,2)
hold on
title(sprintf('Mean segment durations and probabilities'))
xlabel('Lap number')
ylabel('Probability of choosing delayed')
MeanProb = nanmean(P,1);
MeanDuration = nanmean(L,1);
SEMProb = nanstderr(P);
SEMDuration = nanstderr(L);

start(1) = 1;
for k = 1 : max(K);
    finish(k) = start(k)+MeanDuration(k)-1;
    start(k+1) = finish(k)+1;
end
start(max(K)+1) = [];

for k = 1 : max(K)
    X = [start(k)-SEMDuration(k) start(k)-SEMDuration(k) finish(k)+SEMDuration(k) finish(k)+SEMDuration(k)];
    Y = [MeanProb(k)-SEMProb(k) MeanProb(k)+SEMProb(k) MeanProb(k)+SEMProb(k) MeanProb(k)-SEMProb(k)];
    patch(X,Y,[0 0 0],'facecolor',cmap(k,:),'edgecolor','none','facealpha',0.1)
    plot([start(k) finish(k)],[MeanProb(k) MeanProb(k)],'.','color',cmap(k,:),'markersize',20);
    ph(k)=plot([start(k) finish(k)],[MeanProb(k) MeanProb(k)],'-','color',cmap(k,:),'linewidth',2);
    if mod(k,2)==1
        legendStr{k} = sprintf('Alternation,\nSegment %.0f',k);
    else
        legendStr{k} = sprintf('Titration,\nSegment %.0f',k);
    end
end
set(gca,'ylim',[-0.05 1.05])
set(gca,'xlim',[0 ceil(max(L(:))/5)*5])
legend(ph,legendStr,'location','northeastoutside')
hold off