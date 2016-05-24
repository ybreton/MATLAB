%%
% Running HC_SpatialDecoding_sc first will produce all the structures
% necessary.
%%
fd = RRgetSSNfds;
sdList = RRcollectSDs(fd);

%%
nBins = 64;
nTrls = nan(length(fd),1);
for iD = 1 : length(sdList)
    nTrls(iD) = sdList{iD}.nTrials;
end
maxTrls = max(nTrls);

%%
Condition = cell(length(fd),1);

pShouldSkip = nan(length(fd),2,maxTrls,nBins,nBins);
pShouldStay = nan(length(fd),2,maxTrls,nBins,nBins);
pAtThresh = nan(length(fd),2,maxTrls,nBins,nBins);
pAll = nan(length(fd),2,maxTrls,nBins,nBins);

xEntry = nan(length(fd),maxTrls);
yEntry = nan(length(fd),maxTrls);
xFeeder = nan(length(fd),maxTrls);
yFeeder = nan(length(fd),maxTrls);
xExit = xEntry;
yExit = yEntry;
xPrev = xEntry;
yPrev = yEntry;
idSkip = nan(length(fd),maxTrls);
idStay = idSkip;

nTrls = -inf;
nP=ceil(sqrt(length(sdList))+1);
nCells = nan(length(sdList));
for iD = 1 : length(sdList)
    pushdir(fd{iD});
    disp(fd{iD});
    
    % Use SD information.
    sd = sdList{iD};
    Condition{iD} = sd(1).ExpKeys.Condition;
    ShouldStay = RRIdentifyShouldStay(sd);
    ShouldSkip = RRIdentifyShouldSkip(sd);
    nTrls = length(sd.ZoneIn);
    Tstay = sd.EnteringZoneTime(ShouldStay(1:nTrls)==1);
    Tskip = sd.EnteringZoneTime(ShouldSkip(1:nTrls)==1);
    Tthresh = sd.EnteringZoneTime(ShouldSkip(1:nTrls)==0&ShouldStay(1:nTrls)==0);
    Tall = sd.EnteringZoneTime;
    idSkip(iD,1:length(ShouldSkip)) = ShouldSkip;
    idStay(iD,1:length(ShouldStay)) = ShouldStay;
    
    % Get landmarks.
    landmarks(iD) = RRalignedLandmarks(sd);
    xEntry(iD,1:length(landmarks(iD).ZoneEntry.x.data)) = landmarks(iD).ZoneEntry.x.data;
    yEntry(iD,1:length(landmarks(iD).ZoneEntry.y.data)) = landmarks(iD).ZoneEntry.y.data;
    xFeeder(iD,1:length(landmarks(iD).Feeder.x.data)) = landmarks(iD).Feeder.x.data;
    yFeeder(iD,1:length(landmarks(iD).Feeder.y.data)) = landmarks(iD).Feeder.y.data;
    xExit(iD,1:length(landmarks(iD).ZoneExit.x.data)) = landmarks(iD).ZoneExit.x.data;
    yExit(iD,1:length(landmarks(iD).ZoneExit.y.data)) = landmarks(iD).ZoneExit.y.data;
    xPrev(iD,1:length(landmarks(iD).PrevZone.x.data)) = landmarks(iD).PrevZone.x.data;
    yPrev(iD,1:length(landmarks(iD).PrevZone.y.data)) = landmarks(iD).PrevZone.y.data;
    
    % Get decoding.
    disp('Loading decoding...')
    Bfn = FindFiles('*-DecodeXY.mat','CheckSubdirs',0);
    t1 = clock;
    Decoding = load(Bfn{1});
    t2 = clock;
    disp([num2str(etime(t2,t1)) 's to load.'])
    rotPxs = Decoding.B.rotPxs;
    nCells(iD) = Decoding.nCells;
    
    pShouldSkip(iD,1,1:length(Tskip),:,:) = rotPxs.data(Tskip);
    pShouldSkip(iD,2,1:length(Tskip),:,:) = rotPxs.data(Tskip+0.125);
    
    pShouldStay(iD,1,1:length(Tstay),:,:) = rotPxs.data(Tstay);
    pShouldStay(iD,2,1:length(Tstay),:,:) = rotPxs.data(Tstay+0.125);
    
    pAtThresh(iD,1,1:length(Tthresh),:,:) = rotPxs.data(Tthresh);
    pAtThresh(iD,2,1:length(Tthresh),:,:) = rotPxs.data(Tthresh+0.125);
    
    pAll(iD,1,1:length(Tall),:,:) = rotPxs.data(Tall);
    pAll(iD,2,1:length(Tall),:,:) = rotPxs.data(Tall+0.125);
    
    nTrls = max(nTrls,length(Tall));
    
    subplot(nP,nP,iD)
    I1 = squeeze(nanmean(pAll(iD,1,1:length(Tall),:,:),3));
    imagesc(linspace(-250,250,nBins),linspace(-250,250,nBins),I1')
    clear I1
    hold on
    plot(nanmedian(xEntry(iD,:),2),nanmedian(yEntry(iD,:),2),'wo','markersize',4)
    plot(nanmedian(xFeeder(iD,:),2),nanmedian(yFeeder(iD,:),2),'wx','markersize',4)
    plot(nanmedian(xPrev(iD,:),2),nanmedian(yPrev(iD,:),2),'w>','markersize',4)
    plot(nanmedian(xExit(iD,:),2),nanmedian(yExit(iD,:),2),'w<','markersize',4)
    axis xy
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    set(gca,'xcolor','w')
    set(gca,'ycolor','w')
    title(sprintf('All entries (%d cells)',nCells(iD)))
    hold off
    
    drawnow
    popdir;
end
subplot(nP,nP,nP.^2)
pos=get(gca,'position');
pos(3) = pos(3)/4;
pos(1) = pos(1)+3*pos(3);
cbh=colorbar;
set(cbh,'position',pos)
set(get(cbh,'xlabel'),'string',sprintf('Mean decoded position'));
set(gca,'visible','off')
%%
idVeh = strncmpi('Veh',Condition,3)|strncmpi('Sal',Condition,3);
idCNO = strncmpi('Dru',Condition,3)|strncmpi('CNO',Condition,3);
idInc = nCells>=10;

idVeh = idVeh&idInc;
idCNO = idCNO&idInc;
%%
mShouldSkip = nan(nBins,nBins,2);
mShouldSkip(:,:,1) = squeeze(nanmean(nanmean(pShouldSkip(idVeh,1,:,:,:),3),1));
mShouldSkip(:,:,2) = squeeze(nanmean(nanmean(pShouldSkip(idCNO,1,:,:,:),3),1));
mShouldStay = nan(nBins,nBins,2);
mShouldStay(:,:,1) = squeeze(nanmean(nanmean(pShouldStay(idVeh,1,:,:,:),3),1));
mShouldStay(:,:,2) = squeeze(nanmean(nanmean(pShouldStay(idCNO,1,:,:,:),3),1));
%%
mAll = nan(nBins,nBins,2);
mAll(:,:,1) = squeeze(nanmean(nanmean(pAll(idVeh,1,:,:,:),3),1));
mAll(:,:,2) = squeeze(nanmean(nanmean(pAll(idCNO,1,:,:,:),3),1));
%%
figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(mShouldSkip(:,:,1))')
hold on
plot(nanmean(nanmean(xEntry(idVeh,:),2),1),nanmean(nanmean(yEntry(idVeh,:),2),1),'wo')
plot(nanmean(nanmean(xFeeder(idVeh,:),2),1),nanmean(nanmean(yFeeder(idVeh,:),2),1),'wx')
plot(nanmean(nanmean(xPrev(idVeh,:),2),1),nanmean(nanmean(yPrev(idVeh,:),2),1),'w>')
plot(nanmean(nanmean(xExit(idVeh,:),2),1),nanmean(nanmean(yExit(idVeh,:),2),1),'w<')
axis xy
hold off
caxis([0 0.025])
title('Mean decoding, Above threshold (Saline)')

figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(mShouldSkip(:,:,2))')
hold on
plot(nanmean(nanmean(xEntry(idCNO,:),2),1),nanmean(nanmean(yEntry(idCNO,:),2),1),'wo')
plot(nanmean(nanmean(xFeeder(idCNO,:),2),1),nanmean(nanmean(yFeeder(idCNO,:),2),1),'wx')
plot(nanmean(nanmean(xPrev(idCNO,:),2),1),nanmean(nanmean(yPrev(idCNO,:),2),1),'w>')
plot(nanmean(nanmean(xExit(idCNO,:),2),1),nanmean(nanmean(yExit(idCNO,:),2),1),'w<')
axis xy
hold off
caxis([0 0.025])
title('Mean decoding, Above threshold (CNO)')
%%
figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(mShouldSkip(:,:,2)-mShouldSkip(:,:,1)))
hold on
plot(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'wo')
plot(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'wx')
plot(nanmean(nanmean(xPrev,2),1),nanmean(nanmean(yPrev,2),1),'w>')
plot(nanmean(nanmean(xExit,2),1),nanmean(nanmean(yExit,2),1),'w<')
axis xy
hold off
caxis([-0.025 0.025])
title(sprintf('Difference in mean decoding, Above threshold\n(CNO - Saline)'))

