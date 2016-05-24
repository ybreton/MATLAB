fn = FindFiles('RR-*.mat');
fd = cell(length(fn),1);
for iF=1:length(fn); fd{iF}=fileparts(fn{iF}); end;
fd = unique(fd);
%%
nBins = 64;
%%
Condition = cell(length(fd),1);

pRegret = nan(length(fd),800,nBins,nBins);
pRejoice = nan(length(fd),800,nBins,nBins);
pDisapp1 = nan(length(fd),800,nBins,nBins);
pDisapp2 = nan(length(fd),800,nBins,nBins);
pAll = nan(length(fd),800,nBins,nBins);

xEntry = nan(length(fd),800);
yEntry = nan(length(fd),800);
xFeeder = nan(length(fd),800);
yFeeder = nan(length(fd),800);
xExit = xEntry;
yExit = yEntry;
xPrev = xEntry;
yPrev = yEntry;

for iD = 1 : length(fd)
    pushdir(fd{iD});
    disp(fd{iD});
    
    sd = RRInit;
    Condition{iD} = sd(1).ExpKeys.Condition;
    sd.x = sd.x.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);
    sd.y = sd.y.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);
    [sd.x,sd.y] = RRcentreMaze(sd);
    sd = RRFindQuadrant(sd);
    sd = RRrotateXYalign(sd);
    
    idTT = RRassignTetrodeClusters(sd);
    ISI = nan(length(sd.S),1);
    spikes = nan(length(sd.S),1);
    for iC=1:length(sd.S);
        ISI(iC) = nanmean(diff(sd.S{iC}.data));
        spikes(iC) = length(data(sd.S{iC}.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack)));
    end
    SR = 1./ISI;
    idInterNrn = SR>2;
    idSpks = spikes>=40;
    
    disp('Tuning curves...')
    TC = TuningCurves(sd.S(idTT(1,~idInterNrn&idSpks)),{{sd.x -250 250 nBins} {sd.y -250 250 nBins}});
    
    disp('Q matrix...')
    Q = MakeQfromS(sd.S(idTT(1,~idInterNrn&idSpks)),0.125);
    disp('Bayesian decoding...')
    B = BayesianDecoding(Q,TC);
    D = B.pxs.data(sd.EnteringZoneTime);
    B.pxs = tsd(sd.EnteringZoneTime(:),D);
    B.rotPxs = RRrotateDecoding(B,sd)
    clear D;
    
    regret = RRGetRegret(sd)==1;
    rejoice = RRGetRejoice(sd)==1;
    disapp = RRGetDisappointment(sd);
    disapp1 = disapp.Disapp1==1;
    disapp2 = disapp.Disapp2==1;
    nTrl = length(sd.ZoneIn);
    
    Tregret = sd.EnteringZoneTime(regret(1:nTrl));
    Trejoice = sd.EnteringZoneTime(rejoice(1:nTrl));
    Tdisapp1 = sd.EnteringZoneTime(disapp1(1:nTrl));
    Tdisapp2 = sd.EnteringZoneTime(disapp2(1:nTrl));
    Tall = sd.EnteringZoneTime;
    
