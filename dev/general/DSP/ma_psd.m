function psdObj = ma_psd(csc,window,varargin)
% Moving-average power spectral density function.
% ma_psd(csc,window)
%       where       csc         is a tsd of a continuously-sampled channel
%                   window      is the length of the temporal window to
%                                   slide along the CSC channel
% plots the mean power spectral density function in a sliding window of
% duration "window" across the entire duration of the continuously-sampled
% channel "csc".
%
% psdObj = ma_psd(csc,window)
%       where       psdObj      is a power spectral density object as
%                                   returned by ez_psd with fields
%                         .freq     is a vector of frequencies
%                         .data     is the power spectral density averaged
%                                       across all sliding windows
%                         .fs       is the sampling frequency
%                         .fnyquist is the nyquist frequency (Fs/2)
%                         .dt       is the time difference of the original
%                                       csc
%                         .dF       is the frequency difference of the
%                                       power spectral density function
%                         .NFFT     is the number of discrete points used
%                                       for the fast Fourier transform
%                         .window   is the duration of the window being
%                                       slid along the entire csc.
%
% OPTIONAL ARGUMENTS:
% ******************
% plotFlag          (default true if no output; false if returning psdObj)
%       force the power spectral density plot
% Title             (default input name of csc)
%       title of the power spectral density plot, if plotted
%
%
Title = inputname(1);
plotFlag = (nargout<1);
process_varargin(varargin);

t = csc.range;
d = csc.data;
dt = csc.dt;

tFull = min(t):dt:max(t);
dFull = interp1(t,d,tFull);

Fs = 1/dt;
Fnyquist = Fs/2;

n = ceil(window/dt);
NFFT = 2^nextpow2(n);

freq = 0:Fs/NFFT:Fs/2;
time = (linspace(0,window,length(freq)))';

idWindow = 1:length(time);
nWindows = length(tFull)-length(time);

d0 = nan(nWindows,length(time));
disp(['Isolating ' num2str(nWindows) ' sliding windows of ' num2str(length(time)) ' samples...'])
parfor iT=0:nWindows-1
    I = idWindow+iT;
    d0(iT+1,:) = dFull(I);
end
csc0 = tsd(time(:),d0');
disp(['Processing PSDs from ' num2str(nWindows) ' sliding windows of duration ' num2str(window) ' sec...'])
psd0 = ez_psd(csc0);

psdObj.freq = freq(:);
psdObj.data = (nanmean(psd0.data,2));
psdObj.window = window;
psdObj.fs = Fs;
psdObj.fnyquist = Fnyquist;
psdObj.dt = dt;
psdObj.dF = median(diff(freq));
psdObj.NFFT = NFFT;

if plotFlag
    plot(psdObj.freq,10*log10(psdObj.data));
    xlabel('Frequency (Hz)')
    ylabel(sprintf('Mean power spectral density (dB/Hz)\nin %.1fsec sliding window',window))
    title(Title)
end

if nargout<1
    clear psdObj
end