function [Q dt] = MakeQfromS_NonUniformTime(S,bins,varargin)

%Creates a Q matrix segmented into arbitrary intervals instead of a uniform dt.
%Built from MakeQfromS (adr)
% INPUTS:
%    S - a cell array of ts objects 
%        (as generated, for example, by LoadSpikes)
%    bins - a list of start times of whatever bins you want to use
%
% OUTPUTS:
%    Q - a tsd in which the main structure is a |t| x nCells histogram of firing rates
%    dt - a list of bin length (in s). Useful for dedcoding...
% PARAMETERS:
%    T_start: StartTime for the Q matrix, defaults to min(StartTime(S))
%    T_end: EndTime for the Q matrix, defaults to max(EndTime(S))
%    ProgressBar (default 'text'): if 'text', prints "converting n cells: ..."
%                                  if 'graphics', shows display bar
%                                  else shows nothing
%    Alignto0spike = 0; if 1 then uses "sec0" instead of "sec"

% amw - 15Feb2012
% 2012-05-21 AndyP  
% made bins a tsd input, added eps parameter, restricted bins to
% min(SpikeTimes), simplified sparse matrix function call

assert(nargin >= 2, 'Call thus: MakeQfromS(S, bins).');
assert(isa(S, 'cell'), 'Type error: S should be a cell array of ts objects.');
assert(all(cellfun('isclass', S, 'ts')), 'Type error: S should be a cell array of ts objects.');
assert(isa(bins,'ts'),'Type error: bins should be a tsd object');
assert(~isempty(S), 'S is empty');

% --------------------
% Defaults
% --------------------
tStart = min(cellfun(@starttime, S));
tStart = max(tStart, bins.starttime);

tEnd = max(cellfun(@endtime, S));
tEnd = min(tEnd, bins.endtime);

process_varargin(varargin);
nCells = length(S);
bins = bins.restrict(tStart,tEnd);
binsT = bins.range;
nBins = length(binsT);
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

[~, timeIndx] = histc(timeIndx,binsT); 
cellIndx(timeIndx==0)=[];
timeIndx(timeIndx==0)=[];
assert(min(timeIndx)>0);
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
Q = tsd(bins,QData);
dt = [diff(Q.range); nan];