%     pRegret(iD,1:length(Tregret),:,:) = RRzoneAlignedDecoding(sd,B,Tregret);
%     pRejoice(iD,1:length(Trejoice),:,:) = RRzoneAlignedDecoding(sd,B,Trejoice);
%     pDisapp1(iD,1:length(Tdisapp1),:,:) = RRzoneAlignedDecoding(sd,B,Tdisapp1);
%     pDisapp2(iD,1:length(Tdisapp2),:,:) = RRzoneAlignedDecoding(sd,B,Tdisapp2);
%     [pAll(iD,1:length(Tall),:,:)] = RRzoneAlignedDecoding(sd,B,Tall);
    
    pRegret(iD,1:length(Tregret),:,:) = B.rotPxs.data(Tregret);
    pRejoice(iD,1:length(Trejoice),:,:) = B.rotPxs.data(Trejoice);
    pDisapp1(iD,1:length(Tdisapp1),:,:) = B.rotPxs.data(Tdisapp1);
    pDisapp2(iD,1:length(Tdisapp2),:,:) = B.rotPxs.data(Tdisapp2);
    pAll(iD,1:length(Tall),:,:) = B.rotPxs.data(Tall);
    
    landmarks(iD) = RRalignedLandmarks(sd);
    xEntry(iD,1:length(landmarks(iD).ZoneEntry.x.data)) = landmarks(iD).ZoneEntry.x.data;
    yEntry(iD,1:length(landmarks(iD).ZoneEntry.y.data)) = landmarks(iD).ZoneEntry.y.data;
    xFeeder(iD,1:length(landmarks(iD).Feeder.x.data)) = landmarks(iD).Feeder.x.data;
    yFeeder(iD,1:length(landmarks(iD).Feeder.y.data)) = landmarks(iD).Feeder.y.data;
    xExit(iD,1:length(landmarks(iD).ZoneExit.x.data)) = landmarks(iD).ZoneExit.x.data;
    yExit(iD,1:length(landmarks(iD).ZoneExit.y.data)) = landmarks(iD).ZoneExit.y.data;
    xPrev(iD,1:length(landmarks(iD).PrevZone.x.data)) = landmarks(iD).PrevZone.x.data;
    yPrev(iD,1:length(landmarks(iD).PrevZone.y.data)) = landmarks(iD).PrevZone.y.data;
    
    imagesc(linspace(-250,250,nBins),linspace(-250,250,nBins),squeeze(nanmean(nanmean(pRegret(1:iD,:,:,:),2),1))')
    hold on
    plot(xEntry(:),yEntry(:),'wo')
    text(nanmean(xEntry(:)),min(yEntry(:)),'Zone Entry','color','w','HorizontalAlignment','center','VerticalAlignment','top')
    plot(xFeeder(:),yFeeder(:),'wx')
    text(nanmean(xFeeder(:)),max(yFeeder(:)),'Feeder','color','w','HorizontalAlignment','center','VerticalAlignment','bottom')
    plot(xExit(:),yExit(:),'w<')
    text(nanmean(nanmean(xExit,2),1),max(yExit(:)),'Next zone','color','w','HorizontalAlignment','center','VerticalAlignment','bottom')
    plot(xPrev(:),yPrev(:),'w>')
    text(nanmean(xPrev(:)),min(yPrev(:)),'Last zone','color','w','HorizontalAlignment','center','VerticalAlignment','top')
    axis xy
    caxis([0 0.025])
    colorbar;
    hold off
    drawnow
    popdir;
end
%%
idVeh = strncmpi('Veh',Condition,3)|strncmpi('Sal',Condition,3);
idCNO = strncmpi('Dru',Condition,3)|strncmpi('CNO',Condition,3);

%%
mRegret = nan(nBins,nBins,2);
mRegret(:,:,1) = squeeze(nanmean(nanmean(pRegret(idVeh,:,:,:),2),1));
mRegret(:,:,2) = squeeze(nanmean(nanmean(pRegret(idCNO,:,:,:),2),1));

figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(mRegret(:,:,1))')
hold on
    plot(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'wo')
    text(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'Zone Entry','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    plot(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'wx')
    text(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'Feeder','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    axis xy
hold off
title('Mean decoding, regret instance (Saline)')

figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(mRegret(:,:,2))')
hold on
    plot(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'wo')
    text(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'Zone Entry','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    plot(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'wx')
    text(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'Feeder','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    axis xy
hold off
title('Mean decoding, regret instance (CNO)')

figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),(squeeze(mRegret(:,:,2)-mRegret(:,:,1)))')
hold on
    plot(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'wo')
    text(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'Zone Entry','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    plot(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'wx')
    text(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'Feeder','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    axis xy
hold off
title(sprintf('Difference in mean decoding, regret\n(CNO - Saline)'))
%%
mDisapp = nan(nBins,nBins,2);
mDisapp(:,:,1) = squeeze(nanmean(nanmean(pDisapp1(idVeh,:,:,:),2),1));
mDisapp(:,:,2) = squeeze(nanmean(nanmean(pDisapp1(idCNO,:,:,:),2),1));

figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(mDisapp(:,:,1))')
hold on
    plot(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'wo')
    text(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'Zone Entry','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    plot(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'wx')
    text(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'Feeder','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    axis xy
hold off
title('Mean decoding, disappointment instance (Saline)')

figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(mDisapp(:,:,2))')
hold on
    plot(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'wo')
    text(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'Zone Entry','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    plot(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'wx')
    text(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'Feeder','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    axis xy
hold off
title('Mean decoding, disappointment instance (CNO)')

figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(diff(mDisapp,1,3)))
hold on
plot(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'wo')
hold off
title(sprintf('Difference in mean decoding, disappointment\n(CNO - Saline)'))

%%
mDisapp = nan(nBins,nBins,2);
mDisapp(:,:,1) = squeeze(nanmean(nanmean(pDisapp2(idVeh,:,:,:),2),1));
mDisapp(:,:,2) = squeeze(nanmean(nanmean(pDisapp2(idCNO,:,:,:),2),1));

figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(mDisapp(:,:,1))')
hold on
    plot(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'wo')
    text(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'Zone Entry','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    plot(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'wx')
    text(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'Feeder','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    axis xy
hold off
title('Mean decoding, bad luck instance (Saline)')

figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(mDisapp(:,:,2))')
hold on
    plot(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'wo')
    text(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'Zone Entry','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    plot(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'wx')
    text(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'Feeder','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    axis xy
hold off
title('Mean decoding, bad luck instance (CNO)')

figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(diff(mDisapp,1,3)))
hold on
    plot(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'wo')
    text(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'Zone Entry','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    plot(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'wx')
    text(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'Feeder','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    axis xy
hold off
title(sprintf('Difference in mean decoding, bad luck\n(CNO - Saline)'))

%%
mRejoice = nan(nBins,nBins,2);
mRejoice(:,:,1) = squeeze(nanmean(nanmean(pRejoice(idVeh,:,:,:),2),1));
mRejoice(:,:,2) = squeeze(nanmean(nanmean(pRejoice(idCNO,:,:,:),2),1));

figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(mRejoice(:,:,1))')
hold on
    plot(nanmean(nanmean(xEntry(idVeh,:),2),1),nanmean(nanmean(yEntry(idVeh,:),2),1),'wo')
    text(nanmean(nanmean(xEntry(idVeh,:),2),1),nanmean(nanmean(yEntry(idVeh,:),2),1),'Zone Entry','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    plot(nanmean(nanmean(xFeeder(idVeh,:),2),1),nanmean(nanmean(yFeeder(idVeh,:),2),1),'wx')
    text(nanmean(nanmean(xFeeder(idVeh,:),2),1),nanmean(nanmean(yFeeder(idVeh,:),2),1),'Feeder','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    axis xy
hold off
title('Mean decoding, rejoice instance (Saline)')

figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(mRejoice(:,:,2))')
hold on
    plot(nanmean(nanmean(xEntry(idCNO,:),2),1),nanmean(nanmean(yEntry(idCNO,:),2),1),'wo')
    text(nanmean(nanmean(xEntry(idCNO,:),2),1),nanmean(nanmean(yEntry(idCNO,:),2),1),'Zone Entry','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    plot(nanmean(nanmean(xFeeder(idCNO,:),2),1),nanmean(nanmean(yFeeder(idCNO,:),2),1),'wx')
    text(nanmean(nanmean(xFeeder(idCNO,:),2),1),nanmean(nanmean(yFeeder(idCNO,:),2),1),'Feeder','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    axis xy
hold off
title('Mean decoding, rejoice instance (CNO)')

figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(diff(mRejoice,1,3)))
hold on
    plot(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'wo')
    text(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'Zone Entry','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    plot(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'wx')
    text(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'Feeder','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    axis xy
hold off
title(sprintf('Difference in mean decoding, rejoice\n(CNO - Saline)'))

%%
mAll = nan(nBins,nBins,2);
mAll(:,:,1) = squeeze(nanmean(nanmean(pAll(idVeh,:,:,:),2),1));
mAll(:,:,2) = squeeze(nanmean(nanmean(pAll(idCNO,:,:,:),2),1));

figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(mAll(:,:,1))')
hold on
    plot(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'wo')
    text(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'Zone Entry','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    plot(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'wx')
    text(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'Feeder','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    axis xy
hold off
title('Mean decoding, all entries (Saline)')

figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(mAll(:,:,2))')
hold on
    plot(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'wo')
    text(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'Zone Entry','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    plot(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'wx')
    text(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'Feeder','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    axis xy
hold off
title('Mean decoding, all entries (CNO)')

figure;
imagesc(linspace(-250,250,nBins),linspace(-250, 250, nBins),squeeze(diff(mAll,1,3)))
hold on
    plot(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'wo')
    text(nanmean(nanmean(xEntry,2),1),nanmean(nanmean(yEntry,2),1),'Zone Entry','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    plot(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'wx')
    text(nanmean(nanmean(xFeeder,2),1),nanmean(nanmean(yFeeder,2),1),'Feeder','color','w','HorizontalAlignment','left','VerticalAlignment','top')
    axis xy
hold off
title(sprintf('Difference in mean decoding, all entries\n(CNO - Saline)'))