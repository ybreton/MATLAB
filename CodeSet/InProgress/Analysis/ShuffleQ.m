function Qout = ShuffleQ(Qin)

% Qout = ShuffleQ(Qin)
%
% Shuffles cell firing numbers, maintaining spikes within cell, but across
% entries
%
% ADR 2012-11

Q0D = full(Qin.data);
[nT, nC ] = size(Q0D);
for iC = 1:nC
    Q0D(:,iC) = Q0D(randperm(nT), iC);
end
Qout = tsd(Qin.range, Q0D);