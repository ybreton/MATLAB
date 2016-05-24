function Rt = titration_efficiency(sd,firstAdjustment,lastAdjustment)
%
%
%
%

[DD,LL] = DD_getDelays(sd,'nL',sd.TotalLaps);
Laps = (1:sd.TotalLaps)';

SD = LL(min(Laps(~isnan(LL))));
Last20 = LL(Laps>sd.TotalLaps-20);
FD = mean(Last20);

nAdjust = lastAdjustment - firstAdjustment + 1;

Rt = max(nAdjust,eps)/max(abs(FD-SD),eps);
