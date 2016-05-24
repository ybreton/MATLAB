function [Q dt] = MakeQfromS_Theta(S,bins,varargin)

%Creates a Q matrix segmented into arbitrary intervals (ie by theta cycle) instead of a uniform dt.
%Built from MakeQfromS (adr).
% INPUTS:
%    S - a cell array of ts objects from a standard session data (sd)
%    structure
%    bins - structure with fields t0 and t1
%       1) t0  ts with nBins timestamps, start times of bins (ie start time of theta cycle from ThetaCycleBins)
%       2) t1  ts with nBins timestamps, end times of bins (ie end time of theta cycle)
%
% OUTPUTS:
%    Q - a tsd in which the main structure is a nBins x nCells histogram of firing rates
%    Q is aligned to start of bin times by default.
%    dt - ts of bin length [sec]. Useful for decoding...
% PARAMETERS:
%    tStart: 1x1 double, StartTime for the Q matrix, defaults to the minimum time in S
%    or bins
%    tEnd: 1x1 double, EndTime for the Q matrix, defaults to the maximum time in S
%    or bins
%    align2start: 1x1 logical, if true, Q matrix is aligned to bin start
%    times.  If false, Q matrix is aligned to the middle of each bin.


% amw - 15Feb2012
% 2012-05-21 AndyP
% made bins a tsd input, added eps parameter, restricted bins to
% min(SpikeTimes), simplified sparse matrix function call
% 2013-03-18 AndyP, bins are now matched samples of start/end times for each theta cycle.
% 2013-03-19 AndyP and ADR, correctly mapped odd integers (start times) onto integers for
% timeIndx, the index of the theta bin in the Q matrix.  Added align2start
% option.

assert(nargin >= 2, 'Call thus: MakeQfromS(S, bins).');
assert(isa(S, 'cell'), 'Type error: S should be a cell array of ts objects.');
assert(all(cellfun('isclass', S, 'ts')), 'Type error: S should be a cell array of ts objects.');
assert(~isempty(S), 'S is empty');
assert(isstruct(bins),'Type error: bins should be a structure of ts objects');
fnames=fieldnames(bins);
assert(any(strcmp(fnames,'t0')),'bins must contain field t0, the start time of bins');
assert(any(strcmp(fnames,'t1')),'bins must contain field t1, the end time of bins');
assert(isa(bins.t0,'ts'),'bins.t0 must be a a ts');
assert(isa(bins.t1,'ts'),'bins.t1 must be a a ts');
assert(length(bins.t0.data)==length(bins.t1.data),'t0 and t1 must be the same size');

% --------------------
% Defaults
% --------------------
tStart = min(cellfun(@starttime, S));
tStart = max(tStart, bins.t0.starttime);

tEnd = max(cellfun(@endtime, S));
tEnd = min(tEnd, bins.t0.endtime);

align2start = true;

process_varargin(varargin);
nCells = length(S);
nBins = length(bins.t0.range);

%---------------------
% Limit spiking to range
%--------------------
for iS = 1:nCells
	S{iS} = S{iS}.restrict(tStart, tEnd);
end

%--------------------
% Build Q Matrix
%--------------------
cellIndx = []; timeIndx = [];

for iC = 1:nCells
	if ~isempty(S{iC}.data())
		nSpikes = length(S{iC}.data());
		timeIndx = cat(1,timeIndx,S{iC}.data());
		cellIndx = cat(1, cellIndx, repmat(iC, nSpikes, 1));
	end; % if ~empty
end		% for all cells

[binsT,check]=sort(cat(1,bins.t0.data,bins.t1.data)); % 2013-03-18 AndyP
even = check(2:2:end);
odd = check(1:2:end);
assert(all(odd<=max(check)/2),'t0 and t1 are not correctly ordered t0(1)<t1(1)<t0(2)<t1(2) ...');
assert(all(even>max(check)/2),'t0 and t1 are not correctly ordered t0(1)<t1(1)<t0(2)<t1(2) ...');
[~, timeIndx] = histc(timeIndx,binsT); % 2013-03-18 AndyP
ok = mod(timeIndx,2)==1; % 2013-03-18 AndyP
cellIndx(timeIndx==0 | ~ok)=[]; % 2013-03-18 AndyP
timeIndx(timeIndx==0 | ~ok)=[]; % 2013-03-18 AndyP
assert(min(timeIndx)>0);
timeIndx = (timeIndx+1)/2; % (1->1  3->2 5->3 7->4) ... map odd integers to integers % 2013-03-18 AndyP, 2013-03-19 AndyP and ADR
s = ones(length(timeIndx),1);
assert(max(timeIndx)<=nBins);
if isempty(timeIndx)
	QData = zeros(length(bins)-1, nCells); % no spikes, it's a zero-matrix
else
	QData = sparse(timeIndx,cellIndx,s,nBins,nCells); % some matlab functions require full(Q)
end
%--------------------
% Build standard data structure
%--------------------
if align2start   
	Q = tsd(bins.t0.range,QData); % Q is aligned to start of bin times
else     
	Q = tsd((bins.t1.range-bins.t0.range)/2+bins.t0.range,QData); %#ok<UNRCH> % Q is aligned to middle of bins
end
	dt = ts([diff(Q.range); nan]);  
	
end