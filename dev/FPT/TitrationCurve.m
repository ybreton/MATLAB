ZoneIn = sd.ZoneIn(:);
DelayZone = sd.DelayZone(:);
DelayDuration = sd.ZoneDelay(:);
ZoneTime = sd.EnteringZoneTime(:);
NormZoneTime = ZoneTime - ZoneTime(1);
Laps = (1:sd.TotalLaps)';

InDelay = ZoneIn == DelayZone;

% Duration = tsd(NormZoneTime(InDelay),DelayDuration(InDelay));
Duration = tsd(Laps(InDelay),DelayDuration(InDelay));

window = Duration.T(end)-Duration.T(1);
DurationDerivative = dxdt(Duration,'window',window);

for K = 1 : 5
    [fit,RSS] = fit_titration_segments(sd,K);
    clf
    subplot(2,1,1)
    hold on
    plot(Duration.T,Duration.D)
    xlabel('lap')
    ylabel('Delay on delay side when chosen')
    hold off
    subplot(2,1,2)
    hold on
    title(sprintf('Window %.1f',window))
    plot(DurationDerivative.T,DurationDerivative.D)
    for k = 1 : K
        plot([fit(1,k) fit(2,k)],[fit(3,k) fit(3,k)],'r-')
    end
    xlabel('lap')
    ylabel(sprintf('\\partial delay / \\partial lap'))
    hold off
    pause
end