function [fh,ah,ph] = RRplotSpikeRaster(S,t,varargin)
% Plots the raster of peri-event spike times with the Gaussian-smoothed
% spike rate overlain on top.
%
% [fh,ah,ph] = RRplotSpikeRaster(S,t)
% where         fh          is a handle to the figure
%               ah          is a 1x2 handle to each axis
%                               (ah(1) is handle to raster;
%                                ah(2) is handle to spike rate)
%               ph          is a nCells x 2 handle to each plot object
%
%               S           is a ts of spike times
%               t           is event times to align to
%
% or
%               S           is a cell array of spike time ts structures.
%
% OPTIONAL ARGUMENTS:
% ******************
% sigma         (default 50ms)
%                           width of Gaussian smoother
% window        (default [-2 5])
%                           peri-event window
% dt            (default 0.01)
%                           PETH bin size.
% markersize    (default 1)
%                           raster marker size
% linewidth     (default 2)
%                           spike rate line width
% fh            (default gcf)
%                           figure handle
% ah            (default gca)
%                           axes handle to raster plot
%
sigma = 50/1000;
window = [-2 5];
dt = 0.01;
markersize = 1;
linewidth = 2;
fh= gcf;
ah = gca;
process_varargin(varargin);

assert(isa(S,'ts')|iscell(S),'Spike list must be ts or a cell array of ts''s.')

if iscell(S)
    emptyCell = true(length(S(:)),1);
    nottsd = nan(length(S),1);
    for c=1:length(S(:));
        S0=S{c};
        if ~isempty(S0)
            nottsd(c) = ~isa(S0,'ts');
            emptyCell(c) = false;
        end
    end
    assert(any(~emptyCell),'Cell array of spike times is empty.')
    assert(all(nottsd~=1),'Cell array of spike times contains non-ts elements.')
end

h = ishold;
ah(2) = axes('position',get(ah(1),'position'));

if iscell(S)
    sz = size(S);
    didx = cell(length(sz),1);
    for dim=1:length(sz)
        indices = (1:sz(dim))';
        
        res = sz;
        res((1:length(sz))~=dim) = 1;
        resIndices = reshape(indices,res);
        
        rep = sz;
        rep(dim) = 1;
        
        repIndices = repmat(resIndices,rep);
        
        didx{dim} = repIndices(:);
    end
    S = S(~emptyCell);
    cmap = jet(length(S));
    ph = nan(length(S),2);
    legendStr = cell(length(S),1);
    spikeRateFcn = smoothedPEspikeRate(S,t,'window',window,'dt',dt,'sigma',sigma);
    
    for iC=1:length(S)
        if ~isempty(S{iC})
            [~,outputS,outputT] = spikePETH(S{iC},t,'window',window,'dt',dt);
            set(fh,'currentaxes',ah(1))
            hold on
            ph(iC,1) = plot(outputS,outputT,'.','markerfacecolor',cmap(iC,:),'markeredgecolor',cmap(iC,:),'markersize',markersize);
            set(ah(1),'ylim',[1 max(max(get(ah(1),'ylim')),max(outputT))])
            set(fh,'currentaxes',ah(2))
            hold on
            if any(~isnan(spikeRateFcn{iC}.data))
                ph(iC,2)=plot(spikeRateFcn{iC}.range,spikeRateFcn{iC}.data,'-','color',cmap(iC,:),'linewidth',linewidth);
                set(ah(2),'ylim',[0 max(max(get(ah(2),'ylim')),max(spikeRateFcn{iC}.data))])
            end
            str = 'S\{';
            for dim=1:length(didx)
                str = [str sprintf('%d,',didx{dim}(iC))];
            end
            str = str(1:end-1);
            str = [str '\}'];
            legendStr{iC} = str;
        end
    end
    idnan = any(isnan(ph),2);
    ph = ph(~idnan,:);
    legendStr = legendStr(~idnan);
    legend(ph(:,1),legendStr,'location','northeastoutside');
else
    [~,outputS,outputT] = spikePETH(S,t,'window',window,'dt',dt);
    spikeRateFcn = smoothedPEspikeRate(S,t,'window',window,'dt',dt,'sigma',sigma);
    set(fh,'currentaxes',ah(1))
    hold on
    ph(1)=plot(outputS,outputT,'.k','markersize',markersize);
    set(ah(1),'ylim',[1 max(max(get(ah(1),'ylim')),max(outputT))])
    set(fh,'currentaxes',ah(2))
    hold on
    if any(~isnan(spikeRateFcn.data))
        ph(1,2)=plot(spikeRateFcn.range,spikeRateFcn.data,'-k','linewidth',linewidth);
        set(ah(2),'ylim',[0 max(max(get(ah(2),'ylim')),max(SRt.data))])
    end
end
hold off

set(ah,'box','off')
set(ah,'xlim',window)

set(get(ah(1),'xlabel'),'string','Time aligned to event')
set(get(ah(1),'ylabel'),'string','Event #')
set(get(ah(2),'ylabel'),'string','Hz')

set(ah(2),'yaxislocation','right')
set(ah(2),'color','none')
set(ah(2),'xtick',[])

set(ah(2),'position',get(ah(1),'position'))

if h; hold on; end