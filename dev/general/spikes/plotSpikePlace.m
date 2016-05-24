function plotSpikePlace(fn,nvt)
%
%
%
%

[x,y] = LoadVT_lumrg(nvt);
spkCA = LoadSpikes(fn);
for f = 1 : length(spkCA)
    t = spkCA{f};
    t = t.range;
    
    clf
    title(sprintf('%s',fn{f}));
    hold on
    plot(x.data,y.data,'-','color',[0.8 0.8 0.8]);
    for timestamp = 1 : length(t)
        x0 = x.restrict(t(timestamp)-x.dt,t(timestamp)+x.dt);
        y0 = y.restrict(t(timestamp)-y.dt,t(timestamp)+y.dt);
        plot(x0.data,y0.data,'ro','markerfacecolor','r')
    end
    hold off
    disp('Enter for next t file.')
    pause;
end
