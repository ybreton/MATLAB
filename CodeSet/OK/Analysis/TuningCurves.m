function TC = TuningCurves(S, D, varargin)

% TC = TuningCurves(S, {D1, D2, D3, ...,} varargin)
%
% 
% INPUTS:
%      S -- a cell array of class ts or a single object of class ts
%      Di -- a set of dimensions
%         Di can be {Xi, min, max, nbin}
%         Di can be {Xi, nbin}
%         Di can be {Xi}
%         Di can be Xi
%            where
%              min = minimum along that dimension 
%                 (defaults to minimum value on that dimension)
%              max = maximum along that dimension
%                 (defaults to maximum value on that dimension)
%              nBins = number of bins along that dimension (defaults to 64)
%              Xi is a class tsd or ctsd along which we are finding the tuning
% 
% OUTPUTS:
%    TC -- an object containing the following components
%       H - an n+1-dimensional matrix of number of spikes occuring at each bin
%          first dimension indexes cells, second and further dimensions
%          index Di
%       min - minimum values along each dimension
%       max - maximum values along each dimension
%       nBin - number of bins along each dimension
%       Occ - an n-dimensional matrix of Occupancy within each bin (in seconds)
%
%    NOTE: TC is not normalized by default.  To normalize TC, use TC/(Occ + epsilon)
%
% ADR 1998
% version 6.1
% status: PROMOTED
%
% v 4.1 2 nov 1998 now takes out all NaNs.
% v 4.2 17 nov 1998 now correctly returns same order of dimensions
% v 5.0 8 dec 1999 now uses timestamps from first dim input (X1) for occupancy samples
% v 6.0 12 sep 2002 if nargout = 1, then tc is normalized.
% v 7.0 27 dec 2011 no longer normalize TC for one cell.  changed inputs
% and outputs dramatically, rewrote to use histcn
% ADR 11 Jan 2012: Fixed error when there were no spikes and multiple
% dimensions

if length(S)==1 && isa(S, 'ts'), S = {S}; end
if length(D)==1 && (isa(D, 'tsd') || isa(D, 'ctsd')), D = {D}; end

binDefault = 64;

%--------------------
% Unpack inputs
% V = cell array of tsd or ctsd of each dimension
% nV = array of bins for each dimension
%--------------------
nC = length(S);
nD = length(D);
X = cell(1,nD);
minX = nan(1,nD);
maxX = nan(1,nD);
binX = nan(1,nD,1);

for iD = 1:nD
	V = D{iD};
	if isa(V, 'tsd') || isa(V, 'ctsd')
		X{iD} = V;
		minX(iD) = min(X{iD}.data());
		maxX(iD) = max(X{iD}.data());
		binX(iD) = binDefault;
	else
		switch length(V)
			case 1 % {Di}
				X{iD} = V{1};
				minX(iD) = min(X{iD}.data());
				maxX(iD) = max(X{iD}.data());
				binX(iD) = binDefault;
			case 2 % {Di, nB}
				X{iD} = V{1};
				minX(iD) = min(X{iD}.data());
				maxX(iD) = max(X{iD}.data());
				binX(iD) = V{2};
			case 4 % {Di, min, max, nB}
				X{iD} = V{1};
				minX(iD) = V{2};
				maxX(iD) = V{3};
				binX(iD) = V{4};
			otherwise
				error('Unknown calling structure.');
		end
	end % dimenision D
	assert(size(X{iD}.data(),2)==1, 'X(%D) multidimensional');
end

% --------------------
% CHECKS
% --------------------
assert(isa(S, 'cell'), 'Type error: S should be a cell array of ts objects.');
assert(all(cellfun('isclass', S, 'ts')), 'Type error: S should be a cell array of ts objects.');

% --------------------
% DEFAULTS
% --------------------
tStart = min(cellfun(@starttime, X));
tEnd = max(cellfun(@endtime, X));

process_varargin(varargin);

%--------------------
% RESTRICT
%--------------------
% restrict data to be in range for which we have 
% sufficient data
for iD = 1:nD
	X{iD} = X{iD}.restrict(tStart, tEnd);
end

for iC = 1:nC
	S{iC} = S{iC}.restrict(tStart, tEnd);
end

%--------------------
% Calculate edges
%--------------------
E = cell(nD,1);
for iD = 1:nD
	E{iD} = linspace(minX(iD), maxX(iD), binX(iD));
end

%--------------------
% Calculate fields
%--------------------
H = nan([nC binX]);

% foreach cell in the SpikeList
for iC = 1:nC
   
   Sd = S{iC}.data();
   
   if isempty(Sd) % no spikes
      H0 = squeeze(zeros([1 binX]));	
	  H(iC,:) = H0(:);
   else  % there are spikes
	   M = nan(length(Sd), nD);
	   for iD = 1:nD
		   M(:,iD) = X{iD}.data(Sd);		   
	   end	   
	   H0 = histcn(M, E{:});
	   H(iC,:) = H0(:);
   end    
end

%--------------------
% Calculate Occupancy
%--------------------
if length(binX)==1
	Occ = nan([binX 1]);
else
	Occ = nan(binX);
end

timestamps = X{1}.range();            % timing of first inputs
nSteps = length(timestamps);
M = nan(nSteps,nD);
for iD = 1:nD
	M(:,iD) = X{iD}.data(timestamps);
end
Occ = histcn(M, E{:});

Occ = Occ * X{1}.dt(); % normalize for time

%-----------------------
% Build output object
%-----------------------
TC.H = H;
TC.Occ = Occ;
TC.min = minX;
TC.max = maxX;
TC.nBin = binX;
TC.tStart = tStart;
TC.tEnd = tEnd;