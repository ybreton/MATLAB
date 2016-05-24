function fh=RRdayToDay(fn)
% Plots day-to-day choice performance on restaurant row.
% fh=RRdayToDay(fn)
% where    fh      is a handle to produced figures. 
%
%          fn      is a string or cell array of strings with file name
%                       containing RR data, 'RR-SSN-time.mat'
% RRdayToDay will produce one figure for each 'RR-SSN-time.mat' file in the
% current directory.

if nargin<1
    fn = FindFiles('RR-*.mat','CheckSubdirs',false);
end

if ischar(fn)
    fn = {fn};
end
curFigs = get(0,'children');
if isempty(curFigs)
    lastFig = 0;
else
    lastFig = max(curFigs);
end
fh = [lastFig+1:lastFig+length(fn(:))];

cmap2 = RRColorMap;
cmap1 = cmap2;
cmap1(3,:) = [0 0 0];
flavour = {'Cherry' 'Banana' 'Plain White' 'Chocolate'};
for iF = 1 : length(fn)
    disp(fn{iF})
    sd = load(fn{iF});
    sg = ismember(sd.ExitZoneTime,sd.FeederTimes);
    staygo = nan(1,length(sd.EnteringZoneTime));
    staygo(1:length(sg)) = sg;
    delays = sd.FeederDelay;
    zones = sd.ZoneIn;
    nReps = ceil(length(staygo)/length(sd.nPellets));
    pellets = repmat(sd.nPellets(:)',1,nReps);
    pellets = pellets(1:length(staygo));
    predX = unique(sd.FeederDelay(~isnan(sd.FeederDelay)));
    figure(fh(iF))
    set(gcf,'name',fn{iF})
    for iZ = 1 : 4
        idZ = zones == iZ;
        x = delays(idZ);
        y = staygo(idZ);
        th = RRheaviside(x(:),y(:));
        predY = predX<th;
        predY(predX==th) = 0.5;
        nP = unique(pellets(idZ));
        subplot(2,2,iZ)
        cla
        hold on
        title(sprintf('%s\nZone %d, %d pellets',flavour{iZ},iZ,nP))
        plot(x(:),y(:)+randn(length(x),1)/100,'o','markeredgecolor',cmap1(iZ,:),'markerfacecolor',cmap2(iZ,:))
        plot(predX,predY,'-','color',cmap1(iZ,:))
        plot(th,0.5,'x','markeredgecolor',cmap1(iZ,:))
        hold off
        set(gca,'ylim',[-0.05 1.05])
        set(gca,'ytick',[0 1])
        set(gca,'yticklabel',{'Go' 'Stay'})
        set(gca,'xlim',[min(sd.FeederDelay(:))-1 max(sd.FeederDelay(:))+1])
        xlabel('Delay (sec)')
        ylabel('Choice')
    end
end