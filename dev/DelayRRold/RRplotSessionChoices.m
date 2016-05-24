function fh = RRplotSessionChoices(VEH,pellets,sessions,varargin)
% Plots binary stay/go data (jittered by 1%) for a range of sessions and
% number of pellets.
% fh = RRplotSessionChoices(VEH,pellets,sessions)
% where     fh          is a list of figure handles produced
%
%           VEH         is a RR structure produced by wrap_RR_analysis
%           pellets     is the number of food pellets delivered per zone
%           sessions    is a list of sessions to plot overlapped. If list
%                           is empty, plots all sessions superimposed.
% OPTIONAL ARGUMENTS:
% ******************
% fh        (default next 4)    list of handles to plot figures.
% saveFigs  (default true)      attempt to save fig and eps files of
%                                   figures with session data (if one
%                                   sessions) or at current directory (if
%                                   multiple sessions).
% jitterFactor (default 1/100)  standard deviation of random jitter to add
%                                   to binary stay/go data.
% Files are saved as SSN-ZoneX-nPelletsY-Choices.fig (for a single session) or
%                    SSNfirst--SSNlast-ZoneX-nPelletsY-Choices.fig (for range).

curFigs = get(0,'children');
if isempty(curFigs)
    lastFig = 0;
else
    lastFig = max(curFigs);
end
fh = [lastFig+1:lastFig+4];
saveFigs = true;
jitterFactor = 1/100;
process_varargin(varargin);
if isempty(sessions)
    sessions = 1:length(VEH.fn);
end

cmap = RRColorMap;
cmap(3,:) = [0 0 0]; % black for plain white pellets.
delayList = unique(VEH.delays(~isnan(VEH.delays)));
dDelay = median(diff(delayList));
predX = [delayList(1)-dDelay/2 delayList(:)' delayList(end)+dDelay/2];
xmax = max(30,ceil(max(delayList)/5)*5);
for iSess = 1 : length(sessions)
    session = sessions(iSess);
    x = VEH.delays(session,:); 
    p = VEH.zones(session,:); 
    y = VEH.staygo(session,:);
    n = VEH.pellets(session,:);
    
    fn = VEH.fn{session};
    delim = [regexpi(fn,'\') regexpi(fn,'/')];
    fd = fn(1:max(delim)-1);
    delim = [regexpi(fd,'\') regexpi(fd,'/')];
    if length(sessions)==1
        SSN = fd(max(delim)+1:end);
    else
        if session==1
            SSN{1} = fd(max(delim)+1:end);
            SSN{2} = fd(max(delim)+1:end);
        else
            SSN{2} = fd(max(delim)+1:end);
        end
    end
    if any(~isnan(x))
        idnan = isnan(x)|isnan(p)|isnan(y)|isnan(n);
        x = x(~idnan);
        y = y(~idnan);
        p = p(~idnan);
        n = n(~idnan);
        for iZ = 1 : 4; 
            idZ = p==iZ; 
            idN = n==pellets;
            th = VEH.thresholds(session,iZ,pellets);
            predY = double(predX<th);
            predY(unique(x)==th) = 0.5;
            figure(fh(iZ)); 
            set(gca,'fontsize',18)
            set(gca,'fontname','Arial')
            hold on; 
            plot(x(idZ&idN),y(idZ&idN)+randn(1,length(x(idZ&idN)))*jitterFactor,'.','markeredgecolor',cmap(iZ,:)); 
            plot(predX,predY,'-','color',cmap(iZ,:)); 
            set(gca,'ylim',[-0.05 1.05]); 
            set(gca,'ytick',[0 1]); 
            set(gca,'xlim',[0 30])
            set(gca,'xtick',[0:5:30])
            set(gca,'box','off')
            xlabel(sprintf('Delay (secs)'))
            set(gca,'yticklabel',{'Skip' 'Stay'})
            drawnow;
        end;
    end
    
    if length(sessions)==1
        figure(fh(1))
        hold on; title(sprintf('%s\nCherry\n(%d Pellets)',SSN,pellets)); hold off
        figure(fh(2))
        hold on; title(sprintf('%s\nBanana\n(%d Pellets)',SSN,pellets)); hold off
        figure(fh(3))
        hold on; title(sprintf('%s\nPlain White\n(%d Pellets)',SSN,pellets)); hold off
        figure(fh(4))
        hold on; title(sprintf('%s\nChocolate\n(%d Pellets)',SSN,pellets)); hold off
    else
        figure(fh(1))
        hold on; title(sprintf('%s -- %s\nCherry\n(%d Pellets)',SSN{1},SSN{2},pellets)); hold off
        figure(fh(2))
        hold on; title(sprintf('%s -- %s\nBanana\n(%d Pellets)',SSN{1},SSN{2},pellets)); hold off
        figure(fh(3))
        hold on; title(sprintf('%s -- %s\nPlain White\n(%d Pellets)',SSN{1},SSN{2},pellets)); hold off
        figure(fh(4))
        hold on; title(sprintf('%s -- %s\nChocolate\n(%d Pellets)',SSN{1},SSN{2},pellets)); hold off
    end

    if saveFigs
        try
            pushdir(fd);
            for iZ = 1 : 4
                if length(sessions)==1
                    saveas(fh(iZ),[sprintf('%s-Zone%d-nPellets%d-Choices.fig',SSN,iZ,pellets)],'fig')
                    saveas(fh(iZ),[sprintf('%s-Zone%d-nPellets%d-Choices.eps',SSN,iZ,pellets)],'epsc')
                end
            end
            popdir;
        catch exception
            disp('Could not save figures.')
        end
    end
end

if saveFigs && length(sessions)>1
    try
        for iZ = 1 : 4
            saveas(fh(iZ),[sprintf('%s--%s-Zone%d-nPellets%d-Choices.fig',SSN{1},SSN{2},iZ,pellets)],'fig')
            saveas(fh(iZ),[sprintf('%s--%s-Zone%d-nPellets%d-Choices.eps',SSN{2},SSN{2},iZ,pellets)],'epsc')
        end
    catch exception
        disp('Could not save figures.')
    end
end