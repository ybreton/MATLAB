nvt = FindFiles('*.nvt','CheckSubdirs',0);
if isempty(nvt)
    zipfile = FindFiles('*VT1*.zip');
    unzip(zipfile{1});
end
nvt = FindFiles('*.nvt','CheckSubdirs',0);

[x,y] = LoadVT_lumrg(nvt{1});
figure;
plot3(x.data, y.data, x.range,'k.')
view(2)

%%
t1 = input('Time of proposed regret instance:');

%%
RRfile = FindFiles('RR-*.mat','CheckSubdirs',0);
EnteringZoneTime = [];
ExitZoneTime = [];
FeederTimes = [];
ZoneDelay = [];
ZoneIn = [];
SubSess = [];
clear sd
for iF = 1 : length(RRfile)
    sd(iF) = load(RRfile{iF});
    EnteringZoneTime = [EnteringZoneTime sd(iF).EnteringZoneTime];
    FeederTimes = [FeederTimes sd(iF).FeederTimes];
    ExitZoneTime = [ExitZoneTime sd(iF).ExitZoneTime];
    ZoneDelay = [ZoneDelay sd(iF).ZoneDelay];
    ZoneIn = [ZoneIn sd(iF).ZoneIn];
    SubSess = [SubSess ones(1,length(sd(iF).ZoneIn))*iF];
end
fh=gcf;
clf
hold on
x0 = x.restrict(t1-10,t1+10); y0 = y.restrict(t1-10, t1+10);
plot(x.data, y.data, 'k.',x0.data, y0.data, 'ro')
hold off
%%
figure
hold on
plot(EnteringZoneTime/1e6,ZoneDelay,'b.')
plot([t1 t1], [0 30], 'r')

hold off
%%
rt = find(ExitZoneTime/1e6>=t1,1,'first');
%%
SS = SubSess(rt);
ZoneDelaySS = sd(SS).ZoneDelay;
ZoneInSS = sd(SS).ZoneIn;
ExitZoneTimeSS = sd(SS).ExitZoneTime;
FeederTimesSS = sd(SS).FeederTimes;
nPelletsSS = sd(SS).nPellets;
%%
SSNthresholds;
%%
f = find(FeederTimes/1e6>t1,1,'first');

rt = find(ExitZoneTime/1e6>=t1,1,'first'); % Zone immediately following regret instance
RegretDelay = ZoneDelay(rt)
RegretZone = ZoneIn(rt)
RegretThreshold = thresh(RegretZone);

PrevDelay = ZoneDelay(rt-1)
PrevZone = ZoneIn(rt-1)
PrevThreshold = thresh(PrevZone);
tInPrevZone = (ExitZoneTime(rt-1)-EnteringZoneTime(rt-1))/1e6;
tLeftToDelay = ZoneDelay(rt-1)-tInPrevZone

Prev2Delay = ZoneDelay(rt-2)
Prev2Zone = ZoneIn(rt-2)
Prev2Threshold = thresh(Prev2Zone);

set(0,'currentfigure',fh)
hold on
th=text(max(x.data),max(y.data),sprintf('Regret Zone: %d\nRegret Delay: %d\nRegret threshold: %.0f\nPrevious Zone: %d\nPrevious delay: %d\nPrevious threshold: %.0f\nTwo back zone: %d\nTwo back delay: %d\nTwo back threshold: %.0f',RegretZone,RegretDelay,RegretThreshold,PrevZone,PrevDelay,PrevThreshold,Prev2Zone,Prev2Delay,Prev2Threshold));
set(th,'verticalalignment','top')
set(th,'horizontalalignment','left');