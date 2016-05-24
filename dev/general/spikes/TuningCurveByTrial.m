function TC = TuningCurveByTrial(S,D,t1,t2)
% Calculates tuning curve on trial-by-trial basis for spikes in S, along dimension D.
% TC = TuningCurveByTrial(S,D,t1,t2)
% where     TC is a structure with fields
%               .H      nTrials  x nCells x X x Y x ... x Z matrix of spike
%                           counts
%               .Occ    nTrials  x 1 x X x Y x ... x Z matrix of bin
%                           occupancies
%               .Norm   nTrials x nCells x X x Y x ... x Z matrix of bin
%                           occupancies for normalizing H
%               .min    nDims vector of dimension minima
%               .max    nDims vector of dimension maxima
%               .nBin   nDims vector of bins in each dimension
%               .binc   nDims cell array of bin centers for each dimension;
%                           the left-handed bins proceed from [Edge_i, Edge_i+1) 
%               .binEdges
%                       nDims cell array of bin edges for each dimension;
%                           the left-handed bins proceed from [Edge_i, Edge_i+1)
%                           with the final bin from [Edge_n, inf).
%               .tStart nTrials vector of trial start times
%               .tEnd   nTrials vector of trial end times
%               .H0     nCells x X x Y x ... x Z matrix of spike counts for
%                           all times between t1 and t2
%               .Occ0   X x Y x ... x Z matrix of bin occupancies for all
%                           times between t1 and t2
%               .Norm0  nCells x X x Y x ... x Z matrix of bin occupancies
%                           for normalizing H0 for all times between t1 and
%                           t2.
%
%           S is ts of spike times
%           D is cell array with each dimension:
%               Di can be {Xi, min, max, nbin}
%               Di can be {Xi, nbin}            (default min/max are min/max of Xi)
%               Di can be {Xi}                  (default nbin = 64)
%               Di can be Xi
%           t1 is list of trial start times
%           t2 is list of trial end times

if isa(S,'ts')
    S = {S};
end
nCells = length(S);
s = cell(nCells,1);

if ~iscell(D)
    D = {D};
end
if ~iscell(D{1})
    D = {D};
end
nDim = length(D);
nBin = nan(1,nDim);
xMin = nan(1,nDim);
xMax = nan(1,nDim);
X = cell(1,nDim);
for iDim=1:nDim
    D0 = D{iDim};
    switch length(D0)
        case 1
            nBin(iDim) = 64;
            xMin(iDim) = min(D0{1}.data);
            xMax(iDim) = max(D0{1}.data);
            X{iDim} = D0{1};
        case 2
            nBin(iDim) = D0{2};
            xMin(iDim) = min(D0{1}.data);
            xMax(iDim) = max(D0{1}.data);
            X{iDim} = D0{1};
        case 4
            nBin(iDim) = D0{4};
            xMin(iDim) = D0{2};
            xMax(iDim) = D0{3};
            X{iDim} = D0{1};
        otherwise
            error(['Dimension ' num2str(iDim) ' must be a cell array with 1, 2 or 4 elements.'])
    end
end
x = D;

assert(length(t1)==length(t2),'Start and end times must match.')
nTrls = length(t1);

% Prepare the structure
S0 = cell(length(S),1);
for iC=1:length(S)
    S0{iC} = S{iC}.restrict(t1,t2);
end
D0 = D;
binc = cell(1,nDim);
binEdges = cell(1,nDim);
for iDim=1:length(D)
    D0{iDim}{1} = D{iDim}{1}.restrict(t1,t2);
    binEdges{iDim} = linspace(xMin(iDim),xMax(iDim),nBin(iDim));
    binW = diff(binEdges{iDim});
    binc{iDim} = [binEdges{iDim}(1:end-1)+binW/2 binEdges{iDim}(end)+binW(end)/2];
end
TC = TuningCurves(S0,D0);
TC.tStart = t1;
TC.tEnd = t2;
TC.binc = binc;
TC.binEdges = binEdges;
TC.H0 = TC.H;
TC.Occ0 = TC.Occ;
TC.Norm0 = repmat(reshape(TC.Occ,[1 nBin]),[nCells ones(1,length(nBin))]);

%H = nan([nTrls nCells nBin]);
%Occ = nan([nTrls 1 nBin]);
H = [];
Occ = [];
for iTrl=1:nTrls
    empty = false(nDim,1);
    for iDim=1:nDim
        x{iDim}{1} = X{iDim}.restrict(t1(iTrl),t2(iTrl));
        empty(iDim) = isempty(x{iDim}{1}.data);
    end
    for iC=1:nCells
        s{iC} = S{iC}.restrict(t1(iTrl),t2(iTrl));
    end
    if any(~empty)
        TC0 = TuningCurves(s,x,'tStart',t1(iTrl),'tEnd',t2(iTrl));
        H0 = reshape(TC0.H,[1 size(TC0.H)]);
        Occ0 = reshape(TC0.Occ,[1 1 size(TC0.Occ)]);
    else
        H0 = nan([1,size(TC.H)]);
        Occ0 = nan([1,1,size(TC.Occ)]);
    end
    H = cat(1,H,H0);
    Occ = cat(1,Occ,Occ0);
end
Norm = repmat(Occ,[1 nCells ones(1,length(nBin))]);

TC.H = H;
TC.Occ = Occ;
TC.Norm = Norm;