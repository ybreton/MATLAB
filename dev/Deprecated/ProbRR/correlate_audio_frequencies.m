function correlate_audio_frequencies(audio,varargin)

process_varargin(varargin);

L = 0;
Fs = inf;
LB = inf;
UB = -inf;
for k = 1 : length(audio)
    Fs = min(audio(k).Fs,Fs);
    LB = min(LB,min(audio(k).Spectrum.f));
    UB = max(UB,max(audio(k).Spectrum.f));
end

B = [0 linspace(LB,UB,100) 1/(2*Fs)];
B = unique(B);
Z = nan(length(B)-1);
Zfail = nan(length(B)-1);
Zskip = nan(length(B)-1);
Zsucc = nan(length(B)-1);
for c = 1 : length(B)-1
    for r = 1 : c
        Ar = nan(length(audio),1);
        Ac = nan(length(audio),1);
        As1 = nan(length(audio),1);
        As2 = nan(length(audio),1);
        Af1 = nan(length(audio),1);
        Af2 = nan(length(audio),1);
        An1 = nan(length(audio),1);
        An2 = nan(length(audio),1);
        m = 1;
        for k = 1 : length(audio)
            F = audio(k).Spectrum.f;
            idR = F>B(r)&F<=B(r+1);
            idC = F>B(c)&F<=B(c+1);
            Ar(k) = mean(audio(k).Spectrum.a(idR));
            Ac(k) = mean(audio(k).Spectrum.a(idC));
            if audio(k).Entered & audio(k).Rewarded
                As1(k) = mean(audio(k).Spectrum.a(idR));
                As2(k) = mean(audio(k).Spectrum.a(idC));
            end
            if audio(k).Entered & ~audio(k).Rewarded
                Af1(k) = mean(audio(k).Spectrum.a(idR));
                Af2(k) = mean(audio(k).Spectrum.a(idC));
            end
            if audio(k).Skipped
                An1(k) = mean(audio(k).Spectrum.a(idR));
                An2(k) = mean(audio(k).Spectrum.a(idC));
            end
        end
        correlmat = corrcoef(Ar,Ac);
        correlSuccess = corrcoef(As1,As2);
        correlFail = corrcoef(Af1,Af2);
        correlSkip = corrcoef(An1,An2);
        
        Z(r,c) = correlmat(2);
        Zskip(r,c) = correlSkip(2);
        Zsucc(r,c) = correlSuccess(2);
        Zfail(r,c) = correlFail(2);
        Z(c,r) = correlmat(2);
        Zskip(c,r) = correlSkip(2);
        Zsucc(c,r) = correlSuccess(2);
        Zfail(c,r) = correlFail(2);
    end
end
subplot(2,2,1)
title('All zone entries')
cla
hold on
imagesc(Z)
set(gca,'xlim',[1 size(Z,2)])
set(gca,'ylim',[1 size(Z,1)])
set(gca,'xtick',[1:10:size(Z,2)])
set(gca,'ytick',[1:10:size(Z,2)])
set(gca,'xticklabel',B(1:10:end-1))
set(gca,'yticklabel',B(1:10:end-1))
xlabel('Audio frequency')
ylabel('Audio frequency')
ch=colorbar;
set(get(ch,'ylabel'),'string','Correlation')
hold off

subplot(2,2,2)
title('Skip')
cla
hold on
imagesc(Zskip)
set(gca,'xlim',[1 size(Z,2)])
set(gca,'ylim',[1 size(Z,1)])
set(gca,'xtick',[1:10:size(Z,2)])
set(gca,'ytick',[1:10:size(Z,2)])
set(gca,'xticklabel',B(1:10:end-1))
set(gca,'yticklabel',B(1:10:end-1))
xlabel('Audio frequency')
ylabel('Audio frequency')
ch=colorbar;
set(get(ch,'ylabel'),'string','Correlation')
hold off

subplot(2,2,3)
title('Unrewarded entry')
cla
hold on
imagesc(Zfail)
set(gca,'xlim',[1 size(Z,2)])
set(gca,'ylim',[1 size(Z,1)])
set(gca,'xtick',[1:10:size(Z,2)])
set(gca,'ytick',[1:10:size(Z,2)])
set(gca,'xticklabel',B(1:10:end-1))
set(gca,'yticklabel',B(1:10:end-1))
xlabel('Audio frequency')
ylabel('Audio frequency')
ch=colorbar;
set(get(ch,'ylabel'),'string','Correlation')
hold off

subplot(2,2,4)
title('Rewarded entry')
cla
hold on
imagesc(Zsucc)
set(gca,'xlim',[1 size(Z,2)])
set(gca,'ylim',[1 size(Z,1)])
set(gca,'xtick',[1:10:size(Z,2)])
set(gca,'ytick',[1:10:size(Z,2)])
set(gca,'xticklabel',B(1:10:end-1))
set(gca,'yticklabel',B(1:10:end-1))
xlabel('Audio frequency')
ylabel('Audio frequency')
ch=colorbar;
set(get(ch,'ylabel'),'string','Correlation')
hold off