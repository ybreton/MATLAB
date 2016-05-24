function summary = summarize_idealDetector_cps(cp,FinalAlternation,sd)
%
%
%
%

InDelay = sd.ZoneIn == sd.DelayZone;
InDelay = [false; InDelay(:)];
laps = (0:length(sd.ZoneIn))';
D = [nan; sd.ZoneDelay(:)];

pelletRatio = max(sd.World.nPleft,sd.World.nPright)/min(sd.World.nPleft,sd.World.nPright);

LastDelayOnDelayedSide = nan(length(laps),1);
% Before the experiment (before lap 0), the rat did not choose a delay yet.
for l = 2 : length(D)
    lapsSoFar = laps(1:l-1);
    choicesSoFar = InDelay(1:l-1);
    delaysSoFar = D(1:l-1);
    LastLapDelayChosen = max(lapsSoFar(choicesSoFar));
    if isempty(LastLapDelayChosen)
        LastChosenDelay = nan;
    elseif LastLapDelayChosen == 0
        LastChosenDelay = nan;
    else
        idxLastDelayChosen = LastLapDelayChosen == lapsSoFar;
        LastChosenDelay = delaysSoFar(idxLastDelayChosen);
    end
    LastDelayOnDelayedSide(l) = LastChosenDelay;
end
if ~all(isnan(LastDelayOnDelayedSide))
    dtemp = LastDelayOnDelayedSide(~isnan(LastDelayOnDelayedSide));
else
    dtemp = nan;
end


cpList = 1:length(cp);
FinalAlternation = cpList(FinalAlternation);
if isempty(FinalAlternation)
    % No segment found. Assume it hasn't occurred yet.
    FinalAlternation = length(cp)+1;
end
FinalAlternation = FinalAlternation - 1;
s = cp(1:end-1)+1;
f = cp(2:end);
% each segment starts at s and ends at f.
PreAlternationLaps = [];
PostAlternationLaps = [];
AlternationLaps = [];

AlternationDelays = [];
PreAlternationDelays = [];
PostAlternationDelays = [];
AlternationChoices = [];
PreAlternationChoices = [];
PostAlternationChoices = [];
AlternationChosenD = [];
PreAlternationChosenD = [];
PostAlternationChosenD = [];

for seg = 1 : length(s)
    t0 = s(seg);
    t1 = f(seg);
    idx = laps>=t0 & laps<=t1;
    segment.laps = laps(idx);
    segment.D = D(idx);
    segment.InDelay = InDelay(idx);
    segment.LastDelayOnDelayedSide = LastDelayOnDelayedSide(idx);
    
    if any(seg==FinalAlternation)
        % segment is the final alternation seg.
        AlternationLaps = [AlternationLaps; segment.laps];
        AlternationDelays = [AlternationDelays; segment.D];
        AlternationChoices = [AlternationChoices; segment.InDelay];
        AlternationChosenD = [AlternationChosenD; segment.LastDelayOnDelayedSide];
    elseif seg<min(FinalAlternation)
        % segment occurs prior to the final alternation seg.
        PreAlternationLaps = [PreAlternationLaps; segment.laps];
        PreAlternationDelays = [PreAlternationDelays; segment.D];
        PreAlternationChoices = [PreAlternationChoices; segment.InDelay];
        PreAlternationChosenD = [PreAlternationChosenD; segment.LastDelayOnDelayedSide];
    elseif seg>max(FinalAlternation)
        % segment occurs after the final alternation seg.
        PostAlternationLaps = [PostAlternationLaps; segment.laps];
        PostAlternationDelays = [PostAlternationDelays; segment.D];
        PostAlternationChoices = [PostAlternationChoices; segment.InDelay];
        PostAlternationChosenD = [PostAlternationChosenD; segment.LastDelayOnDelayedSide];
    end
end

summary.pelletRatio = pelletRatio;
summary.startDelay = dtemp(1);
summary.delayRange = [min(dtemp) max(dtemp)];

idx = AlternationLaps>0;
summary.Alternation.Laps = AlternationLaps(idx);
summary.Alternation.Delays = AlternationDelays(idx);
summary.Alternation.Choices = AlternationChoices(idx);
summary.Alternation.LastChosenD = AlternationChosenD(idx);
if ~isempty(AlternationChosenD(idx))
    summary.Alternation.MeanD = nanmean(AlternationChosenD(idx));
else
    summary.Alternation.MeanD = nan;
end
summary.Alternation.nLaps = (length(AlternationLaps(AlternationLaps>0)));
summary.Alternation.PropSSN = (length(AlternationLaps(AlternationLaps>0)))/length(laps(laps>0));

idx = PreAlternationLaps>0;
summary.PreAlternation.Laps = PreAlternationLaps(idx);
summary.PreAlternation.Delays = PreAlternationDelays(idx);
summary.PreAlternation.Choices = PreAlternationChoices(idx);
summary.PreAlternation.LastChosenD = PreAlternationChosenD(idx);
if ~isempty(PreAlternationChosenD(idx))
    summary.PreAlternation.MeanD = nanmean(PreAlternationChosenD(idx));
else
    summary.PreAlternation.MeanD = nan;
end
summary.PreAlternation.nLaps = (length(PreAlternationLaps(PreAlternationLaps>0)));
summary.PreAlternation.PropSSN = (length(PreAlternationLaps(PreAlternationLaps>0)))/length(laps(laps>0));

idx = PostAlternationLaps>0;
summary.PostAlternation.Laps = PostAlternationLaps(idx);
summary.PostAlternation.Delays = PostAlternationDelays(idx);
summary.PostAlternation.Choices = PostAlternationChoices(idx);
summary.PostAlternation.LastChosenD = PostAlternationChosenD(idx);
if ~isempty(PostAlternationChosenD(idx))
    summary.PostAlternation.MeanD = nanmean(PostAlternationChosenD(idx));
else
    summary.PostAlternation.MeanD = nan;
end
summary.PostAlternation.nLaps = (length(PostAlternationLaps(PostAlternationLaps>0)));
summary.PostAlternation.PropSSN = (length(PostAlternationLaps(PostAlternationLaps>0)))/length(laps(laps>0));
