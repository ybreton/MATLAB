function fh = wrap_RR_plotVTEhists(VEH,CNO,varargin)
% wrapper for plotting log10(IdPhi) histograms.
% [pVTE,pLaps,fh] = wrap_RR_VTE(CNO,VEH)
%               fh      is a list of handles to figures produced.
%
%               CNO     is a structure produced by wrap_RR_analysis with
%                           CNO data.
%               VEH     is a structure produced by wrap_RR_analysis with
%                           vehicle data.
% OPTIONAL ARGUMENTS:
% ******************
% nBins         (default 50)    number of bins for histogram
% fh            (default next)  figure handle to place plot
%
nBins = 50;
figs = get(0,'children');
if isempty(figs)
    lastFig = 0;
else
    lastFig = max(figs);
end
fh = lastFig+1;
process_varargin(varargin);

[fCNO,binCNO] = hist(log10(CNO.IdPhi),linspace(1,3,nBins));
[fVEH,binVEH] = hist(log10(VEH.IdPhi),linspace(1,3,nBins));

figure(fh(1));
ph=plot(binVEH,fVEH/sum(fVEH),binCNO,fCNO/sum(fCNO));
xlabel(sprintf('Log_{10}[I d\\phi]'));
ylabel(sprintf('Proportion of laps'));
legendStr = {'Vehicle' 'CNO'};
legend(ph,legendStr);
