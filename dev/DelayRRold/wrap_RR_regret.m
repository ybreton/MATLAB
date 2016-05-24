function [outStruc,fh] = wrap_RR_regret(inStruc,varargin)
% Wrapper for regret, disappointment, bad luck, and rejoice instances.
%
%
%

plotFlag = false;
curFigs = get(0,'children');
if isempty(curFigs)
    lastFig = 0;
else
    lastFig = max(curFigs);
end
fh = [lastFig+1:lastFig+4];
process_varargin(varargin);

disp('Identify thresholds for each trial...')
outStruc = RRthreshByTrial(inStruc);
disp('Identify whether rats should stay or go...')
outStruc = RRIdentifyShouldStayGo(outStruc);
disp('Identify regret instances...')
outStruc = RRIdentifyRegret(outStruc);
disp('Identify disappointment instances...')
outStruc = RRIdentifyDisappoint(outStruc);
disp('Identify instances of bad luck...')
outStruc = RRIdentifyBadLuck(outStruc);
disp('Identify rejoice instances...')
outStruc = RRIdentifyRejoice(outStruc);
disp('Calculate handling time...')
outStruc.HandlingTime = RRGetHandlingTime(outStruc.fn);
disp('Calculate stay duration...')
outStruc.StayDuration = [diff(outStruc.EnteringZoneTime,1,2) nan(size(outStruc.EnteringZoneTime,1),1)];
disp('Calculating pStay, zIdPhi, handling time, and stay duration for regret conditions.')
pStay = nan(size(outStruc.staygo,1),4);
RegretZ = nan(size(outStruc.staygo));
DisappointZ = RegretZ;
UnluckyZ = RegretZ;
RejoiceZ = RegretZ;
RegretHT = nan(size(outStruc.staygo));
DisappointHT = RegretHT;
UnluckyHT = RegretHT;
RejoiceHT = RegretHT;

RegretST = nan(size(outStruc.staygo));
DisappointST = RegretST;
UnluckyST = RegretST;
RejoiceST = RegretST;

for iSess = 1 : size(outStruc.staygo,1)
    sg = outStruc.staygo(iSess,:);
    Z  = outStruc.zIdPhi(iSess,:);
    HT = outStruc.HandlingTime(iSess,:);
    ST = outStruc.StayDuration(iSess,:);
    
    idRegret = outStruc.isRegret(iSess,:)==1;
    idDisapp = outStruc.isDisappoint(iSess,:)==1;
    idUnluck = outStruc.isUnlucky(iSess,:)==1;
    idRejoice = outStruc.isRejoice(iSess,:)==1;
    
    pStay(iSess,1) = nanmean(sg(idRegret),2);
    pStay(iSess,2) = nanmean(sg(idDisapp),2);
    pStay(iSess,3) = nanmean(sg(idUnluck),2);
    pStay(iSess,4) = nanmean(sg(idRejoice),2);
    
    RegretZ(iSess,idRegret) = Z(idRegret);
    DisappointZ(iSess,idDisapp) = Z(idDisapp);
    UnluckyZ(iSess,idUnluck) = Z(idUnluck);
    RejoiceZ(iSess,idRejoice) = Z(idRejoice);
    
    RegretHT(iSess,idRegret) = HT(idRegret);
    DisappointHT(iSess,idDisapp) = HT(idDisapp);
    UnluckyHT(iSess,idUnluck) = HT(idUnluck);
    RejoiceHT(iSess,idRejoice) = HT(idRejoice);
    
    RegretST(iSess,idRegret) = ST(idRegret);
    DisappointST(iSess,idDisapp) = ST(idDisapp);
    UnluckyST(iSess,idUnluck) = ST(idUnluck);
    RejoiceST(iSess,idRejoice) = ST(idRejoice);
end
disp('Done.')
outStruc.pStayRegret = pStay(:,1);
outStruc.pStayDisappoint = pStay(:,2);
outStruc.pStayUnlucky = pStay(:,3);
outStruc.pStayRejoice = pStay(:,4);

