function ph = plot_choice_segment_switchprob_overlay(InDelay,fit,varargin)

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

for k = 1 : K
    laps = [Start(k):Finish(k)];
    P(1,2) = fit(2,k);
    P(2,1) = fit(3,k);
    P(1,1) = 1 - P(1,2);
    P(2,2) = 1 - P(2,1);
    ap = sum(P,1);
    
    ph0(k+1)=plot(laps,ones(length(laps),1)*ap(2)./sum(ap),'-','color',cmap(k,:),'linewidth',4);
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