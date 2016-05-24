function [isRejoice,sd] = RRGetRejoice(sd,varargin)
% returns an nSubsess x nTrials matrix of regret (1) or non-regret
% conditions for each trial.
%
% Rejoice is defined as:
% shouldSkip on trial t-1 == 1 && Stay on t-1 == 0 && shouldStay on trial t
% (should have skipped, skipped, and now should stay.)
%
% [isRegret,sd] = RRGetRejoice(sd,varargin)
% where     isRegret    is nSubsess x nTrials matrix of rejoice or
%                           non-rejoice condition
%           if sd output is specified, will append field isRejoice to each
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


isRejoice = nan(numel(sd),nTrials);
for s = 1 : numel(sd)
    isRejoice(s,2:end) = (shouldSkip(s,1:end-1)==1 & stayGo(s,1:end-1)==0) & shouldStay(s,2:end)==1;
end

if nargout>1
    for s = 1 : numel(sd)
        sd(s).isRejoice = isRejoice(s,:);
    end
end