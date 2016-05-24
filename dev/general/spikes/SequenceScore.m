function SS = SequenceScore(t,c,varargin)
% Calculates the sequence score of all cells that fired at times t with
% place field centers at c.
% SS = SequenceScore(t,c,sd)
% where     SS      is sequence score for the sequence,
%
%           t       is a list of spike times,
%           c       is a list of place field center locations at those
%                   times,
%           sd      is a standard session data structure.
%
% As described in Gupta et al. (2012), "Segmentation of Spatial Experience
% by Hippocampal Theta Sequences.":
%
% ``Using the place field centers and spike times, each spike in the theta
% cycle was pairwise compared with other spikes occurring in the same theta
% cycle. If the place field center corresponding to spike A was traversed
% before the place field center for spike B and spike A occurred before
% spike B, the sequence score was +1, otherwise the score was –1. For all
% spikes in a given theta cycle, all pairwise comparisons were summed to
% determine the cumulative score of the sequence. ''
%
%   Since all mazes ultimately wrap such that the end point m approaches the
% start point n, we really don't want a location at m+eps to be behind the
% rat at n+eps, with a distance of (m-n+eps). Really, the distance should
% be +eps. A wrapStart and wrapFinish factor can be included to account for
% this: the distance will be the one with the smallest (absolute) value for
% either C2-C1 or (C2-C1)+(wrapStart-wrapFinish). 
%   For example, if we want the distance in a linearized track that starts
% at 0 and ends at 4 for two points: from point A at C1=3.5 to point B at
% C2=0.5. Without a wrap factor, C2-C1 would be -3, indicating that C2 is
% behind C1 by 3 units, when really, it's just ahead by 1 unit. Using a
% wrapStart of 1 and wrapFinish of 5, we evaluate:
%   C2-C1 = -3
%   C2-C1+4-0 = 1
% and choose the expression with the lowest absolute value. That means that
% the longest distance we will get in a maze that has periodicity is,
% essentially, halfway through the maze (in this example, +/-2).
%
% OPTIONAL ARGUMENTS:
% *******************
% wrapStart     (default: 0)
% wrapFinish    (default: 1)
%   Values of the linearized maze when at maze start (wrapStart) and when
%   at maze finish (wrapFinish), which in a periodic maze are equal.
%   

wrapFinish = 1;
wrapStart = 0;
process_varargin(varargin);
wrapFactor = wrapFinish - wrapStart;

% nSpikes x nSpikes matrix of spike time deltas
deltaT = repmat(t(:),[1 numel(t)]) - repmat(t(:)',[numel(t) 1]);

% Getting field center deltas is not as straightforward, since we want the
% closest of L2-L1 and L2-L1+wrapFactor
deltaC1 = repmat(c(:),[1 numel(c)]) - repmat(c(:)',[numel(c) 1]);
deltaC2 = repmat(c(:),[1 numel(c)]) - repmat(c(:)',[numel(c) 1]) + wrapFactor;
D = [deltaC1(:) deltaC2(:)];
[~,I] = min(abs(D),[],2);
deltaC = nan(size(deltaT));
for iD=1:size(D,1)
    deltaC(iD) = D(iD,I(iD));
end

deltaTC = deltaT.*deltaC;
TC01 = nan(size(deltaTC));
TC01(deltaTC<0) = -1;
TC01(deltaTC>0) = 1;

SS = nansum(TC01(:));