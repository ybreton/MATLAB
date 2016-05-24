function [isRegret,sd] = RRGetRegretMinDiff(sd,varargin)
% returns an nSubsess x nTrials matrix of regret (1) or non-regret
% conditions for each trial, using a minimum difference from threshold.
%
% Regret is defined as:
% (threshold for trial t-1 - delay on trial t-1 >= minDiffB && skip t-1) && (delay on
% trial t - threshold for trial t >= minDiffA)
% (skipped a delay that was minDiffB below threshold, and now has delay.)
%
% [isRegret,sd] = RRGetRegret(sd,varargin)
% where     isRegret    is nSubsess x nTrials matrix of regret or
%                           non-regret condition
%           if sd output is specified, will append field isRegret to each
%           subsession of the sd.
%
%           sd          is nSubsess x 1 structure of standard session data.
%
% OPTIONAL ARGUMENTS:
% ******************
% minDiffB  (default minDiff)   minimum difference below threshold; delay on
%                               previous zone must have been at least this
%                               below threshold and skipped for it to be
%                               regret.
% minDiffA  (default minDiff)   minimum difference above threshold; delay on
%                               current zone must be at least this above
%                               threshold for it to be regret.
% minDiff   (default 4)         minimum difference above and below
%                               threshold for it to be considered regret.
% nZones    (default 4)     number of zones
% maxLaps   (default 200)   maximum number of laps
%
nZones = 4;
maxLaps = 200;
minDiff = 4;
process_varargin(varargin);
minDiffA = minDiff;
minDiffB = minDiff;
process_varargin(varargin);

nTrials = nZones * maxLaps;

stayGo = RRGetStaygo(sd);
threshByTrial = RRthreshByTrial(sd);

delay = nan(1,length(threshByTrial));
delay(1:length(sd.FeederDelay)) = sd.FeederDelay;
diffB = threshByTrial-delay; % delay seconds below threshold
diffA = delay-threshByTrial; % delay seconds above threshold

isRegret = nan(numel(sd),nTrials);
for s = 1 : numel(sd)
    isRegret(s,2:end) = (diffB(1:end-1)>=minDiffB & stayGo(1:end-1)==0) & diffA(2:end)>=minDiffA;
    
    %isRegret(s,2:end) = (shouldStay(s,1:end-1)==1 & stayGo(s,1:end-1)==0) & shouldSkip(s,2:end)==1;
end

if nargout>1
    for s = 1 : numel(sd)
        sd(s).isRegret = isRegret(s,:);
    end
end