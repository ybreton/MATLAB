fn = FindFiles('*-DD.mat');

for f = 1 : length(fn)
    [pn,SSN] = fileparts(fn{f});
    SSN = SSN(1:end-3);
    pushdir(pn)
    
    sd=FPTInit;
    sd2 = SmoothPath(sd);
    sd2 = FPT_fix_times(sd2);
    
    for lap = 1 : length(sd2.EnteringCPTime)
        x = sd2.x.restrict(sd2.EnteringCPTime(lap),sd2.ExitingCPTime(lap));
        y = sd2.y.restrict(sd2.EnteringCPTime(lap),sd2.ExitingCPTime(lap));
        scatterplotc(x.data,y.data,x.range,'solid_face',true)
        sd0 = zIdPhi(sd2,'tstart',sd2.EnteringCPTime(lap),'tend',sd2.ExitingCPTime(lap));
        LogIdPhi = log10(sd0.IdPhi);
        title(sprintf('%s : lap %d\nLog[Id\\Phi]=%.3f',SSN,lap,LogIdPhi))
        set(gca,'xlim',[0 720])
        set(gca,'ylim',[0 480])
        pause;
    end
end