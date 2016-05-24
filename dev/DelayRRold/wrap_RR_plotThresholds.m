function fh=wrap_RR_plotThresholds(analysisStruct,plotRow,varargin);
% Wrapper for plotting restaurant row thresholds.
% fh = wrap_RR_plotThresholds(analysisStruct,plotRow)
% where         fh                  is a list of handles to figure objects created.        
%
%               analysisStruct      is a structure array produced by wrap_RR_analysis containing nSess x nTrials fields:
%                                   .pellets,
%                                   .delays,
%                                   .staygo,
%                                   .zones,
%                                   .thresholds
%               plotRow             is the row to plot in for each zone.
%
% OPTIONAL ARGUMENTS:
% *******************
% titleStr      (default blank)     label all plots with this label
% fh            (default next two)  figure handles to plot in

titleStr = '';
figs = get(0,'children');
if isempty(figs)
    lastFig = 0;
else
    lastFig = max(figs);
end
uniqueNs = unique(analysisStruct.pellets(~isnan(analysisStruct.pellets)));
fh = [lastFig+1:lastFig+length(uniqueNs)];
process_varargin(varargin);
assert(length(fh)==length(uniqueNs),'Length of supplied figure handle list must equal length of unique pellet amounts.')

for iFig = 1 : length(fh)
    figure(fh(iFig));
end

cmap = RRColorMap;
for iN = 1 : length(uniqueNs)
    figure(fh(iN));
    pellets = uniqueNs(iN);
    idPellets = analysisStruct.pellets==pellets;
    for iZ = 1 : 4
        idZone = analysisStruct.zones==iZ;
        idZN = idZone & idPellets;
        znThresh = squeeze(analysisStruct.thresholds(:,iZ,pellets));

        subplot(2,4,(plotRow-1)*4+iZ)
        if ~isempty(titleStr)
            title([titleStr ':' num2str(iZ) ', ' num2str(pellets) ' pellets'])
        else
            title(['Zone ' num2str(iZ) ', ' num2str(pellets) ' pellets'])
        end

        hold on

        X = analysisStruct.delays;
        Y = analysisStruct.staygo;

        ph(1)=plot(X(:),Y(:)+randn(length(Y(:)),1)/100,'ko','markerfacecolor',cmap(iZ,:));
        ph(2)=plot((1:30),(1:30)<nanmean(znThresh),'k-');
        ph(3)=plot(znThresh,ones(length(znThresh),1)*0.5,'ks','markerfacecolor',cmap(iZ,:));
        legendStr = {sprintf('Data (\\pm jitter)') 'Fit' 'Thresholds'};
        legend(ph,legendStr);
        hold off
        set(gca,'xlim',[0 45])
        ytick=get(gca,'ytick');
        ytick(ytick<0|ytick>1) = [];
        set(gca,'ytick',ytick)
    end
end