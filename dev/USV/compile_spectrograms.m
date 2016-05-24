
fn = FindFiles('*-usv.mat');
for f = 1 : length(fn)
    [pn,filename]=fileparts(fn{f});
    SSN = filename(1:end-4);
    pushdir(pn);
    load(fn{f});
    clear Spectrogram
    for t = 1 : length(USV);
        [S,ph]=ez_spectrogram(USV(t).Signal.restrict(min(USV(t).Signal.range)+0.1,min(USV(t).Signal.range)+0.6),0.1);
        id = (S.F(:,1)>=10*1000&S.F(:,1)<=70*1000);
        S.D = S.D(id,:);
        S.F = S.F(id,1);
        S.TimeBin = S.TimeBin(id,:);
        S.T = S.T(1,:);
        S.TimeBin = S.TimeBin(1,:);
        Spectrogram(t).FirstHalfSecond = S;
        title(sprintf('Trial %d',t))
        set(gca,'ylim',[10*1000 70*1000])
        drawnow
    end
    save([SSN '-Spectrogram.mat'],'Spectrogram')
    popdir;
end