fn = FindFiles('*-sd-zIdPhi.mat');

DATA = [];
for f = 1 : length(fn)
    filename = fn{f};
    pathname = fileparts(filename);
    pushdir(pathname);
    load(filename);
    sd = sd2;
    
    ZoneDelay = sd.ZoneDelay;
    ZoneIn = sd.ZoneIn;
    DelayZone = sd.DelayZone;
    nP3 = sd.World.nPleft;
    nP4 = sd.World.nPright;
    
    Laps = 1:length(ZoneIn);
    
    nPellets = ones(length(ZoneIn),1)*(max(nP3,nP4)/min(nP3,nP4));
    
    InDelay = ZoneIn==DelayZone;
    Delay = nan(length(Laps),1);
    Include = false(length(Laps),1);
    if ~isempty(Laps(InDelay==1));
        firstDelayLap = min(Laps(InDelay==1));
        Delay(firstDelayLap) = ZoneDelay(firstDelayLap);
        Delay(1:firstDelayLap-1) = nan;
        for z = firstDelayLap : length(Laps)
            if ZoneIn(z)~=DelayZone
                Delay(z+1) = max(1,Delay(z)-1);
            end
            if ZoneIn(z)==DelayZone
                Delay(z+1) = max(1,Delay(z)+1);
            end
            if z>firstDelayLap
                Include(z) = true;
            end
        end
    end
    maxLaps = ones(length(Laps),1)*max(Laps);
    DATA = [DATA;
        ones(length(Laps),1)*f Laps(:) nPellets(:) Delay(1:length(Laps)) InDelay(:) maxLaps(:) Include(:)];
    
    popdir;
end
if isempty(DATA)
    disp('Empty data file.')
end
InNonDelay = DATA(:,5)==0;
SSN = DATA(:,1);
Laps = DATA(:,2);
nPellets = DATA(:,3);
Delays = DATA(:,4);
Choices = DATA(:,5);
maxLaps = DATA(:,6);
idInc = DATA(:,7)==1;

fh=figure;
[params] = fit_DD_logit(SSN(idInc),Laps(idInc),nPellets(idInc),Delays(idInc),Choices(idInc));
params.Table.DATA(:,6) = maxLaps(idInc);
params.Table.HEADER{6} = 'Max Laps on SSN';
saveas(fh,'LogitDD_fit.fig','fig')
saveas(fh,'LogitDD_fit.eps','epsc')
save('DD_policy.mat','params')
% [params,LnL] = fit_DD_mountain(Laps(idInc),nPellets(idInc),Delays(idInc),Choices(idInc),A0,D0);
% saveas(fh,'MountainDD_fit.fig','fig')
% saveas(fh,'MountainDD_fit.eps','eps')