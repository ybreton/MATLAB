function fh = plot_herrn_mtn_ta(rpt_mtn_fit)

Params = rpt_mtn_fit.Mtn_primary_fit.DATA(:);
% CBlo = rpt_mtn_fit.Mtn_median_fit.DATA(:,2);
% CBhi = rpt_mtn_fit.Mtn_median_fit.DATA(:,3);
Flvr = Params(6:end);
k = Params(2);

PerfData = rpt_mtn_fit.Mtn_means.DATA;
Obs.LogN = PerfData(:,1);
Obs.LogP = PerfData(:,2);
Obs.Prob = PerfData(:,3);
Obs.Zone = PerfData(:,4);
uniqueZones = unique(Obs.Zone);
Obs.TA = PerfData(:,5);
Obs.CBlo = PerfData(:,6);
Obs.CBhi = PerfData(:,7);

markerlist = {'o' 's' '^' 'x' 'd' 'v' '+' '*' '>' 'h' 'p' '<'};
markerlist = markerlist(1:length(uniqueZones));

Obs.Rate = Obs.Prob./(1+k*(10.^Obs.LogP));
delta = zeros(length(Obs.Zone),1);
for choice = 1 : length(Obs.Zone)
    delta(choice) = 10.^(Flvr(Obs.Zone(choice)));
end
Obs.NormalizedN = (10.^Obs.LogN).*delta;

fh=gcf;
clf
subplot(2,2,3)
hold on
axis xy
minP = min(-1,min(Obs.LogP));
maxP = max(2,max(Obs.LogP));
minN = min(-1,log10(min(Obs.NormalizedN)));
maxN = max(2,log10(max(Obs.NormalizedN)));
logP = linspace(minP,maxP,750);
logN = linspace(minN,maxN,750);

[meshP,meshN] = meshgrid(logP,logN);
Pr = ones(size(meshP));
Z = ones(size(meshN));
TA = ez_herrn_mtn_ta([meshN(:) meshP(:) Pr(:) Z(:)],Params);
TA = reshape(TA,size(meshP));
sh=surf(log10(1./(Pr./(1+k*10.^meshP))),meshN,TA);
xlabel(sprintf('Log_{10}[Costs]\n(Sec/Rew)'))
ylabel(sprintf('Log_{10}[Number of Pellets],\n normalized to zone 1'))
zlabel('Proportion chosen')

for iX = 1 : length(Obs.NormalizedN)
    X = log10(1./(Obs.Rate(iX)));
    Y = log10(Obs.NormalizedN(iX));
    plot3([X X],[Y Y],[Obs.CBlo(iX) Obs.CBhi(iX)],'k-')
end
for iZ = 1 : length(uniqueZones)
    idZ = Obs.Zone == uniqueZones(iZ);
    plot3(log10(1./(Obs.Rate(idZ))),log10(Obs.NormalizedN(idZ)),Obs.TA(idZ),markerlist{iZ},'markerfacecolor','k','markeredgecolor','k')
end

set(sh,'facealpha',0.4)
set(sh,'edgecolor','none')
view(45,30)
hold off

subplot(2,2,4)
hold on
minP = min(-1,min(Obs.LogP));
maxP = max(2,max(Obs.LogP));
minN = min(-1,log10(min(Obs.NormalizedN)));
maxN = max(2,log10(max(Obs.NormalizedN)));
logP = linspace(minP,maxP,750);
logN = linspace(minN,maxN,750);

[meshP,meshN] = meshgrid(logP,logN);
Pr = ones(size(meshP));
Z = ones(size(meshN));
TA = ez_herrn_mtn_ta([meshN(:) meshP(:) Pr(:) Z(:)],Params);
TA = reshape(TA,size(meshP));
contour(log10(1./(Pr./(1+k*10.^meshP))),meshN,TA,[0:0.1:1]);
for iZ = 1 : length(uniqueZones)
    idZ = Obs.Zone == uniqueZones(iZ);
    plot(log10(1./Obs.Rate(idZ)),log10(Obs.NormalizedN(idZ)),markerlist{iZ},'markerfacecolor','k','markeredgecolor','k')
end

xlabel(sprintf('Log_{10}[Costs]\n(Sec/Rew)'))
ylabel(sprintf('Log_{10}[Number of Pellets],\n normalized to zone 1'))
axis xy
cbh=colorbar;
Rsq = rpt_mtn_fit.Rsq;
text(min(get(gca,'xlim')),max(get(gca,'ylim')),sprintf('R^2=%.4f',Rsq));
hold off

