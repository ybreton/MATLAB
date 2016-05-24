function [ShouldStay,sdOut] = RRIdentifyShouldStay(sd)
% Returns ShouldStay to RR data structure for each trial t:
% if delay on trial t < threshold, then ShouldStay is true.
%
% [ShouldStay,sd] = RRIdentifyShouldStayGo(sd)
% where         ShouldStay      is nSubsess x nTrial matrix.
%               if sd output is specified, will add fields ShouldSkip and ShouldStay to each subsession.
%
%               sd              is an sd file.
%

delays = RRGetDelays(sd);
threshByTrial = RRthreshByTrial(sd);

ShouldStay = delays < threshByTrial;

if nargout>1
    for s = 1 : numel(sd)
        sd0 = sd(s);
        sd0.ShouldStay = ShouldStay(s,:);
        sdOut(s) = sd0;
    end
end