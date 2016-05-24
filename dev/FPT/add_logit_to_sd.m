function sd = add_logit_to_sd(sd)
%
%
%
%

C = (sd.ZoneIn == sd.DelayZone);
Laps = 1 : length(C);
firstDelayLap = min(Laps(C));

D = nan(length(C),1);
D(firstDelayLap) = sd.ZoneDelay(firstDelayLap);
I = false(length(C),1);
difference = [inf diff(double(C))];
if isempty(firstDelayLap)
    firstDelayLap = length(C)+1;
end
firstNonAlternation = min(Laps(difference==0 & Laps>firstDelayLap));
I(firstNonAlternation:end) = true;
for lap = firstDelayLap : length(sd.ZoneDelay)
    if C(lap)==1
        D(lap+1) = max(D(lap)+1,1);
    else
        D(lap+1) = max(1,D(lap)-1);
    end
    
end
PR = round(10.^(abs(log10(sd.World.nPleft/sd.World.nPright))));
sd.logit.PR = PR*ones(length(D(I)),1);
sd.logit.X = D(I);
sd.logit.Y = C(I);
if ~isempty(D(I))
    sd.logit.b = glmfit((sd.logit.X(:)),sd.logit.Y(:),'binomial');
else
    sd.logit.b = [nan;nan];
end
sd.logit.threshold = (-sd.logit.b(1)/sd.logit.b(2));
sd.logit.Negative = sd.logit.b(2)<0;
sd.logit.Unbiased = sum(double(C))/length(C)>0.05 & sum(double(C))/length(C)<0.95;
sd.logit.NonEconomic = sd.logit.threshold>max(D) | sd.logit.threshold<min(D) | sd.logit.b(2)>0 | firstDelayLap>length(C);

D20 = sd.ZoneDelay(Laps>max(Laps)-20);
% Delay on last 20 laps.
D20 = D20(sd.ZoneIn(Laps>max(Laps)-20)==sd.DelayZone);

sd.logit.last20 = nanmean(D20);