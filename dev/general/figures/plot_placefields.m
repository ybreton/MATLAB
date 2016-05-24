function plot_placefields(tfn,nvt)
%
%
%
%

cmap = hsv(length(tfn));
[x,y] = LoadVT_lumrg(nvt);
dt = nanmean([x.dt y.dt]);
tOnTrack = min(min(x.range),min(y.range));
tOffTrack = max(max(x.range),max(y.range));
clf
fh = gcf;
ah(1)=subplot(1,2,1);
hold on
plot(x.data,y.data,'-','color',[0.8 0.8 0.8]);
set(gca,'xcolor','w')
set(gca,'ycolor','w')
set(gca,'xtick',[])
set(gca,'ytick',[])
hold off
tCA = LoadSpikes(tfn);
for t = 1 : length(tCA)
    spikets = tCA{t};
    spikets = spikets.restrict(tOnTrack,tOffTrack);
    spiketimes = spikets.range;
    
    ah(2)=subplot(length(tCA),2,2*t);
    hold on
    plot(spiketimes,ones(length(spiketimes),1),'.','markerfacecolor',cmap(t,:),'markeredgecolor',cmap(t,:));
    set(gca,'xlim',[tOnTrack tOffTrack])
    set(gca,'ylim',[0 1])
    ylabel('Spike')
    if t==length(tCA)
        xlabel('Spike times')
    end
    hold off
    for s = 1 : length(spiketimes)
        x0 = x.restrict(spiketimes(s)-dt,spiketimes(s)+dt);
        y0 = y.restrict(spiketimes(s)-dt,spiketimes(s)+dt);
        if ~isempty(x0.data)&~isempty(y0.data)
            set(fh,'currentaxes',ah(1));
            hold on
            plot(nanmean(x0.data),nanmean(y0.data),'.','markerfacecolor',cmap(t,:),'markeredgecolor',cmap(t,:));
            hold off
        end
    end
end