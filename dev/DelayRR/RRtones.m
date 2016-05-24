function tones = RRtones(sd)
% Returns a tsd of tone frequencies played during restaurant row.
% If sd contains sub-sessions (length(sd)>1), returns a cell array of tsds
% for each sub-session.
%
%

for iSess=1:length(sd)

    nTrls = length(sd(iSess).ZoneIn);
    D = nan(length(sd(iSess).ToneTimes),1);
    for iTrl = 1 : nTrls
        Tin = sd(iSess).EnteringZoneTime(iTrl);
        if length(sd(iSess).EnteringZoneTime)<=length(sd(iSess).ExitZoneTime)
            Tout = sd(iSess).ExitZoneTime(iTrl);
        else
            Tout = sd(iSess).ExpKeys.TimeOffTrack;
        end

        idT = sd(iSess).ToneTimes>=Tin & sd(iSess).ToneTimes<=Tout;
        delay = sd(iSess).ZoneDelay(iTrl);
        t = sd(iSess).ToneTimes(idT);
        d = nan(length(t),1);
        for iTone=1:length(t)
            d(iTone) = sd(iSess).FeederTone + delay*sd(iSess).FeederToneIncrease;
            delay = delay-1;
        end
        D(idT) = d;
    end
    if length(sd)>1
        tones{iSess} = tsd(sd(iSess).ToneTimes(:),D);
    else
        tones = tsd(sd.ToneTimes(:),D);
    end
end