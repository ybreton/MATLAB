function [R,fh] = Wrap_RR_vocalization_overall(varargin)

conversion = 1e-6;
window = 0.5;
AudioStart = 'RR.EnteringZoneTime(RR.ZoneIn<10)';
process_varargin(varargin);


fn = FindFiles('csc*.ncs');
Frequencies = [];
SpectralDensity = [];
binWidth = -inf;
Tones = [inf -inf];
for f = 1 : length(fn)
    pathname = fileparts(fn{f});
    pushdir(pathname);
    
    csc = LoadCSC(fn{f});
    RRfn = FindFiles('RR*.mat','CheckSubdirs',0);
    for f0 = 1:length(RRfn)
        RR = load(RRfn{f0});
        startTimes = eval(AudioStart)*conversion;
        stopTimes = eval(AudioStart)*conversion+window;
        [~,Stab] = vocalization_cross_coherence(csc,startTimes,stopTimes);
        SD = Stab.DATA';
        F = can2mat(Stab.HEADER)';
        binWidth = max(binWidth,Stab.binWidth);
        Tones(1) = min(Tones(1),min(RR.FeederTone));
        Tones(2) = max(Tones(2),max(RR.FeederTone));
        if ~isempty(Frequencies)
            if length(Frequencies)<length(F)
                % We've got more frequencies. Add nan to the end of SpectralDensity.
                extra = length(F)-length(Frequencies);
                SpectralDensity(end+1:end+extra,:) = nan;
                Frequencies = F;
            elseif length(F)<length(Frequencies)
                % We've got less frequencies. Add nan to SD.
                extra = length(Frequencies)-length(F);
                SD(end+1:end+extra,:) = nan;
            end
        else
            Frequencies = F;
        end
        SpectralDensity=[SpectralDensity SD];
    end
    
    popdir;
end

parfor r = 1 : length(Frequencies)
    Spec1 = SpectralDensity(r,:);
    Rrow = nan(1,length(Frequencies));
    for c = 1 : length(Frequencies)
        Spec2 = SpectralDensity(c,:);
        S1S2 = corrcoef(Spec1,Spec2);
        Rrow(c) = S1S2(2);
    end
    R(r,:) = Rrow;
end

fh=gcf;
clf
colormap('jet');
hold on
imagesc(Frequencies/1000,Frequencies/1000,R)
plot([0 max(Frequencies+binWidth/2)/1000],[Tones(1) Tones(1)]/1000,'w:')
plot([0 max(Frequencies+binWidth/2)/1000],[Tones(2) Tones(2)]/1000,'w:')
plot([Tones(1) Tones(1)]/1000,[0 max(Frequencies+binWidth/2)/1000],'w:')
plot([Tones(2) Tones(2)]/1000,[0 max(Frequencies+binWidth/2)/1000],'w:')
patch([Tones(1) Tones(1) Tones(2) Tones(2)]/1000,[Tones(1) Tones(2) Tones(2) Tones(1)]/1000,[1 1 1],'facealpha',0.1)
caxis([-1 1])
xlabel('Audio Frequency (kHz)')
ylabel('Audio Frequency (kHz)')
cbh = colorbar;
set(get(cbh,'ylabel'),'string',sprintf('Coherence'))
set(get(cbh,'ylabel'),'rotation',-90)
set(gca,'xlim',[0 max(Frequencies+binWidth/2)/1000])
set(gca,'ylim',[0 max(Frequencies+binWidth/2)/1000])
title(sprintf('From %s to %.2fs later',AudioStart,window))

hold off