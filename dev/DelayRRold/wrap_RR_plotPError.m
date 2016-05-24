function fh = wrap_RR_plotPError(VEH,CNO,nPellets,varargin)
% Wrapper to plot the proportion of error choices (staying when should
% skip, skipping when should stay) under vehicle and CNO.
% fh = wrap_RR_plotPError(VEH,CNO,nPellets)
% where     fh          is a vector of handles to produced plot objects, a
%                           boxplot of the decision instability values and
%                           a bargraph of the mean instability.
%
%           VEH         is a structure produced by  
%
% 
curFigs = get(0,'children');
if isempty(curFigs)
    lastFig = 0;
else
    lastFig = max(curFigs);
end
fh = lastFig+1:lastFig+2;
process_varargin(varargin);

if ~isempty(VEH)
    VEH = RRDecisionInstability(VEH);
end
if ~isempty(CNO)
    CNO = RRDecisionInstability(CNO);
end

    m0 = nan;
    g0 = nan;
    if ~isempty(VEH)
        m0 = nan(size(VEH.isError,1),1);
        g0 = zeros(size(VEH.isError,1),1);
        for iSess = 1 : size(VEH.isError,1)
            m0(iSess) = nansum(VEH.isError(iSess,VEH.pellets(iSess,:)==nPellets))./(nansum(VEH.isError(iSess,VEH.pellets(iSess,:)==nPellets))+nansum(VEH.isCorrect(iSess,VEH.pellets(iSess,:)==nPellets)));
        end
    end
    
    m1 = nan;
    g1 = nan;
    if ~isempty(CNO)
        m1 = nan(size(CNO.isError,1),1);
        g1 = ones(size(CNO.isError,1),1);
        for iSess = 1 : size(CNO.isError,1)
            m1(iSess) = nansum(CNO.isError(iSess,CNO.pellets(iSess,:)==nPellets))./(nansum(CNO.isError(iSess,CNO.pellets(iSess,:)==nPellets))+nansum(CNO.isCorrect(iSess,CNO.pellets(iSess,:)==nPellets)));
        end
    end
    idnan0 = isnan(m0);
    idnan1 = isnan(m1);
    m0 = m0(~idnan0);
    g0 = g0(~idnan0);
    m1 = m1(~idnan1);
    g1 = g1(~idnan1);
    
    if ~isempty(m0)&&~isempty(m1)
        figure(fh(1));
        title(sprintf('%d Pellets',nPellets))
        hold on
        boxplot([m0(:);m1(:)],[g0(:);g1(:)],'labels',{'Vehicle' 'CNO'})
        plot(ones(length(m0),1),m0,'ko','markerfacecolor','k')
        plot(ones(length(m1),1)*2,m1,'ko','markerfacecolor','k')
        ylabel(sprintf('Decision instability\n(P[Error])'))
        hold off
        
        figure(fh(2));
        title(sprintf('%d Pellets',nPellets))
        hold on
        [bh,eh,ch]=barerrorbar([0;1],[nanmean(m0);nanmean(m1)],[nanstderr(m0);nanstderr(m1)]);
        set(gca,'xticklabel',{'Vehicle' 'CNO'})
        set(ch,'facecolor',[0.8 0.8 0.8])
        set(eh,'color','k')
        ylabel(sprintf('Decision instability\n(mean P[Error] \\pm SEM)'))
        hold off
    end
    
    if ~isempty(m0)&&isempty(m1)
        figure(fh(1));
        title(sprintf('Vehicle\n%d Pellets',nPellets))
        hold on
        boxplot(m0(:))
        plot(ones(length(m0),1),m0,'ko','markerfacecolor','k')
        ylabel(sprintf('Decision instability\n(P[Error])'))
        hold off
        
        figure(fh(2));
        title(sprintf('Vehicle\n%d Pellets',nPellets))
        hold on
        [bh,eh,ch]=barerrorbar(1,nanmean(m0),nanstderr(m0));
        set(gca,'xtick',[])
        set(ch,'facecolor',[0.8 0.8 0.8])
        set(eh,'color','k')
        ylabel(sprintf('Decision instability\n(mean P[Error] \\pm SEM)'))
        hold off
    end
    
    if isempty(m0)&&~isempty(m1)
        figure(fh(1));
        title(sprintf('CNO\n%d Pellets',nPellets))
        hold on
        boxplot(m1(:))
        plot(ones(length(m1),1),m1,'ko','markerfacecolor','k')
        ylabel(sprintf('Decision instability\n(P[Error])'))
        hold off
        
        figure(fh(2));
        title(sprintf('CNO\n%d Pellets',nPellets))
        hold on
        [bh,eh,ch]=barerrorbar(1,nanmean(m1),nanstderr(m1));
        set(gca,'xtick',[])
        set(ch,'facecolor',[0.8 0.8 0.8])
        set(eh,'color','k')
        ylabel(sprintf('Decision instability\n(mean P[Error] \\pm SEM)'))
        hold off
    end
end