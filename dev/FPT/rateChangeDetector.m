function [cp,logOR] = rateChangeDetector(event_tsd,varargin)
% Implements Gallistel's rate-change detector algorithm, on time-stamped
% data event_tsd using criterion Log-OR crit.
% event_tsd is a time-stamped list of whether a punctate event occurred (1)
% or did not occur (0) at each time t. Assumes no events have occurred
% between 0 and the time of the first event.
%
% [cp,logOR] = rateChangeDetector(event_tsd,varargin)
% where     cp          list of change points (end of segment)
%           logOR       tsd of log-odds ratio of there being fewer/more
%                       events after each point in time compared to random
%                       chance
%           event_tsd   tsd of whether event occurred at time t
% optional arguments:
%   crit            criterion log10(OR) for designating a change point
%                   (default 2).
%   minDuration     minimum duration of a segment created by any new change
%                   point (minimum 5).
%   plotFlag        logical of whether or not to plot the cum-cum graph and
%                   overlain change point.
%
%

crit = log10(2);
minDuration = 5;
plotFlag = false;
process_varargin(varargin);

times = event_tsd.T(event_tsd.D==1);
events = (1:length(times))';
if ~isempty(events)
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
end
cp0 = [0;max(times)];

newCPs = 1;
if plotFlag
    cla
    hold on
end
if nargout>1
    t0 = cp0(1);
    t1 = cp0(end);
    idx = times>t0 & times<=t1;
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
    logOR = tsd(tc,LogOR);
    
    if plotFlag
        hold off
        ah(1)=subplot(2,1,1);
        hold on
        plot(logOR.range,logOR.data,'k-')
        patchX = [min(logOR.range) min(logOR.range) max(logOR.range) max(logOR.range)];
        patchY = [-crit crit crit -crit];
        patch(patchX,patchY,[0.7 0.7 0.7],'facealpha',0.2,'edgecolor','none')
        xlabel('t')
        ylabel(sprintf('Log_{10}[Pf/Pm]'))
        ylim = get(gca,'ylim');
        ymax = max(abs(ylim));
        ylim = [-ymax ymax];
        set(gca,'ylim',ylim)
        set(gca,'xlim',[min(logOR.range) max(logOR.range)])
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
    for s = 2 : length(cp)
        t0 = cp(s-1);
        t1 = cp(s);
        
        idx = times>t0 & times<=t1;
        
        n = max(events(idx));
        t = max(times(idx));
        
        n0 = min(events(idx));
        t0 = min(times(idx));
        
        seg.T = times(idx);
        seg.D = events(idx);
        
        T = t-t0;
        N = n-n0;
        
        m = N/T;
        b = n0 - m*t0;
        
        predT = (seg.D-b)./m;
        
        d = abs(predT-seg.T);
        [dmax,idmax] = max(d);
        
        tc = seg.T(idmax);
        nc = seg.D(idmax);
        
        Ta = t1-tc;
        Pe = Ta./T;
        
        Na = n-nc;
        
        Pf = binocdf(Na,N,Pe);
        Pm = 1-binocdf(Na,N,Pe);
        OR = Pf./Pm;
        LogOR = log10(OR);
        
        % plot segment.
        if plotFlag
            set(gcf,'currentaxes',ah(2))
            hold on
            stairs(seg.T,seg.D)
            plot(sort(seg.T),(sort(seg.T)*m)+b,'r')
            hold off
        end
        
        if abs(LogOR)>=crit && min(abs(tc-cp0))>minDuration
            k = k+1;
            if plotFlag
                set(gcf,'currentaxes',ah(2))
                hold on
                plot(tc,nc,'ro','markerfacecolor','r')
                str = sprintf('%d',k);
                th=text(tc,nc,str,'verticalalignment','middle','horizontalalignment','center');
                set(th,'fontname','arial')
                set(th,'fontsize',12)
                set(th,'fontweight','bold')
                hold off
                set(gcf,'currentaxes',ah(1))
                hold on
                temp = logOR.restrict(tc,tc);
                plot(tc,mean(temp.data),'ro')
                hold off
            end
            cp0 = [cp0(:); tc];
            cp0 = sort(cp0);
        end
        
    end
    newCPs = length(cp0)-length(cp);
end

if numel(cp)<2
    cp(2) = max(event_tsd.range);
end

if plotFlag
    hold off
end
