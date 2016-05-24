function fh = wrap_RR_plotVTEviaGMM(VEH,CNO,varargin)
% wrapper for plotting probability of VTE based on Gaussian mixture fit to IdPhi.
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

m(1) = VEH.pVTE.mixCoeffs(end);
m(2) = CNO.pVTE.mixCoeffs(end);
lo(1) = VEH.pVTE.mixCoeffCIs(1,end);
hi(1) = VEH.pVTE.mixCoeffCIs(2,end);
lo(2) = CNO.pVTE.mixCoeffCIs(1,end);
hi(2) = CNO.pVTE.mixCoeffCIs(2,end);
exlo = m-lo;
exhi = hi-m;

bh=bar(1:2,m,0.8);
childs=get(bh,'children');
hold on
eh=errorbar(1:2,m,exlo,exhi);
set(eh,'linestyle','none')
set(eh,'color','k')
set(childs,'facecolor',[0.8 0.8 0.8])
hold off
set(gca,'xtick',1:2)
set(gca,'xticklabel',{'Vehicle' 'CNO'})
ylabel(sprintf('Probability of VTE\n(mean high-component mixture coefficient \\pm 95%% bootstrap CI)'));
