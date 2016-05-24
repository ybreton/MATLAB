function S = ShuffleISIs(S, t0, t1)

% S = ShuffleISIs(S, t0, t1)
%
% INPUTS
%   S - cell array of ts
%   t0 - starttime of pass (task)
%   t1 - endtime of pass (task)
%
% OUTPUTS
%   S - cell array of ts
%
% Shuffles ISIs of each cell to maintain first order dynamics, but
% breakdown second and subsequent orders
% 
% ADR 2012/11 Now restricts S to t0...t1 before shuffling

%-----------------
% CHECKS
%-----------------
assert(nargin==3, 'Call as S, t0, t1');
assert(isa(S, 'cell'), 'S is not a cell array');
assert(all(cellfun('isclass', S, 'ts')), 'S is not all ts objects.');

%-----------------
% GO
%-----------------
nC = length(S);
for iC = 1:nC	
	S{iC} = S{iC}.restrict(t0, t1);
	ISI = diff([t0; S{iC}.data(); t1]);
	S{iC} = ts(t0 + cumsum(ISI(randperm(length(ISI)))));
end

