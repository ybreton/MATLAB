function psdObj = ez_psd(csc,varargin)
% Calculates the power spectral density of a continuously-sampled channel
% signal.
%
% ez_psd(csc)
%   where           csc         is a continuously-sampled channel tsd
% will plot the power-spectral density (dB/Hz vs Hz) function.
%
% psdObj = ez_psd(csc)
%   where           csc             is a continuously-sampled channel tsd
%
%                   psdObj          is a structure with fields
%                         .freq     is a vector of frequencies
%                         .data     is the power spectral density
%                         .fs       is the sampling frequency
%                         .fnyquist is the nyquist frequency (Fs/2)
%                         .dt       is the time difference of the original
%                                       csc
%                         .dF       is the frequency difference of the
%                                       power spectral density function
%                         .NFFT     is the number of discrete points used
%                                       for the fast Fourier transform
%
% OPTIONAL ARGUMENTS:
% ******************
% plotFlag          (default true if no output; false if returning psdObj)
%       force the power spectral density plot
% Title             (default input name of csc)
%       title of the power spectral density plot, if plotted
%
%

if nargout==0
    plotFlag = true;
else
    plotFlag = false;
end
Title = inputname(1);
process_varargin(varargin);

dt = csc.dt;
Fs = 1/dt;

D = csc.data;
sz = size(D);
D = D(:,:);

NFFT = 2^nextpow2(size(D,1));
f = 0:Fs/NFFT:Fs/2;
    
psdObj.freq = f(:);
data = nan(length(f(:)),size(D,2));
parfor iSignal=1:size(D,2)
    x = D(:,iSignal);
    
    xdft = fft(x,NFFT);
    xdft = xdft(1:NFFT/2+1);
    psdx = (1/(Fs*NFFT))*abs(xdft).^2;
    psdx(2:end-1) = 2*psdx(2:end-1);

    data(:,iSignal) = psdx(:);
end
psdObj.data = reshape(data,[length(f) sz(2:end)]);

psdObj.fs = Fs;
psdObj.fnyquist = Fs/2;
psdObj.dt = dt;
psdObj.dF = median(diff(f));
psdObj.NFFT = NFFT;

if plotFlag
    plot(psdObj.freq,10*log10(psdObj.data));
    xlabel('Frequency (Hz)')
    ylabel('Power spectral density (dB/Hz)')
    title(Title)
end


if nargout<1
    clear psdObj
end