%%
figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(mShouldStay(:,:,1))')
hold on
plot(nanmean(nanmean(xEntry(idVeh,:),2),1),nanmean(nanmean(yEntry(idVeh,:),2),1),'wo')
plot(nanmean(nanmean(xFeeder(idVeh,:),2),1),nanmean(nanmean(yFeeder(idVeh,:),2),1),'wx')
plot(nanmean(nanmean(xPrev(idVeh,:),2),1),nanmean(nanmean(yPrev(idVeh,:),2),1),'w>')
plot(nanmean(nanmean(xExit(idVeh,:),2),1),nanmean(nanmean(yExit(idVeh,:),2),1),'w<')
axis xy
hold off
caxis([0 0.025])
title('Mean decoding, Below threshold (Saline)')

figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(mShouldStay(:,:,2))')
hold on
plot(nanmean(nanmean(xEntry(idCNO,:),2),1),nanmean(nanmean(yEntry(idCNO,:),2),1),'wo')
plot(nanmean(nanmean(xFeeder(idCNO,:),2),1),nanmean(nanmean(yFeeder(idCNO,:),2),1),'wx')
plot(nanmean(nanmean(xPrev(idCNO,:),2),1),nanmean(nanmean(yPrev(idCNO,:),2),1),'w>')
plot(nanmean(nanmean(xExit(idCNO,:),2),1),nanmean(nanmean(yExit(idCNO,:),2),1),'w<')
axis xy
caxis([0 0.025])
hold off
title('Mean decoding, Below threshold (CNO)')
%%
figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(mShouldStay(:,:,2)-mShouldStay(:,:,1)))
hold on
plot(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'wo')
plot(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'wx')
plot(nanmean(nanmean(xPrev,2),1),nanmean(nanmean(yPrev,2),1),'w>')
plot(nanmean(nanmean(xExit,2),1),nanmean(nanmean(yExit,2),1),'w<')
axis xy
caxis([-0.025 0.025])
hold off
title(sprintf('Difference in mean decoding, Below threshold\n(CNO - Saline)'))
%%
figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(mAll(:,:,1))')
hold on
plot(nanmean(nanmean(xEntry(idVeh,:),2),1),nanmean(nanmean(yEntry(idVeh,:),2),1),'wo')
plot(nanmean(nanmean(xFeeder(idVeh,:),2),1),nanmean(nanmean(yFeeder(idVeh,:),2),1),'wx')
plot(nanmean(nanmean(xPrev(idVeh,:),2),1),nanmean(nanmean(yPrev(idVeh,:),2),1),'w>')
plot(nanmean(nanmean(xExit(idVeh,:),2),1),nanmean(nanmean(yExit(idVeh,:),2),1),'w<')
axis xy
hold off
caxis([0 0.025])
title('Mean decoding, All entries (Saline)')

figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(mAll(:,:,2))')
hold on
plot(nanmean(nanmean(xEntry(idCNO,:),2),1),nanmean(nanmean(yEntry(idCNO,:),2),1),'wo')
plot(nanmean(nanmean(xFeeder(idCNO,:),2),1),nanmean(nanmean(yFeeder(idCNO,:),2),1),'wx')
plot(nanmean(nanmean(xPrev(idCNO,:),2),1),nanmean(nanmean(yPrev(idCNO,:),2),1),'w>')
plot(nanmean(nanmean(xExit(idCNO,:),2),1),nanmean(nanmean(yExit(idCNO,:),2),1),'w<')
axis xy
caxis([0 0.025])
hold off
title('Mean decoding, All entries (CNO)')
%%
figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(mAll(:,:,2)-mAll(:,:,1)))
hold on
plot(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'wo')
plot(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'wx')
plot(nanmean(nanmean(xPrev,2),1),nanmean(nanmean(yPrev,2),1),'w>')
plot(nanmean(nanmean(xExit,2),1),nanmean(nanmean(yExit,2),1),'w<')
axis xy
caxis([-0.025 0.025])
hold off
title(sprintf('Difference in mean decoding, all entries\n(CNO - Saline)'))