function SR = RRpopSpikeRate(S,varargin)
% produced a tsd of the population spike rate for the cells specified by
% S.
% 
% SR = RRpopSpikeRate(S)
% where     SR      is a ctsd of the population spike rate
% 
%           S       is a cell array of ts' representing spike times for
%                       each cell.
%
% OPTIONAL ARGUMENTS:
% ******************
% window    (default .03125)     window over which to take spike rate. The
%                                   population spike rate at time t is
%                                   calculated as the number of spikes
%                                   counted between t-window/2 and
%                                   t+window/2, advancing in window time
%                                   steps.
% tMin      (default is first spike)
%                               first time (center of bin) of population ctsd
% tMax      (default is last spike)
%                               last time (center of bin) of population ctsd
%
window = 0.03125;

S = S(:);
T = [];
for iC=1:length(S)
    T = cat(1,T,S{iC}.data);
end
population = ts(T);
clear T
tMin = min(population.range);
tMax = max(population.range);
process_varargin(varargin);

tList = tMin+window/2:window:tMax-window/2;
T = population.data;
D = nan(length(tList),1);
parfor iT = 1:length(tList)
    t = tList(iT);
    t1 = t-window/2;
    t2 = t+window/2;
    
    nSpikes = sum(double(T>=t1&T<=t2));
    spikeRate = nSpikes/window;
    D(iT) = spikeRate;
end

SR = tsd(tList(:),D);