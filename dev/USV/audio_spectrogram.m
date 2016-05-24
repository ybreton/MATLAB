function [T,F,S] = audio_spectrogram(csc,xw,varargin)
% finds the audio spectral density at each xw time window in csc.
%
%
%

downsamplingRatio = 30;
process_varargin(varargin);

Fs = 1/csc.dt;
nyquistFrequency = Fs/2*downsamplingRatio;

timeBins = min(csc.range)+xw/2:xw:max(csc.range)-xw/2;
F = [];
for bin = 1 : length(timeBins)
    cscTimeBin = csc.restrict(timeBins(bin)-xw/2,timeBins(bin)+xw/2);
    
    y = cscTimeBin.data;
    L = length(y);
    NFFT = 2^nextpow2(L);
    Y = fft(y,NFFT)/L;
    F0 = nyquistFrequency*linspace(0,1,NFFT/2+1);
    Y0 = abs(Y(1:NFFT/2+1));
    Y0(2:end-1) = 2*Y0(2:end-1);
    
    S(1:NFFT/2+1,bin) = Y0(:);
    T(1:NFFT/2+1,bin) = timeBins(bin);
    F(1:NFFT/2+1,bin) = F0(:);
end