function ph = plot_choice_segment_overlay(fit,InDelay,varargin)
%
%
%
%

ExclusionRange = 0.1;
process_varargin(varargin);

K = size(fit,2);
cmap = jet(K);
cla
[Start,Finish]=StartFinishLap(fit(1,:));
hold on
ph0(1) = plot([1:numel(InDelay)],InDelay(:),'k.','markersize',20);
plot([1:numel(InDelay)],InDelay(:),':','color',[0.6 0.6 0.6],'linewidth',0.5)

Xpatch = [0 0 numel(InDelay)+1 numel(InDelay)+1];
Ypatch = [mean(fit(2,1:2:end))-ExclusionRange mean(fit(2,1:2:end))+ExclusionRange ...
    mean(fit(2,1:2:end))+ExclusionRange mean(fit(2,1:2:end))-ExclusionRange];

patch(Xpatch,Ypatch,[1 1 1],'edgecolor','none','facecolor',[0.8 0.8 0.8],'facealpha',0.2)
for k = 1 : K
    laps = [Start(k):Finish(k)];
    ph0(k+1)=plot(laps,ones(length(laps),1)*fit(2,k),'-','color',cmap(k,:),'linewidth',4);
end
xlabel('Lap')
ylabel('Choice')
set(gca,'xlim',[1-0.5 max(Finish)+0.5])
set(gca,'ylim',[-0.05 1.05])
set(gca,'ytick',[0 1])
set(gca,'yticklabel',{'Nondelayed' 'Delayed'})
hold off

if nargout>0
    ph = ph0;
end