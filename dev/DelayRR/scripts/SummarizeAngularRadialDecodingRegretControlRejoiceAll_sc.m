fn = FindFiles('RR-*.mat');
fd = cell(length(fn),1);
for iF=1:length(fn); fd{iF}=fileparts(fn{iF}); end;
fd = unique(fd);
%%
nBin1 = 64;
nBin2 = 64;
%%
Condition = cell(length(fd),1);
pRegret = nan(length(fd),nBin1/2,nBin2/2);
pRejoice = nan(length(fd),nBin1/2,nBin2/2);
pDisapp1 = nan(length(fd),nBin1/2,nBin2/2);
pDisapp2 = nan(length(fd),nBin1/2,nBin2/2);
pAll = nan(length(fd),nBin1/2,nBin2/2);
for iD = 1 : length(fd)
    pushdir(fd{iD});
    disp(fd{iD});
    
    sd = RRInit;
    Condition{iD} = sd(1).ExpKeys.Condition;
%     CoM = [nanmean(sd.x.data(sd.EnteringZoneTime)) nanmean(sd.y.data(sd.EnteringZoneTime))];
% 	[x,y]=RRlinearizePath(sd);
%     sd.theta = tsd(sd.x.range,atan2(sd.y.data-CoM(2),sd.x.data-CoM(1)));
%     sd.radius = tsd(sd.x.range,sqrt((sd.x.data-CoM(1)).^2+(sd.y.data-CoM(2)).^2));
%     sd.theta = tsd(x.range,atan2(y.data,x.data));
%     sd.radius = tsd(x.range,sqrt(x.data.^2+y.data.^2));
    
    [sd.theta,sd.radius] = RRstandardizeMaze(sd);
    
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
    TC = TuningCurves(sd.S(idTT(1,~idInterNrn&idSpks)),{{sd.theta, -pi, pi, nBin1} {sd.radius nBin2}});
    disp('Q matrix...')
    Q = MakeQfromS(sd.S(idTT(1,~idInterNrn&idSpks)),0.125);
    disp('Bayesian decoding...')
    B = BayesianDecoding(Q,TC);
    
    regret = RRGetRegret(sd);
    disapp = RRGetDisappointment(sd);
    rejoice = RRGetRejoice(sd);
    
    Tregret = sd.EnteringZoneTime(regret(1:length(sd.ZoneIn))==1);
    Tdisapp1 = sd.EnteringZoneTime(disapp.Disapp1(1:length(sd.ZoneIn))==1);
    Tdisapp2 = sd.EnteringZoneTime(disapp.Disapp2(1:length(sd.ZoneIn))==1);
    Trejoice = sd.EnteringZoneTime(rejoice(1:length(sd.ZoneIn))==1);
    
    thetaBins = linspace(-pi,pi,nBin1/2);
    radiusBins = linspace(-0.1,1,nBin2/2);
    
    pOut = RRplotAngleRadiusDecoding(sd,B,sd.EnteringZoneTime,thetaBins,radiusBins);
    idOcc = squeeze(any(~isnan(pOut),1))';
    hold on; 
    contour(thetaBins,radiusBins,idOcc,[0 0],'w-'); 
    hold off
    axis xy
    title('All entries')
    drawnow
    pAll(iD,:,:) = nanmean(pOut,1);
    
    pOut = RRplotAngleRadiusDecoding(sd,B,Tregret,thetaBins,radiusBins);
    hold on; contour(thetaBins,radiusBins,idOcc,[0 0],'w-'); hold off
    axis xy
    title('Regret')
    drawnow
    pRegret(iD,:,:) = nanmean(pOut,1);
    
    pOut = RRplotAngleRadiusDecoding(sd,B,Tdisapp1,thetaBins,radiusBins);
    hold on; contour(thetaBins,radiusBins,idOcc,[0 0],'w-'); hold off
    axis xy
    title('Disappointment')
    drawnow
    pDisapp1(iD,:,:) = nanmean(pOut,1);
    
    pOut = RRplotAngleRadiusDecoding(sd,B,Tdisapp2,thetaBins,radiusBins);
    hold on; contour(thetaBins,radiusBins,idOcc,[0 0],'w-'); hold off
    axis xy
    title('Bad luck')
    drawnow
    pDisapp2(iD,:,:) = nanmean(pOut,1);
    
    pOut = RRplotAngleRadiusDecoding(sd,B,Trejoice,thetaBins,radiusBins);
    hold on; contour(thetaBins,radiusBins,idOcc,[0 0],'w-'); hold off
    axis xy
    title('Rejoice')
    drawnow
    pRejoice(iD,:,:) = nanmean(pOut,1);
    
    popdir;
