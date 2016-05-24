function [isRegret,sd] = RRGetRegret(sd,varargin)
% returns an nSubsess x nTrials matrix of regret (1) or non-regret
% conditions for each trial.
%
% Regret is defined as:
% shouldStay on trial t-1 == 1 && Stay on t-1 == 0 && shouldSkip on trial t
% (should have stayed, skipped, and now should skip.)
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
% nZones    (default 4)     number of zones
% maxLaps   (default 200)   maximum number of laps
%
nZones = 4;
maxLaps = 200;
process_varargin(varargin);

nTrials = nZones * maxLaps;

stayGo = RRGetStaygo(sd);
shouldStay = RRIdentifyShouldStay(sd);
shouldSkip = RRIdentifyShouldSkip(sd);


isRegret = nan(numel(sd),nTrials);
for s = 1 : numel(sd)
    isRegret(s,2:end) = (shouldStay(s,1:end-1)==1 & stayGo(s,1:end-1)==0) & shouldSkip(s,2:end)==1;
end

if nargout>1
    for s = 1 : numel(sd)
        sd(s).isRegret = isRegret(s,:);
    end
end