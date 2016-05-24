function [audio,AudioData_tab] = collect_vocalizations(varargin)


csc = 1;
ZF = 10;
conversion = 1e-6;
monitorDownsample = 30;
debug = true;
process_varargin(varargin);

RRfn = FindFiles('RR-*.mat');
fList = cell(0,1);
for f = 1 : length(RRfn)
    fn = RRfn{f};
    SSN = load(fn);
    if isfield(SSN,'EnteringZoneTime')
        fList{length(fList)+1} = fn;
    end
end
RRfn = fList;
cmap = jet(length(RRfn));
m = 1;
REm = 1;
UEm = 1;
Sm = 1;
DATA = [];
% audio_row, trial_num, tone, entered, rewarded, pellets, probability, zone, frequency, amplitude 
HEADER = {'audio_row', 'trial', 'tone', 'entered', 'rewarded', 'nPellets', 'Prob', 'Zone', 'Frequency', 'Amplitude'};

for f = 1 : length(RRfn)
    fn = RRfn{f};
    [pathname,filename,ext] = fileparts(fn);
    pushdir(pathname);
    
    CSC = LoadCSC(sprintf('CSC%d.ncs',csc));
    SSN = load([filename ext]);
    k = 1;
    
    StartTime = nan(length(SSN.EnteringZoneTime(SSN.ZoneIn<ZF)),1);
    StopTime = nan(length(SSN.EnteringZoneTime(SSN.ZoneIn<ZF)),1);
    Entered = false(length(SSN.EnteringZoneTime(SSN.ZoneIn<ZF)),1);
    Skipped = false(length(SSN.EnteringZoneTime(SSN.ZoneIn<ZF)),1);
    Rewarded = false(length(SSN.EnteringZoneTime(SSN.ZoneIn<ZF)),1);
    if numel(SSN.nPelletsPerDrop)<length(unique(SSN.ZoneIn(SSN.ZoneIn<ZF)))
        SSN.nPelletsPerDrop = repmat(SSN.nPelletsPerDrop(:)',1,length(unique(SSN.ZoneIn(SSN.ZoneIn<ZF))));
    end
    if length(SSN.nPelletsPerDrop)<length(SSN.ZoneIn(SSN.ZoneIn<ZF))
        z0 = 1;
        for z = 1 : length(SSN.ZoneIn)
            if SSN.ZoneIn(z)<ZF
                zone = SSN.ZoneIn(z);
                nP(z0) = SSN.nPelletsPerDrop(zone);
                z0 = z0+1;
            end
        end
    end
    SSN.nPelletsPerDrop = nP;
    for z = 1 : length(SSN.EnteringZoneTime)-1
        if SSN.ZoneIn(z)<ZF
            StartTime(k) = SSN.EnteringZoneTime(z)*conversion;
            StopTime(k) = SSN.EnteringZoneTime(z+1)*conversion;
            nPellets(k) = SSN.nPelletsPerDrop(k);
            probability(k) = SSN.ZoneProbability(z);
            zone(k) = SSN.ZoneIn(z);
            trial(k) = k;
            atZone(k) = true;
            if SSN.ZoneIn(z+1)>=ZF
                Entered(k) = true;
                Skipped(k) = false;
                Rewarded(k) = SSN.FireFeeder(k);
            end
            if SSN.ZoneIn(z+1)<ZF
                Entered(k) = false;
                Skipped(k) = true;
                Rewarded(k) = false;
            end
            k = k+1;
        end
    end
    if SSN.ZoneIn(end)<ZF
        StartTime(k) = SSN.EnteringZoneTime(end)*conversion;
        StopTime(k) = StartTime(k)+2;
        Entered(k) = false;
        Skipped(k) = true;
        Rewarded(k) = false;
    end
    
    for k = 1 : length(StartTime)
        audio(m).Start = StartTime(k);
        audio(m).Stop = StopTime(k);
        audio(m).Entered = Entered(k);
        audio(m).Skipped = Skipped(k);
        audio(m).Rewarded = Rewarded(k);
        audio(m).CSC = CSC.restrict(StartTime(k),StopTime(k));
        audio(m).data = audio(k).CSC.data;
        audio(m).time = audio(k).CSC.range;
        L = length(audio(m).CSC.range);
        NFFT = 2^nextpow2(L);
        T = audio(m).CSC.range-min(audio(k).CSC.range);
        
        Fs = 1./median(diff(T));
        y = audio(m).CSC.data;
        Y = fft(y)/NFFT;
        freq = Fs/2*linspace(0,1,NFFT/2+1)';
        audio(m).fft.y = Y;
        audio(m).fft.f = freq;
        audio(m).Spectrum.f = freq*monitorDownsample;
        audio(m).Spectrum.a = 2*abs(Y(1:NFFT/2+1));
        audio(m).Fs = Fs;
        
        nrows = length(audio(m).Spectrum.f);
        DATA = [DATA;
             ones(nrows,1)*m ones(nrows,1)*k ones(nrows,1)*SSN.FeederTone(k) ones(nrows,1)*Entered(k) ones(nrows,1)*Rewarded(k) ones(nrows,1)*nPellets(k) ones(nrows,1)*probability(k) ones(nrows,1)*zone(k) audio(m).Spectrum.f audio(m).Spectrum.a];
         % audio_row, trial_num, tone, entered, rewarded, pellets, probability, zone, frequency, amplitude 
        
        m = m+1;
    end
    popdir;
end

if debug
    clf
    subplot(4,1,1)
    hold on
    title('All Trials')
    scatterplotc(DATA(:,9)/1000,DATA(:,2),DATA(:,10),'solid_face',true)
    plot(DATA(:,3)/1000,DATA(:,2),'w+')
    set(gca,'ylim',[1 max(DATA(:,2))])
%     xlabel(sprintf('Audio Frequency on CSC%d\n(Downsampled at monitor out %.1f:1)',csc,monitorDownsample))
    ylabel('Trial Number')
    ch=colorbar;
    set(get(ch,'ylabel'),'string','Amplitude')
    set(get(ch,'ylabel'),'rotation',-90)
    hold off
    id = DATA(:,4)==1 & DATA(:,5)==1;
    subplot(4,1,2)
    hold on
    title('Rewarded Trials')
    scatterplotc(DATA(id,9)/1000,DATA(id,2),DATA(id,10),'solid_face',true)
    plot(DATA(id,3)/1000,DATA(id,2),'w+')
    set(gca,'ylim',[1 max(DATA(:,2))])
%     xlabel(sprintf('Audio Frequency on CSC%d\n(Downsampled at monitor out %.1f:1)',csc,monitorDownsample))
    ylabel('Trial Number')
    ch=colorbar;
%     set(get(ch,'ylabel'),'string','Amplitude')
%     set(get(ch,'ylabel'),'rotation',-90)
    hold off
    id = DATA(:,4)==1 & DATA(:,5)==0;
    subplot(4,1,3)
    hold on
    title('Unrewarded Trials')
    scatterplotc(DATA(id,9)/1000,DATA(id,2),DATA(id,10),'solid_face',true)
    plot(DATA(id,3)/1000,DATA(id,2),'w+')
    set(gca,'ylim',[1 max(DATA(:,2))])
%     xlabel(sprintf('Audio Frequency on CSC%d\n(Downsampled at monitor out %.1f:1)',csc,monitorDownsample))
    ylabel('Trial Number')
    ch=colorbar;
%     set(get(ch,'ylabel'),'string','Amplitude')
%     set(get(ch,'ylabel'),'rotation',-90)
    hold off
    id = DATA(:,4)==0;
    subplot(4,1,4)
    hold on
    title('Skipped Trials')
    scatterplotc(DATA(id,9)/1000,DATA(id,2),DATA(id,10),'solid_face',true)
    plot(DATA(id,3)/1000,DATA(id,2),'w+')
    set(gca,'ylim',[1 max(DATA(:,2))])
    xlabel(sprintf('Audio Frequency in kHz on CSC%d\n(Downsampled at monitor out %.1f:1)',csc,monitorDownsample))
    ylabel('Trial Number')
    ch=colorbar;
%     set(get(ch,'ylabel'),'string','Amplitude')
%     set(get(ch,'ylabel'),'rotation',-90)
    hold off
end

AudioData_tab.HEADER = HEADER;
AudioData_tab.DATA = DATA;