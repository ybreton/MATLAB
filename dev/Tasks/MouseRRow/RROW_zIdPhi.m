function sd = RROW_zIdPhi(sd)

% sd = RROW_zIdPhi(sd)
% add IdPhi and zIdPhi to sd

% find decision zone times
tstart = sd.taskEvents.OfferTimeStamp; % time enters decision zone
tend = nan(size(tstart));
tend(~isnan(sd.taskEvents.EnterTimeStamp)) = sd.taskEvents.EnterTimeStamp(~isnan(sd.taskEvents.EnterTimeStamp));
tend(~isnan(sd.taskEvents.SkipTimeStamp)) = sd.taskEvents.SkipTimeStamp(~isnan(sd.taskEvents.SkipTimeStamp));

sd = zIdPhi(sd, 'tstart', tstart, 'tend', tend);