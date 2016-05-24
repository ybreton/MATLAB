function fh = plot_odds_change_choice(sd)

ZoneIn = sd.ZoneIn;
ZoneD = sd.DelayZone;
Delay = sd.ZoneDelay;
laps = 1:length(ZoneIn);

LnL0 = ones(length(ZoneIn),1);
LnL1a = ones(length(ZoneIn),1);
LnL1b = ones(length(ZoneIn),1);
for c = 2 : length(ZoneIn)-1
    p0(c) = sum(double(ZoneIn(laps~=c)==ZoneD))/length(ZoneIn(laps~=c));
    p1a(c) = sum(double(ZoneIn(laps<c)==ZoneD))/length(ZoneIn(laps<c));
    p1b(c) = sum(double(ZoneIn(laps>c)==ZoneD))/length(ZoneIn(laps>c));
    LnL0(c) = log10(binopdf(sum(double(ZoneIn(laps~=c)==ZoneD)),length(ZoneIn(laps~=c)),p0(c)));
    LnL1a(c) = log10(binopdf(sum(double(ZoneIn(laps<c)==ZoneD)),length(ZoneIn(laps<c)),p1a(c)));
    LnL1b(c) = log10(binopdf(sum(double(ZoneIn(laps>c)==ZoneD)),length(ZoneIn(laps>c)),p1a(c)));
end

LogOR = (LnL1a+LnL1b)-LnL0;
plot(LogOR(2:end-1),'k-')