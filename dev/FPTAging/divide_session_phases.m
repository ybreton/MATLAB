function [Investigation,Adjustment,FinalAlternation] = divide_session_phases(sd,varargin)
%
%
%
%
binSize = 5;
binStep = 1;
debug = true;
process_varargin(varargin);

nLaps = sd.TotalLaps;
LL = DelayOnDelayedSide(sd);
Laps = (1:nLaps)';
C = sd.ZoneIn(:) == sd.DelayZone;

binC = 1+binSize/2 : binStep : nLaps-binSize/2;
alt = nan(length(binC),1);
c = nan(length(binC),binSize);
for bin = 1 : length(binC)
    binLo = binC(bin)-binSize/2;
    binHi = binC(bin)+binSize/2;
    idBin = Laps>=binLo & Laps<binHi;
    c(bin,1:length(C(idBin))) = double(C(idBin));
end
p = sum(c,2)./sum(double(~isnan(c)),2);
alt = p>=0.4 & p<=0.6;

Titbin = binC(alt==0);
firstTit = min(Titbin);
Invest = binC(binC<firstTit);
if ~isempty(Invest)
    Investigation = Laps<firstTit-binSize/2;
else
    Investigation = false(length(Laps),1);
end
% 
% binHi = nLaps-binSize:-binStep:1;
% alt2 = nan(length(binHi),1);
% for bin = 1 : length(binHi)
%     idBin = Laps>binHi(bin)-binSize & Laps<=binHi(bin);
%     c = double(C(idBin));
%     if length(c)==binSize
%         if sum(c)/binSize>=2/5 && sum(c)/binSize<=3/5
%             alt2(bin)=1;
%         else
%             alt2(bin)=0;
%         end
%     end
% end
% Titbin = binHi(alt2==0);

lastTit = max(Titbin);
FinalAltern = binC(binC>lastTit);
if ~isempty(FinalAltern)
    FinalAlternation = Laps>min(FinalAltern)-binSize;
else
    FinalAlternation = false(length(Laps),1);
end
Adjustment = Laps>=firstTit-binSize/2 & Laps<=lastTit+binSize/2;

if debug
    clf
    hold on
    ph(1)=plot(Laps,LL,'k-');
    ph(2)=plot(Laps(alt==1),LL(alt==1),'bs');
    ph(3)=plot(Laps(alt==0),LL(alt==0),'rs');
   
    
%     if any(Investigation)
%         ph(1)=plot(Laps(Investigation),LL(Investigation),'bo-');
%     end
%     if any(Adjustment)
%         ph(2)=plot(Laps(Adjustment),LL(Adjustment),'ro-');
%     end
%     if any(FinalAlternation)
%         ph(3)=plot(Laps(FinalAlternation),LL(FinalAlternation),'ko-');
%     end
    set(gca,'ylim',[0 45])
    set(gca,'xlim',[0 sd.TotalLaps+1])
    hold off
end
