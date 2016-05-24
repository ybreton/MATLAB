function R = remove(tsa, t0, t1)

% 	R = Remove(tsa, t0, t1)
% anti-restrict
% 	Returns a new tsa (ts) R so that any D.Data between 
%		timestamps t0 and t1, where t0 and t1 are in units, have been
%		removed
%
%   assumes t has same units as D
%   t0 and t1 can be arrays
%
% ADR 2011
% version L6.0

if nargin < 3
	error('ts:MismatchedRestrict','Use data for finding closest samples.')
end

if length(t0) ~= length(t1)
	error('ts:MismatchedRestrict','t0 and t1 must be same length')
end

toss = false(size(tsa.T));

for iT = 1:length(t0)
	toss = toss | (tsa.T >= t0(iT) & tsa.T <= t1(iT));	
end

keep = ~toss;
R = ts(tsa.T(keep));

