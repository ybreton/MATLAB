function [ShouldSkip,sdOut] = RRIdentifyShouldSkip(sd)
% Returns ShouldSkip to RR data structure for each trial t:
% if delay on trial t > threshold, then ShouldSkip is true.
%
% [ShouldSkip,sd] = RRIdentifyShouldStayGo(sd)
% where         ShouldSkip      is nSubsess x nTrial matrix,
%               if sd output is specified, will add fields ShouldSkip and ShouldStay to each subsession.
%
%               sd              is an sd file.
%

delays = RRGetDelays(sd);
threshByTrial = RRthreshByTrial(sd);

ShouldSkip = delays > threshByTrial;

if nargout>1
    for s = 1 : numel(sd)
        sd0 = sd(s);
        sd0.ShouldSkip = ShouldSkip(s,:);
        sdOut(s) = sd0;
    end
end