function fh = wrap_RR_plotVTEviaCommonGMM(VEH,CNO,varargin)
% Produces a bar graph of the mixture coefficient for each condition, based
% on a Gaussian mixture model fit to all conditions together.
% fh = wrap_RR_plotVTEviaCommonGMM(VEH,CNO)
% where     fh      is a handle to the produced figure
%
%           VEH     is a structure produced by wrap_RR_analysis of vehicle data 
%           CNO     is a structure produced by wrap_RR_analysis of CNO data 
%
% OPTIONAL ARGUMENTS:
% ******************
% fh        (default is next)   handle to figure to place plot.
% k         (default is 2)      number of components in gaussian mixture model. 
% plotBar   (default is true)   plot bar graph alone in addition to subplots. 
%

figs = get(0,'children');
if isempty(figs)
    lastFig = 0;
else
    lastFig = max(figs);
end
fh = [lastFig+1 lastFig+2];
k = 2;
plotBar = true;
process_varargin(varargin);

LogIdPhiAll = log10([VEH.IdPhi(:); CNO.IdPhi(:)]);
idnan = isnan(LogIdPhiAll)|isinf(LogIdPhiAll);
gmobj = gmmfit(LogIdPhiAll(~idnan),k);
idnan = isnan(VEH.IdPhi)|(VEH.IdPhi==0);
[tauLo,tauHi,tauMean,tauMedian]=gmmfitTauCI(gmobj,log10(VEH.IdPhi(~idnan)));
CI(1,1) = tauLo(end);
CI(1,2) = tauHi(end);
m(1,1) = tauMean(end);
idnan = isnan(CNO.IdPhi)|(CNO.IdPhi==0);
[tauLo,tauHi,tauMean,tauMedian]=gmmfitTauCI(gmobj,log10(CNO.IdPhi(~idnan)));
CI(2,1) = tauLo(end);
CI(2,2) = tauHi(end);
m(2,1) = tauMean(end);
L = m-CI(:,1);
U = CI(:,2)-m;
figure(fh(1))
subplot(2,1,1)
idnan = isnan(LogIdPhiAll)|isinf(LogIdPhiAll);
[f,bin]=hist(LogIdPhiAll(~idnan),ceil(sqrt(length(LogIdPhiAll(~idnan)))));
binW = diff(bin);
binW = [binW(1) binW];
bh=bar(bin,f./sum(f),1);
childs=get(bh,'children');
set(childs,'facecolor',[0.8 0.8 0.8])
set(childs,'facealpha',0.3)
hold on
ph(1)=plot(bin,cdf(gmobj,bin'+binW'/2)-cdf(gmobj,bin'-binW'/2),'r-','linewidth',2);
ph(2)=plot(gmobj.mu,zeros(k,1),'r.');
legend([childs ph],{'All conditions' sprintf('%d-component GMM fit',k) sprintf('Component means')});
hold off
xlabel(sprintf('Log_{10}[I d\\phi]'));
ylabel(sprintf('Proportion of all laps'));

subplot(2,1,2)
bh=bar(m);
childs = get(bh,'children');
hold on
errorbar(1:2,m,L,U,'linestyle','none','color','k');
set(childs,'facecolor',[0.8 0.8 0.8])
hold off
set(gca,'xtick',1:2)
set(gca,'xticklabel',{'Vehicle' 'CNO'})
ylabel(sprintf('P[VTE]\nBased on mixture fit to all conditions\n(Mean \\pm 95%% bootstrap CI)'));

if ~plotBar
    fh(2) = [];
else
    figure(fh(2));
    bh=bar(m);
    childs = get(bh,'children');
    hold on
    errorbar(1:2,m,L,U,'linestyle','none','color','k');
    set(childs,'facecolor',[0.8 0.8 0.8])
    hold off
    set(gca,'xtick',1:2)
    set(gca,'xticklabel',{'Vehicle' 'CNO'})
    ylabel(sprintf('P[VTE]\nBased on mixture fit to all conditions\n(Mean \\pm 95%% bootstrap CI)'));
end