function fh = FPTplotCPpasses(sd,varargin)
% Plots CP passes.
%
%
%

laps = 1:sd.TotalLaps;
nBin = 25;
tstart = sd.EnteringCPTime;
tend = sd.ExitingCPTime;
process_varargin(varargin);
laps = laps(:)';

if ~isfield(sd,'IdPhi')
    sd = zIdPhiFPT(sd,'tstart',tstart,'tend',tend);
end

Coord = sd.Coord;

cmap = jet(nBin);

LIDP = log10(sd.IdPhi);
LIDP = LIDP(~isnan(LIDP)&~isinf(LIDP));
Z = (LIDP-nanmean(LIDP))/nanstd(LIDP);
Z0 = (log10(sd.IdPhi)-nanmean(LIDP))/nanstd(LIDP);
binEdges = linspace(min(Z),max(Z),nBin+1);
I = identifyBins(Z0,binEdges,'edges',true);
I(I<0) = 1;
I(I>nBin) = nBin;

title(sd.ExpKeys.SSN,'interpreter','none');
caxis([(min(Z)),(max(Z))])

hold on
zlabel(sprintf('Log_{10}[Id\\phi]'))
for iLap=laps
    x0 = data(sd.x.restrict(tstart(iLap),tend(iLap)));
    y0 = data(sd.y.restrict(tstart(iLap),tend(iLap)));
    t0 = range(sd.x.restrict(tstart(iLap),tend(iLap)));
    LogIdPhi = log10(sd.IdPhi(iLap));
    if ~isempty(x0) && ~isinf(LogIdPhi) && ~isnan(LogIdPhi)
        plot3(x0,y0,ones(length(x0),1)*LogIdPhi,'-','color',cmap(I(iLap),:))
        
        idnan = isnan(x0)|isnan(y0);
        xN = interp1(t0(~idnan),x0(~idnan),t0(idnan));
        yN = interp1(t0(~idnan),y0(~idnan),t0(idnan));
        
        plot3(xN,yN,ones(length(xN),1)*LogIdPhi,':','color',cmap(I(iLap),:));
        
    elseif ~isempty(x0) && (isinf(LogIdPhi)||isnan(LogIdPhi))
        plot3(x0,y0,ones(length(x0),1)*min(LIDP),'.','color','k')
    end
    view([0 90])
    drawnow
end
cbh=colorbar;
set(get(cbh,'xlabel'),'string',sprintf('\nZ[Log_{10}[Id\\phi]]'));
axis square
set(gca,'xcolor','w')
set(gca,'ycolor','w')
set(gca,'xtick',[])
set(gca,'ytick',[])
xlim = [Coord.CP_x-sd.InZoneDistance(2) Coord.CP_x+sd.InZoneDistance(2)];
ylim = [Coord.CP_y-sd.InZoneDistance(2) Coord.CP_y+sd.InZoneDistance(2)];
zlim = [min(LIDP) max(LIDP)];
plot3([min(xlim) min(xlim)],[min(ylim) max(ylim)],[min(zlim) min(zlim)],'k:','linewidth',0.25)
plot3([min(xlim) max(xlim)],[max(ylim) max(ylim)],[min(zlim) min(zlim)],'k:','linewidth',0.25)
plot3([min(xlim) min(xlim)],[max(ylim) max(ylim)],[min(zlim) max(zlim)],'k:','linewidth',0.25)
set(gca,'xlim',xlim)
set(gca,'ylim',ylim)
set(gca,'zlim',zlim)

hold off


if nargout>0
    fh = gcf;
end