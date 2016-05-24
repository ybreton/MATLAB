function ta = ta_from_RRSUM(RR_SUM_V1P0)
%
%
%
%

% Proportion of delay time spent waiting
%   = (time out - time in) / (delay)
% If (time out - time in) > delay, ta = 1

waitTime = RR_SUM_V1P0.DATA(:,10) - RR_SUM_V1P0.DATA(:,9);
delay = RR_SUM_V1P0.DATA(:,5);
ta = min(1, waitTime./delay);