outStruc.zIdPhiRegret = RegretZ;
outStruc.zIdPhiDisappoint = DisappointZ;
outStruc.zIdPhiUnlucky = UnluckyZ;
outStruc.zIdPhiRejoice = RejoiceZ;

outStruc.HandlingTimeRegret = RegretHT;
outStruc.HandlingTimeDisappoint = DisappointHT;
outStruc.HandlingTimeUnlucky = UnluckyHT;
outStruc.HandlingTimeRejoice = RejoiceHT;

outStruc.StayDurationRegret = RegretST;
outStruc.StayDurationDisappoint = DisappointST;
outStruc.StayDurationUnlucky = UnluckyST;
outStruc.StayDurationRejoice = RejoiceST;

if plotFlag
    disp('Plotting result.')
    legendStr = {sprintf('Regret\n(Skipped low, next high)') 
        sprintf('Disappointment\n(Stayed low, next high)') 
        sprintf('Bad Luck\n(Skipped high, next high)') 
        sprintf('Rejoice\n(Skipped high, next low)')};
    
    figure(fh(1));
    boxplot(pStay);
    xlabel(sprintf('Condition'));
    set(gca,'xtick',1:4);
    set(gca,'xticklabel',{'Regret' 'Disappointment' 'Bad Luck' 'Rejoice'})
    ylabel(sprintf('Probability of stay'))
    set(gca,'ylim',[-0.05 1.05])
    set(gca,'ytick',[0:0.1:1])
    
    figure(fh(2));
    %bin = linspace(floor(min(outStruc.zIdPhi(:))),ceil(max(outStruc.zIdPhi(:))),25);
    bin = linspace(-2,6,25);
    f = hist(RegretZ(:),bin);
    f(2,:) = hist(DisappointZ(:),bin);
    f(3,:) = hist(UnluckyZ(:),bin);
    f(4,:) = hist(RejoiceZ(:),bin);
    p = f./repmat(sum(f,2),1,size(f,2));
    ph=plot(bin(:),p);
    legend(ph,legendStr)
    xlabel(sprintf('zId\\phi'));
    ylabel(sprintf('Proportion of each trial type'))
    set(gca,'ylim',[-0.05 0.55])
    set(gca,'ytick',[0:0.05:0.5])
    
    figure(fh(3));
    %bin = linspace(floor(min(outStruc.HandlingTime(:))),ceil(max(outStruc.HandlingTime(:))),25);
    bin = linspace(0,60,25);
    f = hist(RegretHT(:),bin);
    f(2,:) = hist(DisappointHT(:),bin);
    f(3,:) = hist(UnluckyHT(:),bin);
    f(4,:) = hist(RejoiceHT(:),bin);
    p = f./repmat(sum(f,2),1,size(f,2));
    ph=plot(bin(:),p);
    legend(ph,legendStr)
    xlabel(sprintf('Post-feeder stay duration\n(secs)'));
    ylabel(sprintf('Proportion of each trial type'))
    set(gca,'ylim',[-0.05 1.05])
    set(gca,'ytick',[0:0.1:1])
    
    figure(fh(4));
    %bin = linspace(floor(min(outStruc.HandlingTime(:))),ceil(max(outStruc.HandlingTime(:))),25);
    bin = linspace(0,60,25);
    f = hist(RegretST(:),bin);
    f(2,:) = hist(DisappointST(:),bin);
    f(3,:) = hist(UnluckyST(:),bin);
    f(4,:) = hist(RejoiceST(:),bin);
    p = f./repmat(sum(f,2),1,size(f,2));
    ph=plot(bin(:),p);
    legend(ph,legendStr)
    xlabel(sprintf('Total zone stay duration\n(secs)'));
    ylabel(sprintf('Proportion of each trial type'))
    set(gca,'ylim',[-0.05 1.05])
    set(gca,'ytick',[0:0.1:1])
end

%%