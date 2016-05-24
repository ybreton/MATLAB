function [delays,pelletRatios,idealTitration,finalDelays,startDelays,OIE,TitrationAlternation,LogIdPhi,SD,choseLL,lapsRun] = FPTextractSDFN(sdfn,varargin)

nLaps = 205;
VTEtime = 2;
process_varargin(varargin);

delays = nan(size(sdfn,1),size(sdfn,2),nLaps);
idealTitration = nan(size(sdfn,1),size(sdfn,2),nLaps);
TitrationAlternation = nan(size(sdfn,1),size(sdfn,2),nLaps);
finalDelays = nan(size(sdfn,1),size(sdfn,2));
startDelays = nan(size(sdfn,1),size(sdfn,2));
pelletRatios = nan(size(sdfn,1),size(sdfn,2));
OIE = nan(size(sdfn,1),size(sdfn,2));
LogIdPhi = nan(size(sdfn,1),size(sdfn,2),nLaps);
choseLL = nan(size(sdfn,1),size(sdfn,2),nLaps);
lapsRun = nan(size(sdfn,1),size(sdfn,2),nLaps);
fh=figure;
for r = 1 : size(sdfn,1)
    for c = 1 : size(sdfn,2)
        if ~isempty(sdfn{r,c})
            fd = fileparts(sdfn{r,c});
            pushdir(fd);
            delim = regexpi(fd,'\');
            SSN = fd(max(delim)+1:end);
            disp(fd);
            
            load(sdfn{r,c});
            sd.SSN = SSN;
            
            [DD,LL] = DD_getDelays(sd,'nL',sd.TotalLaps);
            sd.DelayLL = LL;
            laps = 1:length(LL);
            Last20 = LL(laps>sd.TotalLaps-20);
            finalDelay = mean(Last20);
            sd.finalDelay = finalDelay;
            startDelay = LL(1);
            sd.startDelay = startDelay;

            sd.pelletRatio = 10^(abs(log10(sd.World.nPleft/sd.World.nPright)));

            TA = DD_getLapType(sd,'nL',sd.TotalLaps);
            Phase = nan(1,sd.TotalLaps);
            
            sd.TA = TA;
            
            save(sdfn{r,c},'sd');
            if any(sd.ZoneIn==sd.DelayZone)
%                 [ID,TI,nInvest,firstAltern] = DD_idealTitration(sd);
%                 sd.idealTitration = ID;
                [Inv0,Inv,Tit,Expl] = FPT_getPhases(sd);
                delays(r,c,1:length(sd.DelayLL)) = reshape(sd.DelayLL, 1, 1, length(sd.DelayLL));
%                 idealTitration(r,c,1:length(ID)) = reshape(sd.idealTitration, 1, 1, length(sd.idealTitration));
                choseLL(r,c,1:length(sd.ZoneIn)) = reshape(sd.ZoneIn==sd.DelayZone, 1, 1, length(sd.ZoneIn));
                finalDelays(r,c) = finalDelay;
                startDelays(r,c) = startDelay;
%                 OverallInefficiency = sqrt(nanmean((LL-ID).^2));
                
%                 OIE(r,c) = OverallInefficiency;
%                 Phase(1:nInvest) = 1;
%                 Phase(nInvest+1:firstAltern-1) = 2;
%                 Phase(firstAltern:end) = 3;
            end
            TitrationAlternation(r,c,1:length(sd.TA)) = reshape(sd.TA, 1, 1, length(sd.TA));
            pelletRatios(r,c) = sd.pelletRatio;
            LogIdPhi(r,c,1:length(sd.IdPhi)) = reshape(log10(sd.IdPhi), 1, 1, length(sd.IdPhi));
            lapsRun(r,c,1:length(sd.ZoneIn)) = reshape(1:length(sd.ZoneIn), 1, 1, length(sd.ZoneIn));
            sd.Phase = Phase;
            SD(r,c) = sd;

            set(0,'currentfigure',fh);
            clf
            hold on
            title(sprintf('%s',sd.SSN))
            FPTplotPaths(sd,'tstart',sd.EnteringCPTime_fix,'tend',sd.ExitingCPTime_fix);
            hold off

            saveas(gcf,sprintf('%s-CP_passes.fig',sd.SSN),'fig')
            saveas(gcf,sprintf('%s-CP_passes.eps',sd.SSN),'epsc')
            popdir;
        end
    end
end
close(fh);

save('delays.mat','delays')
save('pelletRatios.mat','pelletRatios')
% save('idealTitration.mat','idealTitration')
save('finalDelays.mat','finalDelays')
save('startDelays.mat','startDelays')
% save('OIE.mat','OIE');
save('TitrationAlternation.mat','TitrationAlternation');
save('LogIdPhi.mat','LogIdPhi');
save('AllRatsSDs.mat','SD');
save('choseLL.mat','choseLL');
save('lapsRun.mat','lapsRun');