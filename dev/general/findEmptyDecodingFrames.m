function emptyTimes = findEmptyDecodingFrames(S,B)
% finds time stamps in B for which no spikes in s were fired within dt.
%
%
%

T = [];
D = [];
for iC=1:length(S)
    T = [T; S{iC}.data];
    D = [D; ones(length(S{iC}.data),1)*iC];
end
[T,idSort] = sort(T);
D = D(idSort);
N = tsd(T,D);
clear T D

emptyTimes = [];
T0 = B.pxs.range;
D0 = nan(length(T0),1);
for iT=1:length(T0)
    N0 = N.restrict(T0(iT)-B.pxs.dt/2,T0(iT)+B.pxs.dt/2);
    D0(iT) = length(N0.data);
end

emptyTimes = T0(D0==0);