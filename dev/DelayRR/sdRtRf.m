function sdOut = sdRtRf(sdIn,varargin)
% Adds fields 
% sd.RtRf           the total rate of reinforcement
% sd.instRtRf       the instantaneous rate of reinforcement.
% sd.pelletEarned   the total number of pellets earned on each zone entry
% sd.cumPellets     the cumulative number of pellets earned
% sd.sessTime       the total time on the track
% 

for iS=1:length(sdIn)
    sd0 = sdIn(iS);
    
    sd0.pelletEarned = sd0.nPellets.*sd0.stayGo;
    sd0.sessTime = sd0.ExpKeys.TimeOffTrack-sd0.ExpKeys.TimeOnTrack;
    sd0.RtRf = nansum(sd0.pelletEarned)/sd0.sessTime;
    
    sd0.cumPellets = cumsum(sd0.pelletEarned);
        
    C = sd0.cumPellets;
    T = sd0.ExitZoneTime-sd0.ExpKeys.TimeOnTrack;
    n = min(length(C),length(T));
    m = max(length(C),length(T));
    sd0.instRtRf = nan(m,1);
    sd0.instRtRf(1:n) = C(1:n)./T(1:n);
    
    sdOut(iS) = sd0;
end