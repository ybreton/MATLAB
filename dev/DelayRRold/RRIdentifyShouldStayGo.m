function [ShouldSkip,ShouldStay] = RRIdentifyShouldStayGo(sd)
% Returns ShouldSkip and ShouldStay to RR data structure for each trial t:
% if delay on trial t > threshold, then ShouldSkip is true.
% if delay on trial t < threshold, then ShouldStay is true.
%
% outStruc = RRIdentifyShouldStayGo(sd)
% where         ShouldSkip      is nSubsess x nTrial matrix,
%               ShouldStay      is nSubsess x nTrial matrix.
%
%               sd              is an sd file.
%

delays = RRGetDelays(sd);
threshByTrial = RRthreshByTrial(sd);

ShouldSkip = delays > thresholdByTrial;
ShouldStay = delays < thresholdByTrial;

