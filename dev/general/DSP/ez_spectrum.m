function [Spectrum,RawFFT] = ez_spectrum(signal)
% ESD = dT^2*dftx^2
% PSD = 1/(Fs*N)*dftx^2
%
%

T = signal.range;
A = signal.data;
% First, the data have to be sampled at a constant rate.
dt = diff(T);
Fs = 1/(max(dt));
T0 = min(signal.range):max(dt):max(signal.range);
A0 = interp1(T,A,T0);

L = length(T0);

NFFT = 2^nextpow2(L);

Y = fft(A0(:))/NFFT;
xdft = fft(A0(:));
freq = Fs/2*linspace(0,1,NFFT/2+1)';

Spectrum.f = freq;
Spectrum.a = 2*abs(Y(1:NFFT/2+1));
Spectrum.Fs = Fs;
Spectrum.p = abs(Y(1:NFFT/2+1)).^2;
Spectrum.p(2:end-1) = Spectrum.p(2:end-1)*2;
Spectrum.psd = (1/(Fs*L)).*abs(xdft(1:NFFT/2+1)).^2;
Spectrum.psd(2:end-1) = Spectrum.psd(2:end-1)*2;
Spectrum.esd = (1/Fs).^2.*abs(xdft(1:NFFT/2+1)).^2;
Spectrum.esd(2:end-1) = Spectrum.esd(2:end-1)*2;


RawFFT.f = freq;
RawFFT.a = Y;
RawFFT.dft = xdft;