function cp = recursively_get_choice_changes(sd,crit,plotFlag)

if nargin < 3
    plotFlag = 0;
end

cp0 = [0 length(sd.ZoneIn)];
% each change point in the list cp divides the laps into a segment before
% the CP and a segment after the CP.

newCP = 1;
while newCP>0
    newCP = 0;
    start = cp0(1:length(cp0)-1)+1;
    finish = cp0(2:length(cp0));
    for c = 1 : length(start)
        laps = start(c):finish(c);
        choices = sd.ZoneIn(laps);
        [LogORs,LnL1,LnL0] = calculateLogORs(laps,choices,sd.DelayZone);
        idCP = ((LnL1)>crit);
        cp = [cp0 laps(idCP)];
        newCP = newCP + (length(cp)-length(cp0));
        cp0 = sort(cp);
    end
end
cp = sort(cp0);

if plotFlag
    laps = 1:length(sd.ZoneIn);
    DelayLaps = laps(sd.ZoneIn==sd.DelayZone);
    NondelayLaps = laps(sd.ZoneIn~=sd.DelayZone);
    AllDelayZoneDelay = nan(length(sd.ZoneIn),1);
    if ~isempty(DelayLaps)
        AllDelayZoneDelay(1:DelayLaps(1)) = sd.ZoneDelay(DelayLaps(1));
        for l = 2 : length(DelayLaps)
            AllDelayZoneDelay(DelayLaps(l-1):DelayLaps(l)) = sd.ZoneDelay(DelayLaps(l));
        end
        AllDelayZoneDelay(DelayLaps(end):end) = sd.ZoneDelay(DelayLaps(end));
    end
    AllNondelayZoneDelay = nan(length(sd.ZoneIn),1);
    if ~isempty(NondelayLaps)
        AllNondelayZoneDelay(1:NondelayLaps(1)) = sd.ZoneDelay(NondelayLaps(1));
        for l = 2 : length(NondelayLaps)
            AllNondelayZoneDelay(NondelayLaps(l-1):NondelayLaps(l)) = sd.ZoneDelay(NondelayLaps(l));
        end
        AllNondelayZoneDelay(NondelayLaps(end):end) = sd.ZoneDelay(NondelayLaps(end));
    end
    
    clf
    cla
    subplot(2,1,1)
    hold on
    start = cp0(1:length(cp0)-1)+1;
    finish = cp0(2:length(cp0));
    cmap = hsv(length(start));
    for c = 1 : length(start)
        laps = start(c):finish(c);
        choices = sd.ZoneIn(laps);
        LogORs = calculateLogORs(laps,choices,sd.DelayZone);
        plot(laps,LogORs,'-','color',cmap(c,:),'linewidth',2)
    end
    ylabel('Log-OR of no change')
    hold off
    subplot(2,1,2)
    hold on
    xlabel('lap')
    ylabel('delay')
    for c = 1 : length(start)
        laps = start(c):finish(c);
        plot(laps,AllDelayZoneDelay(laps),'-','color',cmap(c,:),'linewidth',2)
    end
    hold off
end


function [LogORs,LnL1,LnL0] = calculateLogORs(laps,ZoneIn,ZoneD)

p0 = ones(length(laps),1);
p1a = ones(length(laps),1);
p1b = ones(length(laps),1);
LnL0 = ones(length(laps),1);
LnL1a = ones(length(laps),1);
LnL1b = ones(length(laps),1);
for l = 2 : length(laps)-1
    c = laps(l);
    p0(l) = binofit(sum(double(ZoneIn(laps)==ZoneD)),length(ZoneIn(laps)));
    p1a(l) = binofit(sum(double(ZoneIn(laps<=c)==ZoneD)),length(ZoneIn(laps<=c)));
    p1b(l) = binofit(sum(double(ZoneIn(laps>c)==ZoneD)),length(ZoneIn(laps>c)));
    LnL0(l) = log10(binopdf(sum(double(ZoneIn(laps)==ZoneD)),length(ZoneIn(laps)),p0(l)));
    LnL1a(l) = log10(binopdf(sum(double(ZoneIn(laps<=c)==ZoneD)),length(ZoneIn(laps<=c)),p1a(l)));
    LnL1b(l) = log10(binopdf(sum(double(ZoneIn(laps>c)==ZoneD)),length(ZoneIn(laps>c)),p1a(l)));
end
LogORs = (LnL1a+LnL1b)-LnL0;
LnL1 = LnL1a+LnL1b;