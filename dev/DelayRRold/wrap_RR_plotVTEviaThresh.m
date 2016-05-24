function fh = wrap_RR_plotVTEviaThresh(VEH,CNO,varargin)
% wrapper for plotting proportion of VTE as measured by arbitrary log10(IdPhi) criterion.
% [pVTE,pLaps,fh] = wrap_RR_VTE(CNO,VEH)
%               fh      is a list of handles to figures produced.
%
%               CNO     is a structure produced by wrap_RR_analysis with
%                           CNO data.
%               VEH     is a structure produced by wrap_RR_analysis with
%                           vehicle data.
%
% OPTIONAL ARGUMENTS:
% ******************
% fh        (default next)      figure handle to place plot
%

figs = get(0,'children');
if isempty(figs)
    lastFig = 0;
else
    lastFig = max(figs);
end
fh = lastFig+1;
process_varargin(varargin);

figure(fh);
pVTE_VEH = VEH.pVTE.byThreshold;
pVTE_CNO = CNO.pVTE.byThreshold;

bh=bar(1:2,[nanmean(pVTE_VEH) nanmean(pVTE_CNO)],0.8);
childs=get(bh,'children');
hold on
eh=errorbar(1:2,[nanmean(pVTE_VEH) nanmean(pVTE_CNO)],[nanstderr(pVTE_VEH) nanstderr(pVTE_CNO)]);
set(eh,'linestyle','none')
set(eh,'color','k')
set(childs,'facecolor',[0.8 0.8 0.8])
hold off
set(gca,'xtick',1:2)
set(gca,'xticklabel',{'Vehicle' 'CNO'})
ylabel(sprintf('Proportion of laps with Log_{10}[I d\\phi] > %.2f\n(mean \\pm SEM)',VEH.pVTE.VTEthresh));