uniqueZones = unique(Obs.Zone);
for iZ = 1 : length(uniqueZones)
    idZone = Obs.Zone == uniqueZones(iZ);
    feederPellets = 10.^Obs.LogN(idZone);
    feederDelay = 10.^(Obs.LogP(idZone));
    feederProb = Obs.Prob(idZone);
    feederChoice = Obs.TA(idZone);
    feederCIs = [Obs.CBlo(idZone) Obs.CBhi(idZone)];
    
    predZone = ones(500,1)*uniqueZones(iZ);
    
    if length(unique(feederProb))==1 & length(unique(feederDelay))>1
        % Delay sweep
        xStr = sprintf('Log_{10}[Delay]');
        X = feederDelay;
        Llist = [feederPellets(:) feederProb(:)];
        L = unique([feederPellets(:) feederProb(:)],'rows');
        legendStr = cell(size(L,1),1);
        for iLvl = 1 : size(L,1)
            str = sprintf('%.0f Pellets\n %.2f Probability',L(iLvl,1),L(iLvl,2));
            legendStr{iLvl} = str;
        end
        location = 'northwest';
        xlo = -0.05;
        xhi = 2.05;
        predXcol = 2;
    elseif length(unique(feederProb))>1
        % Probability sweep
        xStr = sprintf('Probability');
        X = (feederProb);
        Llist = [feederPellets(:) feederDelay(:)];
        L = unique([feederPellets(:) feederDelay(:)],'rows');
        legendStr = cell(size(L,1),1);
        for iLvl = 1 : size(L,1)
            str = sprintf('%.0f Pellets\n %.2fs Delay',L(iLvl,1),L(iLvl,2));
            legendStr{iLvl} = str;
        end
        location = 'southeast';
        xlo = -0.05;
        xhi = 1.05;
        predXcol = 3;
    else 
        xStr = sprintf('Log_{10}[Pellets]');
        X = (feederPellets);
        Llist = [feederProb(:) feederDelay(:)];
        L = unique([feederProb(:) feederDelay(:)],'rows');
        legendStr = cell(size(L,1),1);
        for iLvl = 1 : size(L,1)
            str = sprintf('%.2f Prob\n %.2fs Delay',L(iLvl,1),L(iLvl,2));
            legendStr{iLvl} = str;
        end
        location = 'southeast';
        xlo = -0.05;
        xhi = 30.05;
        predXcol = 1;
    end
    
    cmap = lines(size(L,1));
    ph = nan(size(L,1),1);
    subplot(2,length(uniqueZones),iZ)
    hold on
    for iL = 1 : size(L,1)
        comparison = repmat(L(iL,:),length(Llist),1);
        idL = all(comparison==Llist,2);
        x = X(idL);
        y = feederChoice(idL);
        l = feederCIs(idL,1);
        u = feederCIs(idL,2);
        eh=errorbar(x,y,y-l,u-y);
        set(eh,'linestyle','none')
        set(eh,'color',cmap(iL,:))
        ph(iL) = plot(x,y,markerlist{iZ},'markerfacecolor',cmap(iL,:),'markeredgecolor',cmap(iL,:));
        
        predLogN = linspace(log10(min(feederPellets(idL))),log10(max(feederPellets(idL))),500);
        predLogP = linspace(log10(min(feederDelay(idL))),log10(max(feederDelay(idL))),500);
        predPr   = linspace(min(feederProb(idL)),max(feederProb(idL)),500);
        predZone = ones(length(predLogN),1)*uniqueZones(iZ);
        
        preds = [predLogN(:) predLogP(:) predPr(:) predZone(:)];
        predX = preds(:,predXcol);
        predTA = ez_herrn_mtn_ta(preds,Params);
        
        plot(predX,predTA,'-','color',cmap(iL,:))
    end
    set(gca,'xlim',[xlo xhi])
    set(gca,'ylim',[-0.05 1.05])
    xlabel(xStr);
    if iZ == 1
        ylabel(sprintf('Proportion chosen'));
    end
    if size(L,1)>1
        lh=legend(ph,legendStr);
        set(lh,'location',location)
        set(lh,'fontsize',8)
        title(sprintf('Zone %d',uniqueZones(iZ)))
    else
        titleStr = [sprintf('Zone %d\n',uniqueZones(iZ)) legendStr{1}];
        title(titleStr)
    end
    hold off
end