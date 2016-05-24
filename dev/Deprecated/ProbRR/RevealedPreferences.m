function [Skip,Entry,ZoneProbSkipPref,ZoneSkipPref,ProbSkipPref] = RevealedPreferences

ZoneIn = evalin('caller','ZoneIn');
ZoneProbability = evalin('caller','ZoneProbability');
Probabilities = 0:0.1:1;
Zones = 1:4;

Entry = zeros(4,length(Probabilities));
Skip = zeros(4,length(Probabilities));
for r = 1 : length(ZoneIn)-1
    CurZone = ZoneIn(r);
    NextZone = ZoneIn(r+1);
    PZone = ZoneProbability(r);
    idProb = PZone == Probabilities;
    idZone = mod(CurZone,10)==Zones;
    
    if CurZone < 10 & NextZone >= 10
        % Enters the feeder.
        Entry(idZone,idProb) = Entry(idZone,idProb)+1;
    end
    if CurZone < 10 & NextZone < 10
        % Skips the feeder.
        Skip(idZone,idProb) = Skip(idZone,idProb)+1;
    end
end

ZoneProbSkipPref = Skip./(Skip+Entry);
ZoneSkipPref = sum(Skip,2)./(sum(Skip,2)+sum(Entry,2));
ProbSkipPref = sum(Skip,1)./(sum(Skip,1)+sum(Entry,1));
