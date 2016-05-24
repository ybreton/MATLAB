function [ShouldStay,ShouldSkip,sdOut] = RRIdentifyShouldStayGo(sd)
% Returns ShouldSkip and ShouldStay to RR data structure for each trial t:
% if delay on trial t > threshold, then ShouldSkip is true.
% if delay on trial t < threshold, then ShouldStay is true.
%
% [ShouldSkip,ShouldStay,sd] = RRIdentifyShouldStayGo(sd)
% where         ShouldSkip      is nSubsess x nTrial matrix,
%               ShouldStay      is nSubsess x nTrial matrix.
%               if sd output is specified, will add fields ShouldSkip and ShouldStay to each subsession.
%
%               sd              is an sd file.
%

delays = RRGetDelays(sd);
threshByTrial = RRthreshByTrial(sd);

ShouldSkip = delays > threshByTrial;
ShouldStay = delays < threshByTrial;

if nargout>2
    for s = 1 : numel(sd)
        sd0 = sd(s);
        sd0.ShouldSkip = ShouldSkip(s,:);
        sd0.ShouldStay = ShouldStay(s,:);
        sdOut(s) = sd0;
    end
end