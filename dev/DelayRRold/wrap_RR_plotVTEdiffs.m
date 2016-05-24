function fh = wrap_RR_plotVTEdiffs(VEH,CNO,varargin)
% wrapper for plotting difference in histograms based on log10(IdPhi).
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

figure(fh);
plot(binVEH,fCNO/sum(fCNO)-fVEH/sum(fVEH),binVEH,zeros(1,length(binVEH)));
xlabel(sprintf('Log_{10}[I d\\phi]'));
ylabel(sprintf('\\Delta Proportion of laps\nCNO - VEH'));

