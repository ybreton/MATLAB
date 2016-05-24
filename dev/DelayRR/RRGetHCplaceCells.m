function S = RRGetHCplaceCells(sd,varargin)
% Extracts place cells from hippocampus-targeted tetrode clusters.
% S = RRGetHCplaceCells(sd)
% where         S           is a cell array of cluster spike times.
%
%               sd          is a standard session data structre.
%
% OPTIONAL ARGUMENTS:
% ******************
% HC            (default 1) 
%                           number identifying the target corresponding to
%                               hippocampus.
% minISI        (default 0.5)
%                           minimum mean inter-spike interval. Smaller
%                               inter-spike intervals are presumed
%                               interneurons.
% minSpikes     (default 40)
%                           minimum number of spikes between TimeOnTrack
%                               and TimeOffTrack. Fewer numbers are
%                               presumed to be task-irrelevant.
% minStable     (default inf)
%                           maximum ratio (large:small) of number of spikes
%                               in first half of session to number of
%                               spikes in second half. Larger ratios are
%                               presumed to be unstable.
%                           
%                           
%
%

minSpikes = 40;
minISI = 0.5;
HC = 1;
minStable = inf;
process_varargin(varargin);

idTT = RRassignTetrodeClusters(sd);
ISI = nan(length(sd.S),1);
spikes = nan(length(sd.S),1);
Tstart = sd(1).ExpKeys.TimeOnTrack;
Tfinish = sd(1).ExpKeys.TimeOffTrack;
Tmid = (Tfinish-Tstart)/2+Tstart;
SR1 = nan(length(sd.S),1);
SR2 = SR1;
for iC=1:length(sd.S);
    ISI(iC) = nanmean(diff(sd.S{iC}.data));
    spikes(iC) = length(data(sd.S{iC}.restrict(Tstart,Tfinish)));
    SR1(iC) = length(data(sd.S{iC}.restrict(Tstart,Tmid)));
    SR2(iC) = length(data(sd.S{iC}.restrict(Tmid,Tfinish)));
end

idInterNrn = ISI<minISI;
idSpks = spikes>=minSpikes;
idHC = idTT(HC,:)';
idUnstable = 10.^(abs(log10(SR1./SR2)))>=minStable;

S = sd.S(idHC&~idInterNrn&idSpks&~idUnstable);