function [Frequencies,Power,Magnitude,Phases] = ez_fft(signalCTSD,window,varargin)
% [Frequencies,Power,Magnitude,Phases] = ez_fft(signalCTSD)
% where     Frequencies         is vector of frequencies
%           Power               is vector of frequency power
%           Magnitude           is vector of frequency absolute magnitude
%           Phases              is vector of frequency angle phases
%
%           signalCTSD          is a ctsd of the signal to analyze
%
% analyzes the entire signal contained in signalCTSD.
%
% [Frequencies,Power,Magnitude,Phases] = ez_fft(signalCTSD,window)
% where     Frequencies         is nWindows x 1 cell array of frequencies
%           Power               is nWindows x 1 cell array of frequency power
%           Magnitude           is nWindows x 1 cell array of frequency absolute magnitude
%           Phases              is nWindows x 1 cell array of frequency angle phases
%
%           signalCTSD          is a ctsd of the signal to analyze
%           window              is a nWindows x 2 matrix of windows to analyze
%
% analyzes the data within each window specified.
%
% OPTIONAL ARGUMENTS:
% ******************
% Hamming   (default false)     implements a Hamming window to each signal window
% Padding   (default false)     pads the end of the signal window with zeros
%
%

Hamming = false;
Padding = false;
process_varargin(varargin);

dt = signalCTSD.dt;
Fs = 1./dt;

if nargin<2
    window(1,1) = min(signalCTSD.range);
    window(1,2) = max(signalCTSD.range);
end
if isempty(window)
    window(1,1) = min(signalCTSD.range);
    window(1,2) = max(signalCTSD.range);
end
window = sort(window,2);
nRows = size(window,1);

if nRows>1
    Frequencies = cell(nRows,1);
    Power = cell(nRows,1);
    Magnitude = cell(nRows,1);
    Phases = cell(nRows,1);
end

for r = 1 : nRows
    t0 = max(min(signalCTSD.range),window(r,1));
    t1 = min(max(signalCTSD.range),window(r,2));
    subsignal = signalCTSD.restrict(t0,t1);
    y = subsignal.data;
    y = y(:)';
    L = length(y);
    if Hamming
        y = y.*hamming(L)';
    end
    NFFT = 2^nextpow2(L);
    if Padding
        y = [y zeros(1,NFFT-L)];
    end
    F = (Fs/2)*linspace(0,1,NFFT/2+1);

    Y = fft(y,NFFT);
    Y = Y(:)';
    
    if nargout>1
        Pow = (Y.*conj(Y))/NFFT;
        Pow = Pow(1:NFFT/2+1);
        Pow(2:end-1) = Pow(2:end-1)*2;
    end
    
    if nargout>2
        Mag = abs(Y(1:NFFT/2+1));
        Mag(2:end-1) = Mag(2:end-1)*2;
    end
    
    if nargout>3
        Phi = angle(Y(1:NFFT/2+1));
    end
    
    if nRows>1
        if nargout>0
            Frequencies{r} = F;
        end
        if nargout>1
            Power{r} = Pow;
        end
        if nargout>2
            Magnitude{r} = Mag;
        end
        if nargout>3
            Phases{r} = Phi;
        end
    else
        if nargout>0
            Frequencies = F;
        end
        if nargout>1
            Power = Pow;
        end
        if nargout>2
            Magnitude = Mag;
        end
        if nargout>3
            Phases = Phi;
        end
    end
end