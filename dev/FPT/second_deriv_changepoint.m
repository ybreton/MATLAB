function Mdl_list = second_deriv_changepoint(sd)
%
%
%
%

tol = eps;
Ptol = 0.1;

laps = 1:sd.TotalLaps;
DelayLaps = laps(sd.ZoneIn==sd.DelayZone);
AllDelayZoneDelay = nan(length(sd.ZoneIn),1);
if ~isempty(DelayLaps)
    AllDelayZoneDelay(1:DelayLaps(1)) = nan;
    for l = 1 : length(DelayLaps)-1
        AllDelayZoneDelay(DelayLaps(l):DelayLaps(l+1)) = sd.ZoneDelay(DelayLaps(l));
    end
    AllDelayZoneDelay(DelayLaps(end)+1:end) = nan;
end

assert(~all(isnan(AllDelayZoneDelay))==1,'Never chose delayed side.')

smoothedD = smooth(AllDelayZoneDelay,1);
x = tsd(laps,AllDelayZoneDelay);
smoothedX = tsd(laps,smoothedD);
t0 = min(laps(~isnan(AllDelayZoneDelay)));
t1 = max(laps(~isnan(AllDelayZoneDelay)));
smoothedX = smoothedX.restrict(t0,t1);
laps = smoothedX.range;
x = x.restrict(t0,t1);
% dx = dxdt(x,'window',(max(x.range)-min(x.range)));
dx = dxdt(smoothedX,'window',3);
d2x = dxdt(dx,'window',3);

clf
ah(1)=subplot(2,1,1);
cla
hold on
xlabel('Lap')
ylabel('Last delay chosen')
plot(x.range,x.data,'k:')
plot(dx.range,dx.data,'r:','linewidth',2)
plot(d2x.range,d2x.data,'r:','linewidth',0.5)

stationary = abs(dx.D)<=tol;
start = 0;
for l = 2 : length(stationary)
    if stationary(l)~=stationary(l-1)
        start = [start; laps(l-1)];
        x0=x.D;
        plot(laps(l-1),x0(l-1),'ko')
    end
end
start = [start; laps(end)];
diffs = diff(start);
if ~isempty(x0)
    plot(laps(end),x0(end),'ko')
end
hold off

choice = sd.ZoneIn == sd.DelayZone;

cps = start(2:end-1);
subplot(2,2,4)
cla
hold on
xlabel('nSegments')
ylabel('Ln[L]')
nSeg = 0;
bestFit = [];
while (nSeg < length(cps)+1) & isempty(bestFit)
% while (nSeg < length(cps)+1)
    nSeg = nSeg+1;
    nCPs = nSeg-1;
    indices = [1:nCPs];
    LnLold = -inf;
    CP_old = nan(nCPs,1);
    p_old = nan(nCPs,1);
    
    if ~isempty(indices)
        while all(indices<length(cps))
            cpList = cps(indices);

            lastLap = [cpList(:);sd.TotalLaps];
            startLap = [1;cpList(:)+1];
            p = ones(length(startLap),1)*0.5;
            for lap = 1 : length(startLap)
                p(lap) = sum(choice(startLap(lap):lastLap(lap)))./length(choice(startLap(lap):lastLap(lap)));
            end
            % force one of the segments within 0.50+/-0.1 to be 0.5.
%             LnL = zeros(length(lastLap),1);
%             for lap = 1 : length(lastLap)
%                 tempP = p;
%                 tempP(lap) = 0.5;
%                 LnL(lap) = loglikelihood(choice,lastLap,tempP);
%             end
            tempP = p;
            tempP(abs(tempP-0.5)<=Ptol) = 0.5;
            LnL = loglikelihood(choice,lastLap,tempP);
            [LnLnew,idNew] = max(LnL);
            p_new = tempP;
            for lap = 1 : length(p_new)-1
                pChange(lap) = p_new(lap)~=p_new(lap+1);
            end
            if LnLnew>LnLold & all(pChange)
                LnLold = LnLnew;
                CP_old = cpList;
                p_old = p_new;
            end

            % update indices.
            indices(end) = indices(end)+1;
            for c = length(indices):-1:2
                if indices(c)>length(cps)
                    indices(c)=1;
                    indices(c-1)=indices(c-1)+1;
                end
            end
        end
        Mdl_list(nSeg).LnL = LnLold;
        Mdl_list(nSeg).CPs = CP_old;
        Mdl_list(nSeg).Probs = p_old;
        params = length(CP_old)+length(p_old);
        Mdl_list(nSeg).AIC = 2*params - 2*LnLold;
    else
        LnL = loglikelihood(choice,length(choice),0.5);
        Mdl_list(1).LnL = LnL;
        Mdl_list(1).CPs = [];
        Mdl_list(1).Probs = 0.5;
        Mdl_list(1).AIC = -2*LnL;
    end
    plot(nSeg,Mdl_list(nSeg).LnL,'ok')
    if nSeg>1
        if (Mdl_list(nSeg).LnL - Mdl_list(nSeg-1).LnL)<=tol
            % LnL decreasing.
            bestFit = nSeg-1;
        end
    end
end
hold off

highestCPs = [0 Mdl_list(bestFit).CPs(:)' sd.TotalLaps];
highestPs = [0 Mdl_list(bestFit).Probs(:)' 0];
subplot(2,2,3)
cla
hold on
xlabel('Lap')
ylabel('Choice')
plot(choice,'ko')
for seg = 2 : length(highestCPs)
    plot([highestCPs(seg-1)+1 highestCPs(seg)],[highestPs(seg) highestPs(seg)],'g-')
end
hold off

set(gcf,'currentaxes',ah(1))
hold on

for lap = 2 : length(highestCPs)
    start = highestCPs(lap-1)+1;
    finish = highestCPs(lap);
    plot([start finish],[nanmean(x.data(start:finish)) nanmean(x.data(start:finish))],'g-','linewidth',3)
end
hold off

function LnL = loglikelihood(InDelay,SegmentFinish,SegmentP)
laps = 1:length(InDelay);
SegmentStart = ones(length(SegmentFinish),1);
L = zeros(length(SegmentFinish),1);
for seg = 1 : length(SegmentFinish)
    SegmentStart(seg+1) = SegmentFinish(seg)+1;
    idIn = InDelay==1&(laps>=SegmentStart(seg)&laps<=SegmentFinish(seg));
    idOut = InDelay==0&(laps>=SegmentStart(seg)&laps<=SegmentFinish(seg));
    L(idIn) = SegmentP(seg);
    L(idOut) = 1-SegmentP(seg);
end
LnL0 = log(L);
LnL = sum(LnL0);