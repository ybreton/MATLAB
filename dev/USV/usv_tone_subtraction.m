function usv0 = usv_tone_subtraction(usv,varargin)
% Subtracts the power in the first ToneDuration secs from the power in the
% next (Window-ToneDuration) secs.
%
%
%

usvDownsample = 30;
binSize = 250; % in Hz
ToneDuration = 0.1; % in s
Window = 1; % in s
plotResult = true;
process_varargin(varargin);
s=0;
n=0;
for T = 1 : length(usv)
    % for each trial of usv, 
    signal = usv(T).Signal;
    
    signal = signal.restrict(min(signal.range),min(signal.range)+Window);
    [F,P]=ez_fft(signal.restrict(min(signal.range),min(signal.range)+ToneDuration));
    [F2,P2]=ez_fft(signal.restrict(min(signal.range)+ToneDuration,min(signal.range)+Window));
    
    [~,p] = binned_USV_amplitude(F*usvDownsample,P,'binSize',binSize);
    [f,p2] = binned_USV_amplitude(F2*usvDownsample,P2,'binSize',binSize);
    
    usv(T).FreqDiff = f;
    usv(T).PowerDiff = p2-p;
    s = s+(p2-p);
    n = n+1;
end
m = s/n;
if plotResult
    clf
    cmap = hsv(length(usv));
    hold on
    for T=1:length(usv)
        plot(usv(T).FreqDiff/1000,usv(T).PowerDiff,'-','color',cmap(T,:),'linewidth',1)
    end
    plot(f/1000,m,'k:','linewidth',2)
    xlabel('kHz')
    zlabel(sprintf('Power Difference\n(Last %.1fs - First %.1fs)',Window-ToneDuration,ToneDuration))
    hold off
end
usv0 = usv;
