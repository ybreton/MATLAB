function fh = RRplotAllThresholds(varargin)
%
%
%
%

fd = pwd;
curFigs = get(0,'Children');
if isempty(curFigs)
    lastFig = 0;
else
    lastFig = max(curFigs);
end
fh = lastFig+1;
flavours = {'Cherry' 'Banana' 'Plain White' 'Chocolate' 'Overall'};
process_varargin(varargin);
cd(fd);


fn0 = FindFiles('*-Veh.mat');
fn1 = FindFiles('*-CNO.mat');

m = nan(5,2,3);
s = nan(5,2,3);
for iF=1:length(fn0);
    load(fn0{iF})
    nPellets = unique(VEH.pellets(~isnan(VEH.pellets)));
    for p = nPellets'
        m(1:4,1,p) = nanmean(VEH.thresholds(:,:,p),1)';
        s(1:4,1,p) = nanstderr((VEH.thresholds(:,:,p)))';
        m(5,1,p) = nanmean(VEH.marginalZonebyPellet(:,1,p));
        s(5,1,p) = nanstderr(VEH.marginalZonebyPellet(:,1,p));
    end
    
end
for iF=1:length(fn1);
    load(fn1{iF})
    nPellets = unique(CNO.pellets(~isnan(CNO.pellets)));
    for p = nPellets'
        m(1:4,2,p) = nanmean(CNO.thresholds(:,:,p),1)';
        s(1:4,2,p) = nanstderr(CNO.thresholds(:,:,p))';
        m(5,2,p) = nanmean(CNO.marginalZonebyPellet(:,1,p));
        s(5,2,p) = nanstderr(CNO.marginalZonebyPellet(:,1,p));
    end
end


for p = 1:size(m,3);
    figure(fh);
    subplot(1,size(m,3),p)
    hold on
    [bh,eh,ch]=barerrorbar((1:5)',squeeze(m(:,:,p)),s(:,:,p));
    legend(ch,{'Vehicle' 'CNO'})
    set(eh,'linestyle','none')
    set(eh,'color','k')
    set(ch,'linewidth',2)
    set(eh,'linewidth',1)
    hold off
    set(gca,'ylim',[0 35])
    set(gca,'xticklabel',flavours)
    title(sprintf('%d pellets',p))
end