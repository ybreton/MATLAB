function [AudioTab,AudioStruct] = process_start_stop_audio(varargin)

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

DATA = [];
%           1       2       3       4           5           6       7           8       9       10          11          12          13                      14
HEADER = {'Session' 'Trial' 'Zone' 'Pellets' 'Probability' 'Tone' 'AtZone' 'AtFeeder' 'Entered' 'Rewarded' 'Frequency' 'Amplitude' 'Power Spectral Density' 'Energy Spectral Density'};
for f = 1 : length(RRfn)
    fn = RRfn{f};
    [pathname,filename,ext] = fileparts(fn);
    pushdir(pathname);
    
    CSC = LoadCSC(sprintf('CSC%d.ncs',csc));
    SSN = load([filename ext]);
    
    Entered = false(length(SSN.EnteringZoneTime),1);
    Skipped = false(length(SSN.EnteringZoneTime),1);
    Rewarded = false(length(SSN.EnteringZoneTime),1);
    SSN.nPelletsPerDrop = fix_nPellets_Per_Drop(SSN.nPelletsPerDrop,SSN.ZoneIn);
    
    StartTime = SSN.EnteringZoneTime(:)*conversion;
    StopTime = [SSN.EnteringZoneTime(:);SSN.EnteringZoneTime(end)]*conversion;
    StopTime(1) = [];
    StopTime(end) = StopTime(end)+2;
    nPellets = SSN.nPelletsPerDrop(:);
    probability = SSN.ZoneProbability(:);
    zone = SSN.ZoneIn(:);
    atZone = zone<ZF;
    atFeeder = zone>=ZF;
    idx = 1:length(zone);
    idFeeder = idx(atFeeder);
    zone(atFeeder) = zone(idFeeder-1);
    entered = atFeeder;
    entered(1:end-1) = entered(1:end-1)|atZone(1:end-1)&atFeeder(2:end);
    
    k = 0;
    trial = nan(length(atZone),1);
    tone = nan(length(atZone),1);
    firefeeder = false(length(atZone),1);
    for z = 1 : length(SSN.EnteringZoneTime)
        if SSN.ZoneIn(z)<ZF
            k = k+1;
        end
        trial(z) = k;
        tone(z) = SSN.FeederTone(k);
        firefeeder(z) = SSN.FireFeeder(k);
    end
    rewarded = firefeeder&entered;
    
    for z = 1 : length(StartTime)
        audio(z).Start = StartTime(z);
        audio(z).Stop = StopTime(z);
        audio(z).CSC = CSC.restrict(StartTime(z),StopTime(z));
        [audio(z).Spectrum, audio(z).fft] = ez_spectrum(audio(z).CSC);
        audio(z).Session = RRfn{f};
        audio(z).SessNum = f;
        audio(z).Trial = trial(z);
        audio(z).Zone = zone(z);
        audio(z).AtZone = atZone(z);
        audio(z).AtFeeder = atFeeder(z);
        audio(z).Entered = entered(z);
        audio(z).Rewarded = rewarded(z);
        audio(z).nPellets = nPellets(z);
        audio(z).Probability = probability(z);
        audio(z).Tone = tone(z);
        nrows = length(audio(z).Spectrum.f);
        
        Session = ones(nrows,1)*f;
        Trial = ones(nrows,1)*trial(z);
        Zone = ones(nrows,1)*zone(z);
        AtZone = ones(nrows,1)*atZone(z);
        AtFeeder = ones(nrows,1)*atFeeder(z);
        Entered = ones(nrows,1)*entered(z);
        Rewarded = ones(nrows,1)*rewarded(z);
        Pellets = ones(nrows,1)*nPellets(z);
        Probability = ones(nrows,1)*probability(z);
        Tone = ones(nrows,1)*tone(z);
        
        Frequency = audio(z).Spectrum.f(:)*monitorDownsample;
        Amplitude = audio(z).Spectrum.a(:);
        PSD = audio(z).Spectrum.psd(:);
        ESD = audio(z).Spectrum.esd(:);
        DATA = [DATA;
            Session Trial Zone Pellets Probability Tone AtZone AtFeeder Entered Rewarded Frequency Amplitude PSD ESD];
    end
end

AudioTab.HEADER = HEADER;
AudioTab.DATA = DATA;
AudioStruct.trials = audio;
AudioStruct.monitorDownsample = monitorDownsample;