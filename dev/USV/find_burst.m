function [t0,t1] = find_burst(signalCTSD,Hz,Window,varargin)
%
%
%
%
usvDownsample = 30;
plotSpectrogram = true;
process_varargin(varargin);

start = min(signalCTSD.range);
finish = max(signalCTSD.range);
dt = signalCTSD.dt;

k = 1;
for t = start+Window/2:dt:finish-Window/2
    windowedCTSD = signalCTSD.restrict(t-Window/2,t+Window/2);
    [Frequency,Power]=ez_fft(windowedCTSD);
    Frequency = Frequency*usvDownsample;
    Fresolution = mean(diff(Frequency(2:end)));
    Flo = Frequency-Fresolution/2;
    Fhi = Frequency+Fresolution/2;
    
    id = Flo<Hz & Fhi>=Hz;
    
    P = mean(Power(id));
    N = mean(Power(~id));
    
    SNR(k) = P/N;
    k = k+1;
    
    if plotSpectrogram
        Plist(:,k) = Power(:);
        imagesc([start:dt:t],Frequency/1000,Plist)
        axis xy
        drawnow
    end
end