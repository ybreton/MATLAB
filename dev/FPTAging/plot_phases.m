function [fh,longestAlternation,primaryAlternation] = plot_phases(sd)
%
%
%
%

phase = DD_getPhaseSW(sd,'nL',sd.TotalLaps);
choseD = sd.ZoneIn == sd.DelayZone;
[~,Dadj] = DD_getDelays(sd,'nL',sd.TotalLaps);
laps = 1:sd.TotalLaps;

idExplore = phase==1;
idTitrate = phase==2;
idExploit = phase==3;

cp = diff(phase)~=0;
cp = [cp; true];
cp = laps(cp);
cp = [0 cp];

clf
plot(laps,Dadj,'k.')
longestAlternation = 0;
primaryAlternation = [];
hold on
for p = 2 : length(cp)
    if phase(cp(p))==1
        b = glmfit((cp(p-1)+1:cp(p))',Dadj(cp(p-1)+1:cp(p)),'normal');
        d = glmval(b,cp(p-1)+1:cp(p),'identity');
        plot(cp(p-1)+1:cp(p),d,'b-','linewidth',3)
    end
    if phase(cp(p))==2
        b = glmfit((cp(p-1)+1:cp(p))',Dadj(cp(p-1)+1:cp(p)),'normal');
        d = glmval(b,cp(p-1)+1:cp(p),'identity');
        plot(cp(p-1)+1:cp(p),d,'r-','linewidth',3)
    end
    if phase(cp(p))==3
        D = Dadj(cp(p-1)+1:cp(p));
        C = choseD(cp(p-1)+1:cp(p));
        d = nanmean(D(C));
        plot([cp(p-1)+1 cp(p)],[d d],'c-','linewidth',3)
        if length(d)>longestAlternation
            longestAlternation = length(D);
            primaryAlternation = [cp(p-1)+1 cp(p)];
        end
    end
end
hold off
xlabel('Lap number')
ylabel('Delay on delayed side (sec)')
title(sprintf('Explore-titrate-exploit\n(%s)',sd.ExpKeys.SSN));
drawnow
fh = gcf;