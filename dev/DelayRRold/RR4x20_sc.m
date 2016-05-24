clear;

sdfn = FindFiles('*-sd.mat');
delays = RRGetDelays(sdfn); 
staygo = RRGetStaygo(sdfn); 
drugs = RRGetDrugs(sdfn);
idCNO = strcmpi('Drug',drugs)|strcmpi('CNO',drugs);
[IdPhi,Zidphi] = RRGetIdPhi(sdfn,'VTEtime',5); 
zones = RRGetZones(sdfn);
pellets = RRGetPellets(sdfn);

handlingTime = RRGetHandlingTime(sdfn);

cmapIn = RRColorMap;
cmapOut = cmapIn;
cmapOut(3,:) = [0 0 0];

%% thresholds
uniqueNs = unique(pellets(~isnan(pellets)));
thresholds = nan(size(staygo,1),4,length(uniqueNs));
overall = thresholds;
overallZone = nan(size(staygo,1),4,length(uniqueNs));
overallPels = nan(size(staygo,1),4,length(uniqueNs));
pelletMat = nan(size(staygo,1),4,length(uniqueNs));
pOut = nan(size(staygo,1),4,length(uniqueNs));
for iSess = 1 : size(staygo,1)
    for iZone = 1 : 4
        idZone = zones(iSess,:)==iZone;
        for iPellets = 1 : length(uniqueNs);
            nPellets = uniqueNs(iPellets);
            idPel = pellets(iSess,:)==nPellets;
            pelletMat(iSess,iZone,iPellets) =nPellets;
            
            [th,in,out] = RRheaviside(delays(iSess,idZone&idPel)',staygo(iSess,idZone&idPel)');
            
            thresholds(iSess,iZone,iPellets) = th;
            pOut(iSess,iZone,iPellets) = binofit(out,out+in);
        end
        [th,in,out] = RRheaviside(delays(iSess,idZone)',staygo(iSess,idZone)');
        overallZone(iSess,iZone,:) = th;
    end
    for iPellets = 1 : length(uniqueNs)
        [th,in,out] = RRheaviside(delays(iSess,idPel)',staygo(iSess,idPel)');
        overallPels(iSess,:,iPellets) = th;
    end
    [th,in,out] = RRheaviside(delays(iSess,:)',staygo(iSess,:)');
    overall(iSess,:,:) = th;
end

%%

% deviation of thresholds from overall for this number of pellets
deltaFlavr = thresholds - overallPels;
% deviation of thresholds from overall for this zone
deltaValue = thresholds - overallZone;
% deviation of thresholds from overall this session
delta = thresholds - overall;

RMSDflavr = nan(size(deltaFlavr,1),1);
RMSDvalue = nan(size(deltaValue,1),1);
for iSess = 1 : size(deltaFlavr,1)
    sessFlvr = reshape(deltaFlavr(iSess,:,:),[1 numel(deltaFlavr(iSess,:,:))]);
    RMSDflavr(iSess) = sqrt((sessFlvr*sessFlvr')/numel(sessFlvr));
    sessValu = reshape(deltaValue(iSess,:,:),[1 numel(deltaValue(iSess,:,:))]);
    RMSDvalue(iSess) = sqrt((sessValu*sessValu')/numel(sessValu));
    sess = reshape(delta(iSess,:,:),[1 numel(delta(iSess,:,:))]);
    RMSDoverall(iSess) = sqrt(sess*sess'/numel(sess));
end

mRMSD = nan(3,2);
sRMSD = nan(3,2);

mRMSD(1,1) = nanmean(RMSDflavr(idCNO));
mRMSD(1,2) = nanmean(RMSDflavr(~idCNO));
sRMSD(1,1) = nanstderr(RMSDflavr(idCNO));
sRMSD(1,2) = nanstderr(RMSDflavr(~idCNO));
mRMSD(2,1) = nanmean(RMSDvalue(idCNO));
mRMSD(2,2) = nanmean(RMSDvalue(~idCNO));
sRMSD(2,1) = nanstderr(RMSDvalue(idCNO));
sRMSD(2,2) = nanstderr(RMSDvalue(~idCNO));
mRMSD(3,1) = nanmean(RMSDoverall(idCNO));
mRMSD(3,2) = nanmean(RMSDoverall(~idCNO));
sRMSD(3,1) = nanstderr(RMSDoverall(idCNO));
sRMSD(3,2) = nanstderr(RMSDoverall(~idCNO));


figure(1)
bh=bar(mRMSD);
hold on
childs=get(bh(1),'children');
xpos = nanmean(get(childs,'xdata'));
eh=errorbar(xpos,mRMSD(:,1),sRMSD(:,1));
set(eh,'linestyle','none')
set(eh,'color','k')
childs=get(bh(2),'children');
xpos = nanmean(get(childs,'xdata'));
eh=errorbar(xpos,mRMSD(:,2),sRMSD(:,2));
set(eh,'linestyle','none')
set(eh,'color','k')
legend([get(bh(1),'children') get(bh(2),'children')],{'CNO' 'Vehicle'})
set(gca,'xtick',1:3)
set(gca,'xticklabel',{'Flavour-based' 'Amount-based' 'Overall'})
ylabel(sprintf('Root-mean squared deviation of threshold from overall\n(mean \\pm SEM)'))
hold off

saveas(gcf,'RMSD_ThresholdToOverall_vs_FlvrValuAny_at_Drug.fig','fig')
saveas(gcf,'RMSD_ThresholdToOverall_vs_FlvrValuAny_at_Drug.eps','epsc')