function [fh,stats] = DD_plot_chosen_delay(sd)
%
%
%
%

DelayZone = sd.DelayZone;
Delay = sd.ZoneDelay;
ZoneIn = sd.ZoneIn;
InDelay = sd.ZoneIn==DelayZone;
NonDelayZone = unique(ZoneIn(~InDelay));
laps = 1:length(ZoneIn);
DelayLaps = laps(InDelay);
NondelayLaps = laps(~InDelay);

% Zone=3 is L
% Zone=4 is R

pellets(3) = sd.World.nPleft;
pellets(4) = sd.World.nPright;

pelletsDelay = pellets(DelayZone);
pelletsNondelay = pellets(NonDelayZone);

DelayWhenDelayChosen = Delay(InDelay);
NonDelayWhenNonDelayChosen = Delay(~InDelay);

RunningD = zeros(length(laps),1);
RunningND = zeros(length(laps),1);
if ~isempty(DelayWhenDelayChosen)
    RunningD(1:DelayLaps(1)) = DelayWhenDelayChosen(1);
    RunningD(DelayLaps(end):end) = DelayWhenDelayChosen(end);
end
if ~isempty(NonDelayWhenNonDelayChosen)
    RunningND(1:NondelayLaps(1)) = NonDelayWhenNonDelayChosen(1);
    RunningND(NondelayLaps(end):end) = NonDelayWhenNonDelayChosen(end);
end
for l = 2 : length(DelayLaps)
    RunningD(DelayLaps(l-1):DelayLaps(l)-1) = DelayWhenDelayChosen(l-1);
end

for l = 2 : length(NondelayLaps)
    RunningND(NondelayLaps(l-1):NondelayLaps(l)-1) = NonDelayWhenNonDelayChosen(l-1);
end

clf
fh=gcf;
cla

hold on
ph(1)=plot(laps,RunningD,'k-','linewidth',2);
legendStr{1} = sprintf('Delayed side,\n%d pellets',pelletsDelay);
if ~isempty(DelayLaps)
    ph(2)=plot(DelayLaps,DelayWhenDelayChosen,'ko','markersize',6);
else
    ph(2)=plot(NaN,NaN,'ko','markersize',6);
end
legendStr{2} = sprintf('(Delay chosen)');
ph(3)=plot(laps,RunningND,'-','color',[0.8 0.8 0.8]);
legendStr{3} = sprintf('Non-Delayed side,\n%d pellets',pelletsNondelay);
if ~isempty(NondelayLaps)
    ph(4)=plot(NondelayLaps,RunningD(NondelayLaps),'x','markersize',6,'markerfacecolor',[0.8 0.8 0.8],'markeredgecolor',[0.8 0.8 0.8]);
else
    ph(4)=plot(NaN,NaN,'ko','markersize',6);
end
legendStr{4} = sprintf('(Non-delay chosen)');

[M,P,stats] = CPRBayes(RunningD(:),'linear');
[Mbin,Pbin,statsbin] = CPRBayes(InDelay(:),'binomial');


for seg = 1 : size(stats.params,1)
    p = stats.params{seg,1};
    slope(seg) = p(2);
end
[minSlope,id] = min(abs(slope));

for seg = 2 : length(M)
    start = M(seg-1)+1;
    finish = M(seg);
    meanDelay(seg-1) = mean(RunningD(start:finish));
    yPred = [1 0;1 finish-start]*stats.params{seg-1,1};
    ph(5)=plot([start;finish],yPred,'r-','linewidth',1);
    th=text(finish,max(RunningD(start:finish)),sprintf('D=%.1f',meanDelay(seg-1)));
    set(th,'verticalalignment','bottom')
    set(th,'horizontalalignment','left')
end
legendStr{5} = sprintf('MML Linear Segment Fit to delay');
for seg = 2 : length(Mbin)
    start = Mbin(seg-1)+1;
    finish = Mbin(seg);
    ph(6)=plot([start;finish],[(seg-2)*0.1 (seg-2)*0.1],'g-');
end
legendStr{6} = sprintf('MML Binomial Segment Fit to choice');

ymin = min(Delay)-1;
ymax = max(Delay)+1;
set(gca,'ylim',[ymin ymax])
xh = xlabel('Lap');
yh = ylabel('Delay');

lh = legend(ph,legendStr);
set(lh,'location','northeastoutside')
hold off