end
%%
idVeh = strcmpi('Vehicle',Condition)|strcmpi('Saline',Condition);
idCNO = strcmpi('CNO',Condition)|strcmpi('Drug',Condition);
%%
controlImg = squeeze(nanmean(pAll(idVeh,:,:)))';
expImg = squeeze(nanmean(pRegret(idVeh,:,:)))';
figure;
[fh,ah,cbh,oh] = RRplotExpControlImgs(thetaBins,radiusBins,controlImg,expImg,'zMax',0.05,'zMin',0);
for iP = 1 : length(ah)
    if ~isnan(ah(iP));
        set(get(ah(iP),'ylabel'),'string','Pixel radius from zone entry')
        set(get(ah(iP),'xlabel'),'string','Radians from zone entry')
        set(get(cbh(iP),'ylabel'),'string','Mean decoded probability')
    end
end
set(can2mat(get(ah([1 4]),'title')),'string','All zone entries, vehicle')
set(get(ah(3),'title'),'string','Regret entries, vehicle')

%%
controlImg = squeeze(nanmean(pAll(idVeh,:,:)))';
expImg = squeeze(nanmean(pDisapp1(idVeh,:,:)))';
figure;
[fh,ah,cbh,oh] = RRplotExpControlImgs(thetaBins,radiusBins,controlImg,expImg,'zMax',0.05,'zMin',0);
for iP = 1 : length(ah)
    if ~isnan(ah(iP));
        set(get(ah(iP),'ylabel'),'string','Pixel radius from zone entry')
        set(get(ah(iP),'xlabel'),'string','Radians from zone entry')
        set(get(cbh(iP),'ylabel'),'string','Mean decoded probability')
    end
end
set(can2mat(get(ah([1 4]),'title')),'string','All zone entries, vehicle')
set(get(ah(3),'title'),'string','Disappointment entries, vehicle')

%%
controlImg = squeeze(nanmean(pAll(idVeh,:,:)))';
expImg = squeeze(nanmean(pDisapp2(idVeh,:,:)))';
figure;
[fh,ah,cbh,oh] = RRplotExpControlImgs(thetaBins,radiusBins,controlImg,expImg,'zMax',0.05,'zMin',0);
for iP = 1 : length(ah)
    if ~isnan(ah(iP));
        set(get(ah(iP),'ylabel'),'string','Pixel radius from zone entry')
        set(get(ah(iP),'xlabel'),'string','Radians from zone entry')
        set(get(cbh(iP),'ylabel'),'string','Mean decoded probability')
    end
end
set(can2mat(get(ah([1 4]),'title')),'string','All zone entries, vehicle')
set(get(ah(3),'title'),'string','Bad luck entries, vehicle')

%%
controlImg = squeeze(nanmean(pAll(idVeh,:,:)))';
expImg = squeeze(nanmean(pRejoice(idVeh,:,:)))';
figure;
[fh,ah,cbh,oh] = RRplotExpControlImgs(thetaBins,radiusBins,controlImg,expImg,'zMax',0.05,'zMin',0);
for iP = 1 : length(ah)
    if ~isnan(ah(iP));
        set(get(ah(iP),'ylabel'),'string','Pixel radius from zone entry')
        set(get(ah(iP),'xlabel'),'string','Radians from zone entry')
        set(get(cbh(iP),'ylabel'),'string','Mean decoded probability')
    end
end
set(can2mat(get(ah([1 4]),'title')),'string','All zone entries, vehicle')
set(get(ah(3),'title'),'string','Rejoice entries, vehicle')

%%
controlImg = squeeze(nanmean(pRegret(idVeh,:,:)))';
expImg = squeeze(nanmean(pRegret(idCNO,:,:)))';
figure;
[fh,ah,cbh,oh] = RRplotExpControlImgs(thetaBins,radiusBins,controlImg,expImg,'zMax',0.05,'zMin',0);
for iP = 1 : length(ah)
    if ~isnan(ah(iP));
        set(get(ah(iP),'ylabel'),'string','Pixel radius from zone entry')
        set(get(ah(iP),'xlabel'),'string','Radians from zone entry')
        set(get(cbh(iP),'ylabel'),'string','Mean decoded probability')
    end
end
set(can2mat(get(ah([1 4]),'title')),'string','Regret entries, vehicle')
set(get(ah(3),'title'),'string','Regret entries, CNO')