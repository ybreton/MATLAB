function p = wrapRRrotatedDecoding(sd,varargin)
% returns a nT x Ti x nBin x nBin matrix of decoded position, rotated so
% that zone entries for all zones are aligned.
% p = wrapRRrotatedDecoding(sd,T1,T2,...,Tn)
% where     p       is a n x Tj x nBin x nBin matrix of decoded position probabilities,
%
%           sd      is a standard session data structre,
%           Tj      is a vector of time stamps to extract.
%
% OPTIONAL ARGUMENTS:
% ******************
% S         (default sd.S)      cell array of spike times,
% nBins     (default 64)        number of spatial x-y bins.
%
%

idStr = false(length(varargin),1);
for iV=1:length(varargin)
    idStr(iV)=ischar(varargin{iV});
end
idStr = find(idStr,1,'first');
Tlist=varargin(1:idStr-1);

S = sd.S;
nBins = 64;
varargin = varargin(idStr:end);
process_varargin(varargin);

nTlist = length(Tlist);
nTrl = nan(length(Tlist),1);
T = [];
for iT=1:nTlist;
    t0 = Tlist{iT};
    t0 = t0(:);
    Tlist{iT} = t0;
    nTrl(iT) = length(t0);
    T = [T; t0];
end

disp('Tuning curves...')
TC = TuningCurves(S,{{sd.x -250 250 nBins} {sd.y -250 250 nBins}});

disp('Q matrix...')
Q = MakeQfromS(S,0.125);
disp('Bayesian decoding...')
B = BayesianDecoding(Q,TC);
disp('Rotating decoding matrices...');
B.rotPxs = RRrotateDecoding(B,sd);

p = nan(nTlist,max(nTrl),nBins,nBins);

for iT=1:nTlist
    t0=Tlist{iT};
    p(iT,1:nTrl(iT),:,:) = B.rotPxs.data(t0);
end

