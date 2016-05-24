function [R,Stab,fh] = vocalization_cross_coherence(csc,startTimes,stopTimes,varargin)
%
%
%
%

downsamplingRatio = 30;
% monitor downsamples 30:1
binSize = 1000;
% 1kHz bin
process_varargin(varargin);

dT = csc.dt;
Fs = 1/dT;
nyquistFreq = Fs/2*downsamplingRatio;

idx1 = startTimes<=max(csc.range)&startTimes>=min(csc.range);
idx2 = stopTimes<=max(csc.range)&stopTimes>=min(csc.range);

startTimes = startTimes(idx1);
stopTimes = stopTimes(idx2);

startTimes = startTimes(1:min(length(startTimes),length(stopTimes)));
stopTimes = stopTimes(1:min(length(startTimes),length(stopTimes)));


bin = binSize/2:binSize:nyquistFreq-binSize/2;
lb = bin-binSize/2;
ub = bin+binSize/2;

S = nan(length(bin),length(startTimes));
for t = 1 : length(startTimes)
    cscWindow = csc.restrict(startTimes(t),stopTimes(t));
    x = cscWindow.range-min(cscWindow.range);
    y = cscWindow.data;
    L = length(x);
    NFFT = 2^nextpow2(L);
    Y = fft(y,NFFT)/L;
    f = Fs/2*linspace(0,1,NFFT/2+1);
    % f in the csc is downsampled by a factor, so actual F is
    F0 = f*downsamplingRatio;
    Y0 = abs(Y(1:NFFT/2+1));
    Y0(2:end-1) = Y0(2:end-1)*2;
    
    S0 = nan(length(bin),1);
    parfor ib = 1 : length(bin)
        idx = F0>lb(ib)&F0<=ub(ib);
        p = sum(Y0(idx));
        S0(ib) = p;
    end
    S(:,t) = S0;
end

R = nan(length(bin));
parfor ib = 1 : length(bin)
    spec1 = S(ib,:);
    colR = nan(1,length(bin));
    for col = 1 : length(colR)
        spec2 = S(col,:);
        cellR = corrcoef(spec1,spec2);
        colR(col) = cellR(2);
    end
    R(ib,:) = colR;
end
if nargout>1
    Stab.DATA = S';
    Stab.HEADER = mat2can(bin(:)');
    Stab.binWidth = binSize;
    Stab.lb = lb';
    Stab.ub = ub';
end

if nargout>2
    fh=gcf;
    clf
    hold on
    colormap('jet')
    imagesc(bin/1000,bin/1000,R)
    caxis([-1 1])
    set(gca,'xlim',[0 nyquistFreq/1000])
    set(gca,'ylim',[0 nyquistFreq/1000])
    cbh=colorbar;
    set(get(cbh,'ylabel'),'string',sprintf('Coherence'))
    set(get(cbh,'ylabel'),'rotation',-90)
    xlabel('Frequency (kHz)')
    ylabel('Frequency (kHz)')
    hold off
end