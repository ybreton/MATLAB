function fh = wrap_RR_plotRMS(VEH,CNO,varargin)
% wrapper to make bar graphs of the root-MSD of thresholds for the effect
% of flavor or amount.
% fh = wrap_RR_plotRMS(CNO,VEH,varargin)
% where         fh      is a list of figure handles produced
%               
%               CNO     is a struct produced by wrap_RR_analysis with CNO data
%               VEH     is a struct produced by wrap_RR_analysis with vehicle data
%
% OPTIONAL ARGUMENTS:
% ******************
% plotFlavor    (default true)          plot flavour effect for each amount:
%                                       sqrt(sum_i[(threshold(Zone_i,pellets)-threshold(AnyZone,pellets))^2]/n)
% plotAmount    (default true)          plot amount effect for each zone:
%                                       sqrt(sum_i[(threshold(zone,Pellet_i)-threshold(zone,AnyPellets))^2]/n)
% fh            (default new two)       figure handles to plot bar graphs:
%                                       places Flavour in fh(1) and Amount in fh(2).
%

plotFlavor = true;
plotAmount = true;
figs = get(0,'children');
if isempty(figs)
    lastFig = 0;
else
    lastFig = max(figs);
end
fh = [lastFig+1 lastFig+2];
process_varargin(varargin);

mRMSflavor(:,1) = nanmean(VEH.RMSflavor)';
mRMSflavor(:,2) = nanmean(CNO.RMSflavor)';
sRMSflavor(:,1) = nanstderr(VEH.RMSflavor)';
sRMSflavor(:,2) = nanstderr(CNO.RMSflavor)';
xFlavor = (1:size(mRMSflavor,1))';

mRMSamount(:,1) = nanmean(VEH.RMSamount)';
mRMSamount(:,2) = nanmean(CNO.RMSamount)';
sRMSamount(:,1) = nanstderr(VEH.RMSamount)';
sRMSamount(:,2) = nanstderr(CNO.RMSamount)';
xAmount = (1:size(mRMSamount,1))';


idnan = all(isnan(mRMSflavor),2);

mRMSflavor = mRMSflavor(~idnan,:);
sRMSflavor = sRMSflavor(~idnan,:);
xFlavor = xFlavor(~idnan);

if plotFlavor
    if length(xFlavor)>1
        figure(fh(1))
        bh=bar(xFlavor,mRMSflavor,0.8);
        childs = get(bh,'children');
        ph(1) = childs{1};
        xpos = nanmean(get(ph(1),'xdata'));
        hold on
        eh=errorbar(xpos,mRMSflavor(:,1),sRMSflavor(:,1));
        set(eh,'linestyle','none')
        set(eh,'color','k')
        hold off
        ph(2) = childs{2};
        xpos = nanmean(get(ph(2),'xdata'));
        hold on
        eh=errorbar(xpos,mRMSflavor(:,2),sRMSflavor(:,2));
        set(eh,'linestyle','none')
        set(eh,'color','k')
        hold off
        set(gca,'xtick',xFlavor);
        set(gca,'box','off')
        xlabel(sprintf('Number of pellets'));
        ylabel(sprintf('Root-mean-squared deviation\nZone threshold from overall for each amount\n(mean across sessions \\pm SEM)'))
        legendStr = {'Vehicle' 'CNO'};
        legend(ph,legendStr);
    else
        figure(fh(1))
        bh=bar(1:2,mRMSflavor,0.8);
        childs = get(bh,'children');
        set(childs,'facecolor',[0.8 0.8 0.8]);
        hold on
        eh=errorbar(1:2,mRMSflavor,sRMSflavor);
        set(eh,'linestyle','none')
        set(eh,'color','k')
        hold off
        set(gca,'xtick',1:2)
        set(gca,'xticklabel',{'Vehicle' 'CNO'})
        set(gca,'box','off')
        xlabel(['Drug condition, ' num2str(xFlavor) ' pellets'])
        ylabel(sprintf('Root-mean-squared deviation\nZone threshold from overall\n(mean across sessions \\pm SEM)'))
        
    end
end

idnan = all(isnan(mRMSamount),2);

mRMSamount = mRMSamount(~idnan,:);
sRMSamount = sRMSamount(~idnan,:);
xAmount = xAmount(~idnan);

if plotAmount
    if length(xAmount)>1
        figure(fh(2))
        bh=bar(xAmount,mRMSamount,0.8);
        childs = get(bh,'children');
        ph(1) = childs{1};
        xpos = nanmean(get(ph(1),'xdata'));
        hold on
        eh=errorbar(xpos,mRMSamount(:,1),sRMSamount(:,1));
        set(eh,'linestyle','none')
        set(eh,'color','k')
        hold off
        ph(2) = childs{2};
        xpos = nanmean(get(ph(2),'xdata'));
        hold on
        eh=errorbar(xpos,mRMSamount(:,2),sRMSamount(:,2));
        set(eh,'linestyle','none')
        set(eh,'color','k')
        hold off
        set(gca,'xtick',xAmount);
        set(gca,'box','off')
        xlabel(sprintf('Zone number'));
        ylabel(sprintf('Root-mean-squared deviation\nPellet threshold from overall for each zone\n(mean across sessions \\pm SEM)'))
        legendStr = {'Vehicle' 'CNO'};
        legend(ph,legendStr);
    else
        figure(fh(1))
        bh=bar(1:2,mRMSamount,0.8);
        childs = get(bh,'children');
        set(childs,'facecolor',[0.8 0.8 0.8]);
        hold on
        eh=errorbar(1:2,mRMSamount,sRMSamount);
        set(eh,'linestyle','none')
        set(eh,'color','k')
        hold off
        set(gca,'xtick',1:2)
        set(gca,'xticklabel',{'Vehicle' 'CNO'})
        set(gca,'box','off')
        xlabel(['Drug condition, zone ' num2str(xAmount)])
        ylabel(sprintf('Root-mean-squared deviation\nPellet threshold from overall\n(mean across sessions \\pm SEM)'))
        
    end
end