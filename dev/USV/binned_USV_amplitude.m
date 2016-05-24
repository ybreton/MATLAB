function [BinCenter,binnedAmplitudes,binnedSums,binnedNs] = binned_USV_amplitude(Frequencies,Amplitudes,varargin)
%
%
%
%

binSize = 1000;
process_varargin(varargin);


BinCenter = min(Frequencies(:))+binSize/2:binSize:max(Frequencies(:))-binSize/2;
nBins = length(BinCenter);
nFreq = size(Frequencies,2);

BinLo = BinCenter-binSize/2;
BinHi = BinCenter+binSize/2;

his = repmat(BinHi(:),1,nFreq);
los = repmat(BinLo(:),1,nFreq);

binnedAmplitudes = nan(size(Amplitudes,1),length(BinCenter));
DC = nan(size(Amplitudes,1),1);
DCsum = DC;
DCN = DCsum;
n = size(Frequencies,1);

for r = 1 : n
    instanceAmplitudes = Amplitudes(r,:);
    instanceFrequencies = Frequencies(r,:);
    
    idDC = instanceFrequencies==0 & ~isnan(instanceAmplitudes);
    DC(r) = nanmean(instanceAmplitudes(idDC));
    DCsum(r) = nansum(instanceAmplitudes(idDC));
    DCN(r) = length(instanceAmplitudes(idDC));
    
    amp = nan(1,nBins);
    
    instanceFrequencies = repmat(instanceFrequencies,nBins,1);
    
    id = (instanceFrequencies>los&instanceFrequencies<=his);
    
    for b = 1 : size(id,1)
        idBin = id(b,:);
        amp(b) = nanmean(instanceAmplitudes(idBin));
        pow(b) = nansum(instanceAmplitudes(idBin));
        N(b) = length(instanceAmplitudes(idBin&~isnan(instanceAmplitudes)));
    end
    binnedAmplitudes(r,:) = amp;
    binSums(r,:) = pow;
    binNs(r,:) = N;
end
BinCenter = [0 BinCenter];
binnedAmplitudes = [DC binnedAmplitudes];

if nargout>2
    binnedSums = [DCsum binSums];
end
if nargout>3
    binnedNs = [DCN binNs];
end