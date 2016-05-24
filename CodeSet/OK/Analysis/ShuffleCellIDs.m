function S = ShuffleCellIDs(S)
% S = ShuffleCellIDs(S)
%
% INPUTS
%   S - cell array of ts
%
% OUTPUTS
%   S - cell array of ts
%
% Shuffles Cell IDs so that the time of each spike is a constant, 
% but the cell to which it was assigned can change.
%
% Note: spikes that occur at the exact same time can sometimes be lost
% because they both get assigned to the same cell.
%
% ADR 2011-12

%-----------------
% CHECKS
%-----------------
assert(nargin==1, 'Call with S');
assert(isa(S, 'cell'), 'S is not a cell array');
assert(all(cellfun('isclass', S, 'ts')), 'S is not all ts objects.');

%-----------------
% GO
%-----------------
nC = length(S);
t = [];
for iC = 1:nC
	t = cat(1, t, S{iC}.data());
end

c = randi(nC, length(t), 1);
for iC = 1:nC
	t0 = unique(sort(t(c==iC)));
	S{iC} = ts(t0);
end