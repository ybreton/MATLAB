function [MS,fh]= mean_audio_spectrogram(csc,eventTime,eventWindow)

xw = 0.01;

for event = 1 : length(eventTime)
    csc2 = csc.restrict(eventTime(event)-eventWindow,eventTime(event)+eventWindow);
    Time = csc2.range;
    realignTime = Time-eventTime(event);
    csc2 = tsd(realignTime,csc2.data);
    [T,F,S] = audio_spectrogram(csc2,xw);
    S0(:,:,event) = S;
end
MS = mean(S0,3);

if nargout>1

    fh=gcf;
    clf
    hold on
    axis xy
    imagesc(T(1,:),F(:,1)/1000,MS)
    xlabel('Time')
    ylabel('Audio Frequency (kHz)')
    set(gca,'xlim',[0 max(T(:))])
    set(gca,'ylim',[0 max(F(:)/1000)])
    cbh = colorbar;
    set(get(cbh,'ylabel'),'string','Power')
    set(get(cbh,'ylabel'),'rotation',-90)
    hold off
end