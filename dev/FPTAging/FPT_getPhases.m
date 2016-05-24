function [Inv0,Inv,Tit,Expl] = FPT_getPhases(sd,varargin)

nL = sd.TotalLaps; % total laps to check
fL = 20; % final laps for compensatory delay
startTit = 1; % number of laps moving in correct direction to be called titration.
process_varargin(varargin);
C = sd.ZoneIn(1:nL) == sd.DelayZone;
laps = 1:nL;
[DD,LL] = DD_getDelays(sd,'nL',nL);
SD = LL(1);
FD = mean(LL(laps>sd.TotalLaps-fL));
direction = sign(FD-SD);
startLap = find(C==1,1,'first');

firstAltern = nan;
lastInvest = nan;
if all(C==0)
    disp('Only nondelayed choices.')    
    Inv = nan(nL,1);
    Inv0 = nan(nL,1);
    Tit = nan(nL,1);
    Expl = nan(nL,1);
else
    for iL = 1+startTit : sd.TotalLaps
        if direction>=0 & isnan(firstAltern) & ~isnan(lastInvest)
            if LL(iL-1)<FD & LL(iL)>=FD
                firstAltern = iL;
            end
        end
        if direction<=0 & isnan(firstAltern)& ~isnan(lastInvest)
            if LL(iL-1)>FD & LL(iL)<=FD
                firstAltern = iL;
            end
        end
        if direction>=0 & isnan(lastInvest)
            if all(LL(iL-startTit:iL)>SD)
                lastInvest = iL-2;
            end
        end
        if direction<=0 & isnan(lastInvest)
            if all(LL(iL-startTit:iL)<SD)
                lastInvest = iL-2;
            end
        end
    end
    if isnan(firstAltern);firstAltern=startLap+1;end;
    if isnan(lastInvest);lastInvest=startLap;end;
    Inv0 = laps(:)<=lastInvest;
    Inv = laps(:)>=startLap&laps(:)<=lastInvest;
    Tit = laps(:)>lastInvest&laps(:)<firstAltern;
    Expl = laps(:)>=firstAltern;
end