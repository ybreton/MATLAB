function Wrap_RR_vocalization_spectrograms(varargin)
%
%
%
%
AudioStart = 'RR.EnteringZoneTime(RR.ZoneIn<10)';
conversion = 1e-6;
window = 0.5;
downsamplingRatio = 30;
process_varargin(varargin);

fn = FindFiles('csc*.ncs');
binWidth = -inf;
Tones = [];
MS = [];
nyquistFrequency = -inf;
for f = 1 : length(fn)
    pathname = fileparts(fn{f});
    pushdir(pathname);
    
    csc = LoadCSC(fn{f});
    dt = csc.dt;
    Fs = 1/dt;
    nyquistFrequency = max(nyquistFrequency,Fs/2)*downsamplingRatio;
    RRfn = FindFiles('RR*.mat','CheckSubdirs',0);
    for f0 = 1:length(RRfn)
        RR = load(RRfn{f0});
        startTimes = eval(AudioStart)*conversion;
        [MS0,fh] = mean_audio_spectrogram(csc,startTimes,window);
        close(fh);
        Tones = unique([Tones(:); unique(RR.FeederTone(:))]);
        if isempty(MS)
            MS = MS0;
            k = 2;
        else
            n = abs(size(MS,1)-size(MS0,1));
            if size(MS0,1)>size(MS,1)
                MS0(end+1:end+n,:) = nan;
            end
            if size(MS,1)>size(MS0,1)
                MS(end+1:end+n,:,:) = nan;
            end
            MS(:,:,k) = MS0;
            k = k+1;
        end
    end
    
    popdir;
end
MS = mean(MS,3);

Frequencies = (linspace(0,1,size(MS,1))'*nyquistFrequency)/1000;
times = linspace(-window,window,size(MS,2));
clf
fh=gcf;
hold on
axis xy
set(gca,'xlim',[-window window])
set(gca,'ylim',[0 nyquistFrequency/1000])
imagesc(times,Frequencies,log10(MS))
xlabel(sprintf('Time aligned to %s',AudioStart))
ylabel(sprintf('Audio Frequency (kHz)'));
cbh=colorbar;
set(get(cbh,'ylabel'),'string','Log Mean Power')
set(get(cbh,'ylabel'),'rotation',-90)
hold off