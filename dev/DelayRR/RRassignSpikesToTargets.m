function sd = RRassignSpikesToTargets(sd)
% Adds field ByTarget to sd, 
% with subfields S, fn, fc
% where each is an nCells x nTargets cell array of spike timestamps.

tt = RRassignTetrodes(sd);
% tt now contains tetrode information on each cluster in sd
CluTargets = sd.ExpKeys.TetrodeTargets(tt);
% targets cointains index to sd.ExpKeys.Target.

ByTarget.S = cell(length(sd.S),length(sd.ExpKeys.Target));
ByTarget.fn = cell(length(sd.S),length(sd.ExpKeys.Target));
ByTarget.fc = cell(length(sd.S),length(sd.ExpKeys.Target));
ByTarget.nCells = nan(1,length(sd.ExpKeys.Target));

for iTarget = 1:length(sd.ExpKeys.Target)
    Target = sd.ExpKeys.Target{iTarget};
    disp(['Assigning ' Target ' spikes to column ' num2str(iTarget) '...'])
    idTarget = CluTargets==iTarget;
    S0 = sd.S(idTarget);
    fn0 = sd.fn(idTarget);
    fc0 = sd.fc(idTarget);
    ByTarget.S(1:length(S0),iTarget) = S0;
    ByTarget.fn(1:length(fn0),iTarget) = fn0;
    ByTarget.fc(1:length(fc0),iTarget) = fc0;
    ByTarget.nCells(1,iTarget) = length(S0);
    disp([num2str(length(S0)) ' clusters assigned to column ' num2str(iTarget)])
end
% save space.
maxCells = max(ByTarget.nCells);
ByTarget.S = ByTarget.S(1:maxCells,:);
ByTarget.fn = ByTarget.fn(1:maxCells,:);
ByTarget.fc = ByTarget.fc(1:maxCells,:);

sd.ByTarget = ByTarget;

