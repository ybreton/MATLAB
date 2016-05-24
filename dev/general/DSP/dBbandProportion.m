function p = dBbandProportion(CSC,loF,hiF,varargin)
% Calculates the proportion of the area under the total spectral density
% curve (in dB) that is within a frequency band.
% Assumes a Welch spectral estimate using a 1.5s Hamming window with 50%
% overlap between windows.
%
% p = dBbandProportion(CSC,loF,hiF)
% where     p           is the proportional area of the spectral density
%                           curve (in dB).
%           [n x m x ... x p]
%
%           CSC         is a continuously-sampled channel for which to
%                           calculate the power spectral density.
%           [tsd/ctsd]
%           loF, hiF    are the lower and upper bounds of the band to
%                           consider, respectively.
%           [m x n x ... x p]
%
% OPTIONAL ARGUMENTS:
% ******************
% S             (default: spectrum.welch('Hamming',1.5/CSC.dt,50) )
%       a spectrum object for estimating power spectral density. Default is
%       a Welch estimator using a Hamming window of 1.5s with 50% overlap.
% rightEdged    (default: false)
%       a logical that specifies whether to include (true) or exclude
%       (false) frequencies equal to the right/upper edge of the frequency
%       band
% leftEdged     (default: true)
%       a logical that specifies whether to include (true) or exclude
%       (false) frequencies equal to the lower/left edge of the frequency
%       band
% normalizeNeg  (default: true)
%       a logical that specifies whether the PSD curve should be moved by a
%       constant equal to its minimum. When true, the PSD curve hits a
%       minimum dB value of 0.
%
% rightEdged and leftEdged can be 1x1 or of equal size to loF and hiF.
% 
% REVISION HISTORY:
% ****************
% 2015-02-18    (YAB)       added normalizeNeg flag to deal with negative
%                           dB values resulting in negative areas.
%
S=spectrum.welch('Hamming',1.5/CSC.dt,50);
rightEdged = false;
leftEdged = true;
normalizeNeg = true;
process_varargin(varargin);

assert(length(size(loF))==length(size(hiF)),'lower and upper bounds must have identical size.');
assert(all(size(loF)==size(hiF)),'lower and upper bounds must have identical size.')
assert(numel(leftEdged)==1|all(size(leftEdged)==size(loF)),'Left edge specification must be 1x1 or equal to bound specification.')
assert(numel(rightEdged)==1|all(size(rightEdged)==size(loF)),'Left edge specification must be 1x1 or equal to bound specification.')

sz = size(loF);
loF = loF(:);
hiF = hiF(:);

if numel(leftEdged)==1
    leftEdged = squeeze(leftEdged);
    leftEdged = repmat(leftEdged,sz);
end
if numel(rightEdged)==1
    rightEdged = squeeze(rightEdged);
    rightEdged = repmat(rightEdged,sz);
end
leftEdged = leftEdged(:);
rightEdged = rightEdged(:);

PSD=S.psd(CSC.data,'Fs',1/CSC.dt);
dB = 10*log10(PSD.Data);
if normalizeNeg
    const = min(dB);
    dB = dB-const;
end
AUC = nansum(dB,1);

p = nan(length(loF),1);
for iBand=1:length(loF)
    if leftEdged(iBand)==1
        idLo = PSD.Frequencies>=loF(iBand);
    elseif leftEdged(iBand)==0
        idLo = PSD.Frequencies>loF(iBand);
    else
        idLo = false(length(PSD.Frequencies),1);
    end
    if rightEdged(iBand)==1
        idHi = PSD.Frequencies<=hiF(iBand);
    elseif rightEdged(iBand)==0
        idHi = PSD.Frequencies<hiF(iBand);
    else
        idHi = false(length(PSD.Frequencies),1);
    end
    idBand = idLo&idHi;
    p(iBand) = nansum(dB(idBand),1)./AUC;
end

p = reshape(p,sz);