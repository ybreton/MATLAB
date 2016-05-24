function [S,fh] = vocalization_spectra(csc,startTimes,stopTimes,downsamplingRatio)
%
%
%
%

S = [];
allx = csc.range-min(csc.range);
Fs = 1/(mean(diff(allx)));
N = length(allx);
Flist = Fs/2*linspace(0,1,N/2+1)*downsamplingRatio;
id = Flist>=1 & Flist<200*1000;
N = sum(double(id));
Flist = Flist(id);
gridY = nan(N,min(length(startTimes),length(stopTimes)));
for t = 1 : min(length(startTimes),length(stopTimes))
    t1 = startTimes(t);
    t2 = stopTimes(t);
    
    cscWindow = csc.restrict(t1,t2);
    x = (cscWindow.range)-min(cscWindow.range);
    y = cscWindow.data;
    Fs = 1/(mean(diff(x)));
    nfft = 2.^nextpow2(length(y));
    Y=fft(y,nfft)/length(y);
    f=Fs/2*linspace(0,1,nfft/2+1)*downsamplingRatio;
    Yplot=Y(1:nfft/2+1);
    
    start = ones(length(Yplot),1)*startTimes(t);
    stop  = ones(length(Yplot),1)*stopTimes(t);
    S = [S;
        start stop f(:) abs(Yplot)];
    id = f>=1&f<200*1000;
    listY = abs(Yplot(id));
    gridY(1:length(listY),t) = listY(:);
end

if nargout>1
    fh=gcf;
    clf
    hold on
    imagesc(1:min(length(startTimes),length(stopTimes)),Flist,gridY)
    set(gca,'xlim',[1 min(length(startTimes),length(stopTimes))])
    set(gca,'ylim',[1 200*1000])
    xlabel(sprintf('Time'))
    ylabel(sprintf('Frequency [Hz]'))
    hold off
end