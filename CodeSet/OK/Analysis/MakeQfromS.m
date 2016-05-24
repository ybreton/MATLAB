function Q = MakeQfromS(S, DT, varargin)
%
% Q = MakeQfromS(S, DT, parameters)
% 
% 
% INPUTS:
%    S - a cell array of ts objects 
%        (as generated, for example, by LoadSpikes)
%    DT - timestep for ctsd (measured in timestamps!)
%
% OUTPUTS:
%    Q - a ctsd in which the main structure is a |t| x nCells histogram of firing rates
%
% PARAMETERS:
%    T_start: StartTime for the Q matrix, defaults to min(StartTime(S))
%    T_end: EndTime for the Q matrix, defaults to max(EndTime(S))
%    ProgressBar (default 'text'): if 'text', prints "converting n cells: ..."
%                                  if 'graphics', shows display bar
%                                  else shows nothing
%    Alignto0spike = 0; if 1 then uses "sec0" instead of "sec"

% ADR 1998
%  version L5.6
%  status: PROMOTED

% v5.0 30 Oct 1998 time is now first dimension.  INCOMPAT with v4.0.
% v5.1 13 Nov 1998 SCowen found a bug with some cells empty.  Fixed.
% v5.2 18 Nov 1998 Now can create a zero matrix.
% v5.3 19 Nov 1998 ProgresBar flag
% v5.4 21 Nov 1998 fixed [timeIndx T_end] bug
% v5.5 25 Nov 1998 fixed T_end bug
% v5.6 10 May 2000 if no start/end found/given, returns empty Q matrix

assert(nargin >= 2, 'Call thus: MakeQfromS(S, DT).');
assert(isa(S, 'cell'), 'Type error: S should be a cell array of ts objects.');
assert(all(cellfun('isclass', S, 'ts')), 'Type error: S should be a cell array of ts objects.');

% --------------------
% Defaults
% --------------------
  
tStart = min(cellfun(@starttime, S));
tEnd = max(cellfun(@endtime, S));

process_varargin(varargin);

nCells = length(S);

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

nSpikes = length(timeIndx);

timeIndx = round((timeIndx - tStart)/DT)+1; % reset time of first spike in data to zero
endIndx = round((tEnd - tStart)/DT)+1;
s = ones(nSpikes,1);
nTime = max([timeIndx; endIndx]);

if isempty(timeIndx)
   QData = zeros(nTime, nCells); % no spikes, it's a zero-matrix
else
   QData = sparse(timeIndx,cellIndx, s, nTime, nCells); % some matlab functions require full(Q)
end

%--------------------
% Build standard data structure
%--------------------
Q = ctsd(tStart, DT, QData);




