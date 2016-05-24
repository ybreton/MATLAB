function [Investigation,Titration,Alternation] = divide_session_phases_v2(sd,varargin)
%
%
%
%
binSize = 5;
debug=true;
process_varargin(varargin);

nLaps = sd.TotalLaps;

laps = (1:nLaps)';

LL = sd.ZoneIn == sd.DelayZone;
dev = diff(LL(:));
adjustment = [nan; dev==0];
alternation = [nan; abs(dev)>0];

phase = 1;
binCenter = nan;
b=2;
for window = 2+binSize/2 : nLaps-binSize/2
    binLo = window-binSize/2;
    binHi = window+binSize/2;
    id = laps>=binLo & laps<binHi;
    binCenter(b) = nanmean(laps(id));
    ADJ = adjustment(id);
    if sum(ADJ)<=1 & (binCenter(b)<30 | phase(b-1)<2)
        phase(b) = 1;
    end
    if sum(ADJ)>=2
        phase(b) = 2;
    end
    if sum(ADJ)<=1 & (binCenter(b)>30 | phase(b-1)>=2)
        phase(b) = 3;
    end
    b=b+1;
end

firstInvestigation = min(binCenter(phase==1));
lastInvestigation = max(binCenter(phase==1));

firstTitration = min(binCenter(phase==2&binCenter>lastInvestigation));
lastTitration = max(binCenter(phase==2&binCenter<firstExploit));

firstExploit = min(binCenter(
lastExploit = max(binCenter(phase==3));

Investigation = false(nLaps,1);
Titration = false(nLaps,1);
Alternation = false(nLaps,1);

Investigation(firstInvestigation:lastInvestigation) = true;
Titration(firstTitration:lastTitration) = true;
Alternation(firstExploit:lastExploit) = true;

if debug
    LD = DelayOnDelayedSide(sd);
    cla
    hold on
    plot(laps,LD,'k-')
    plot(laps(Investigation),LD(Investigation),'ro')
    plot(laps(Titration),LD(Titration),'bo')
    plot(laps(Alternation),LD(Alternation),'ko')
    set(gca,'xlim',[0 nLaps+1])
    set(gca,'ylim',[0 30])
    hold off
end