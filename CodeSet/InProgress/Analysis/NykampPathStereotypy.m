function [ D ] = NykampPathStereotypy( sd, L0, L1, varargin )
%[ R ] = NykampPathStereotypy( sd, L0, L1, varargin )
% parms:
% nSampsPerLap = 1000;
% maxLaps = inf; % so will return a matrix of appropriate size
% Distance = 1/n * sqrt(sum_d integral (f(s) - g(s)) ds)

nSampsPerLap = 1000;
maxLaps = Inf;
varargin = process_varargin(varargin);

% check
assert(length(L0)==length(L1), 'lap ID mismatch');
assert(all(L1>L0), 'lapend < lapstart');

nLaps = length(L0);

if length(L0) > maxLaps
    L0 = L0(1:maxLaps);
    L1 = L1(1:maxLaps);
    nLaps = maxLaps;
end

nLaps = length(L0);

zT = sd.x.range;
xD = sd.x.data;
yD = sd.y.data;
z = tsd(zT, [xD yD]);
D = NykampDistance(z, L0, L1, 'nSampsPerLap', nSampsPerLap);

end

