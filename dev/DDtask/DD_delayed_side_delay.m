function [delayed_side_delay,Contingency,fh,stats] = DD_delayed_side_delay(sd)
%
%
%
%

DelayZone = sd.DelayZone;
Delay = sd.ZoneDelay;
ZoneIn = sd.ZoneIn;
InDelay = sd.ZoneIn==DelayZone;
NonDelayZone = unique(ZoneIn(~InDelay));

DelayWhenDelayChosen = Delay(InDelay);
NonDelayWhenNonDelayChosen = Delay(~InDelay);
StartingDelay = DelayWhenDelayChosen(1);
StartingNonDelay = NonDelayWhenNonDelayChosen(1);

% Zone=3 is L
% Zone=4 is R

% Contingency is a linear input-output matrix.
% rows: input zones chosen
% columns: output zones updated
% entry (r,c) : change in delay for zone c when choosing zone r.

Contingency = zeros(4,4);

Contingency(3,4) = sd.World.incrRgoL; % increase in zone 4 by choosing zone 3
Contingency(4,4) = sd.World.incrRgoR; % increase in zone 4 by choosing zone 4
Contingency(3,3) = sd.World.incrLgoL; % increase in zone 3 by choosing zone 3
Contingency(4,3) = sd.World.incrLgoR; % increase in zone 3 by choosing zone 4

LastZone = ZoneIn(1);
delay_side_delay(1) = StartingDelay;
nondelay_side_delay(1) = StartingNonDelay;
for lap = 2 : length(ZoneIn)
    LastZone = ZoneIn(lap-1);
    if ZoneIn(lap)==LastZone
        % update delay.
        zoneList = false(1,4);
        zoneList(ZoneIn(lap)) = true;
        DelayList = zoneList*Contingency;
        delay_side_delay(1,lap) = delay_side_delay(lap-1)+DelayList(DelayZone);
        nondelay_side_delay(:,lap) = nondelay_side_delay(:,lap-1)+DelayList(NonDelayZone);
    else
        delay_side_delay(1,lap) = delay_side_delay(1,lap-1);
        nondelay_side_delay(:,lap) = nondelay_side_delay(:,lap-1);
    end
end
delayed_side_delay = delay_side_delay(:);

if nargout>2
    fh = gcf;
    clf
    cla
    title('Performance on DD')
    hold on
    ph(1)=plot(delay_side_delay,'k-','linewidth',2);
    xlabel('Lap')
    ylabel('Delay on delayed side')
    set(gca,'xlim',[0 length(delay_side_delay)+1])
    set(gca,'xtick',[0:10:length(delay_side_delay)])
    set(gca,'ylim',[0 max(delay_side_delay)+1])
    set(gca,'ytick',[0:1:max(delay_side_delay)])
    hold off
end
if nargout>3
    [M,P,stats] = CPRBayes(delayed_side_delay,'linear');
    hold on
    for seg = 2 : length(M)
        start = M(seg-1)+1;
        finish = M(seg);
        yPred = [1 0;1 finish-start]*stats.params{seg-1,1};
        plot([start;finish],yPred,'r-')
    end
    hold off
end