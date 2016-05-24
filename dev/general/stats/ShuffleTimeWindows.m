function [tShuffleStart,tShuffleEnd,stopCode] = ShuffleTimeWindows_Old(t0,t1,tWindowStart,tWindowEnd)
% Generates n uniformly selected time windows between t0 and t1 of size
% equal to tWindowEnd-tWindowStart.
%
% [tShuffleStart,tShuffleEnd,stopCode] = ShuffleTimeWindows(t0,t1,tWindowStart,tWindowEnd)
% where     tShuffleStart       is nWindows (n x m x ... x p) matrix of
%                                   shuffled time  window start times
%           tShuffleEnd         is nWindows (n x m x ... x p) matrix of
%                                   shuffled time window end times 
%           stopCode            is 1x1 logical of premature stop. If it was
%                                   impossible to move overlapping
%                                   uniformly selected windows, the
%                                   function will fail with stopCode==1. If
%                                   the randomization completed
%                                   successfully, the function will stop
%                                   with stopCode==0.
%
%           t0                  is 1x1 scalar of earliest time stamp from
%                                   which to uniformly sample
%           t1                  is 1x1 scalar of latest time stamp from
%                                   which to uniformly sample
%           tWindowStart        is nWindows (n x m x ... x p) matrix of
%                                   time window start times.
%           tWindowEnd          is nWindows (n x m x ... x p) matrix of
%                                   time window end times.
%

% Make sure tWindowStart and tWindowEnd have matching size.
assert(length(size(tWindowEnd))==length(size(tWindowStart)),'Time window start and end times must have matching dimensions.')
assert(all(size(tWindowEnd)==size(tWindowStart)),'Time window start and end times must have matching size.');

% Remember that size for the output.
sz = size(tWindowStart);

% Convert to a single column vector.
tWindowStart = tWindowStart(:);
tWindowEnd = tWindowEnd(:);

assert(all(tWindowEnd>tWindowStart),'Time window start times must be less than time window end times.');

% Sort time windows.
[tWindowStart,I] = sort(tWindowStart);
tWindowEnd = tWindowEnd(I);

% Get window size
tWindow = tWindowEnd-tWindowStart;

% Center of time window must be between t0+tWindow(1)/2 and
% t1-tWindow(end)/2.
tStart = t0+tWindow(1)/2;
tEnd = t1-tWindow(end)/2;
tc = sort(tStart+rand(length(tWindow),1)*(tEnd-tStart));

tShuffleStart = nan(length(tc),1);
tShuffleEnd = nan(length(tc),1);

% Check for window overlap.
ITI = (tWindow(1:end-1)/2+tWindow(2:end)/2);
overlap = diff(tc)<ITI;
stopCode = false;
while any(overlap) && ~stopCode
    d = diff(tc);
    idOv = find(d<ITI,1,'first');
    
    % How far back can I move to the last time window?
    if idOv>1
        % distance to previous window's edge from current window edge
        d2 = (tc(idOv)-tWindow(idOv)/2) - (tc(idOv-1)+tWindow(idOv-1)/2);
    else
        % distance to start time.
        d2 = tc(idOv)-tStart;
    end
    % How far back does it need to be moved from the next?
    d3 = (tc(idOv)+tWindow(idOv)/2)-(tc(idOv+1)-tWindow(idOv+1)/2);
    
    % Move time window back as far as possible.
    mv = min([d2;d3]);
    % Move next time window by the remainder.
    mv2 = d3-mv;
    
    tc(idOv) = tc(idOv)-mv;
    tc(idOv+1) = tc(idOv+1)+mv2;
    tc=sort(tc);
    
    overlap = diff(tc)<ITI;
    stopCode = mv==0;
end

if ~stopCode
    tShuffleEnd = tc+tWindow/2;
    tShuffleStart = tc-tWindow/2;
end

tShuffleStart = reshape(tShuffleStart,sz);
tShuffleEnd = reshape(tShuffleEnd,sz);