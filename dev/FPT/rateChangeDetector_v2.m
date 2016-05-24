function [cp,logOR] = rateChangeDetector_v2(event_tsd,varargin)
%
%
%
%
%
crit = log10(2);
minDuration = 5;
plotFlag = false;
process_varargin(varargin);

times = event_tsd.T(event_tsd.D==1);
events = (1:length(times))';
if min(times)>0
    times = [0; times(:)];
end
if max(times)<event_tsd.T(end)
    times = [times(:); event_tsd.T(end)];
end
if min(events)>0
    events = [0; events(:)];
end
events = [events(:); events(end)];

cp0 = [-1;max(times)];
newCPs = 1;
if plotFlag
    cla
    hold on
end
logOR = nan(length(times),1);
if nargout>1
    t0 = cp0(1)+1;
    t1 = cp0(end);
    idx = times>=t0 & times<=t1;
    n = max(events(idx));
    t = max(times(idx));
    n0 = min(events(idx));
    t0 = min(times(idx));
    seg.T = times(idx);
    seg.D = events(idx);
    
    T = t-t0;
    N = n-n0;
    
    tc = seg.T(2:end-1);
    nc = seg.D(2:end-1);
    
    Ta = t1-tc;
    Pe = Ta./T;

    Na = n-nc;

    Pf = binocdf(Na,N,Pe);
    Pm = 1-binocdf(Na,N,Pe);
    OR = Pf./Pm;
    LogOR = log10(OR(:));
    
    if plotFlag
        hold off
        ah(1)=subplot(2,1,1);
        hold on
        plot(seg.T(2:end-1),LogOR,'k-')
        patchX = [min(seg.T(2:end-1)) min(seg.T(2:end-1)) max(seg.T(2:end-1)) max(seg.T(2:end-1))];
        patchY = [-crit crit crit -crit];
        patch(patchX,patchY,[0.7 0.7 0.7],'facealpha',0.2,'edgecolor','none')
        xlabel('t')
        ylabel(sprintf('Log_{10}[Pf/Pm]'))
        ylim = get(gca,'ylim');
        ymax = max(abs(ylim));
        ylim = [-ymax ymax];
        set(gca,'ylim',ylim)
        set(gca,'xlim',[min(seg.T) max(seg.T)])
        hold off
        ah(2)=subplot(2,1,2);
        hold on
        xlabel('t')
        ylabel('Cumulative Record')
    end
end
k=0;
while newCPs>0
    cp = cp0;
    logOR = [];
    for s = 2 : length(cp)
        t0 = cp0(s-1)+1;
        t1 = cp0(s);
        idx = times>=t0 & times<=t1;
        n = max(events(idx));
        t = max(times(idx));
        n0 = min(events(idx));
        t0 = min(times(idx));
        seg.T = times(idx);
        seg.D = events(idx);

        T = t-t0;
        N = n-n0;
        m = N/T;
        % t0 = m*n0+b
        % b = t0-m*n0
        b = t0-m*n0;

        tc = seg.T(2:end-1);
        nc = seg.D(2:end-1);

        Ta = t1-tc;
        Pe = Ta./T;

        Na = n-nc;

        Pf = binocdf(Na,N,Pe);
        Pm = 1-binocdf(Na,N,Pe);
        OR = Pf./Pm;
        LogOR = log10(OR(:));
        logOR = [logOR;LogOR(:)];
        
        [LogORmax,idMax] = max(abs(LogOR));
        
        % plot segment.
        if plotFlag
            set(gcf,'currentaxes',ah(2))
            hold on
            stairs(seg.T,seg.D)
            plot(sort(seg.T),(sort(seg.T)*m)+b,'r')
            hold off
        end
        
        if LogORmax>=crit && min(abs(tc(idMax)-cp0))>minDuration
            k = k+1;
            if plotFlag
                set(gcf,'currentaxes',ah(2))
                hold on
                plot(tc(idMax),nc(idMax),'ro','markerfacecolor','r')
                str = sprintf('%d',k);
                th=text(tc(idMax),nc(idMax),str,'verticalalignment','middle','horizontalalignment','center');
                set(th,'fontname','arial')
                set(th,'fontsize',12)
                set(th,'fontweight','bold')
                hold off
                set(gcf,'currentaxes',ah(1))
                hold on
                temp = seg.D(idMax);
                plot(tc(idMax),mean(temp),'ro')
                hold off
            end
            cp0 = [cp0(:); tc(idMax)];
            cp0 = sort(cp0);
        end
        
    end
    newCPs = length(cp0)-length(cp);
end
if plotFlag
    hold off
end