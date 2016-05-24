function A = wrap_RR_analysis(condition,varargin)
% Wrapper for analyzing restaurant row data.
% A = wrap_RR_analysis(condition)
% where     A is a structure containing fields
%               .fn, nSDs x 1, filenames of sd files in condition,
%               .IdPhi, nSess x m, IdPhi for each session (rows) and trial (columns)
%               .zIdPhi, nSess x m, zIdPhi for each session (rows) and trial (columns)
%               .pVTE
%                   .gmobj, a two-component Gaussian mixture fit,
%                   .mixCoeffs, 1x2, the mixture coefficients of the mixfit,
%                   .mixCoeffCIs, 2x2, the lower (row 1) and upper (row 2) bootstrap CIs of the mixture coefficients
%                   .mixCoeffMedian, 1x2, the median estimate of the mixture coefficients, 
%                   .VTEthresh, arbitrary log10(IdPhi) threshold for identifying VTE directly, 
%                   .isVTE, nSess x nTrials, boolean of VTE/not based on above criterion, 
%                   .byThreshold, nSess x 1, proportion of laps exceeding criterion per session 
%               .EnteringZoneTime, nSess x m, entering time in seconds at each zone for each session (rows), and trial (columns)
%               .FeederTimes, nSess x m, time in seconds of feeder fire in seconds at each zone for each session (rows) and trial (columns)
%               .ExitZoneTime, nSess x m, time in seconds of zone exit for each session (rows) and trial (columns)
%               .staygo, nSess x m, stay (1) or go (1) for each session (rows) and trial (columns)
%               .pellets, nSess x m, number of pellets delivered for each session and trial
%               .zones, nSess x m, zone encountered for each session and trial
%               .threshold, nSess x nZones x maxPellets, threshold for each session (dim 1), zone (dim 2), and number of pellets (dim 3)
%               .correct, nSess x nZones x maxPellets, number of correctly identified stay/go
%               .error, nSess x nZones x maxPellets, number of error stay/go
%               .marginalPelletbyZone, nSess x nZones x 1, threshold for each zone (cols) when ignoring (marginalizing) number of pellets
%               .marginalZonebyPellet, nSess x 1 x maxPellets, threshold for each number of pellets, ignoring (marginalizing) zone identity
%               .RMSflavor, nSess x maxPellets, root mean squared deviation of zone thresholds from all zones, for each number of pellets
%               .RMSamount, nSess x nZones, root mean squared deviation of pellet thresholds from all pellet amounts, for each zone
%
%           condition is a string specifying which sessions have been
%           marked as vehicle (e.g., 'Saline') in the keys file or CNO
%           (e.g., 'Drug') in the keys file.
% 
%   Note that there may be more sessions than SD directories. 4x20
%   directories will have 4 sessions per directory.
%
% OPTIONAL:
% maxPellets    (default 3)             maximum number of pellets delivered at a feeder
% nZones        (default 4)             number of zones
% nLaps         (default 200)           maximum number of laps
% VTEtime       (default 2)             calculate VTE from EnteringZoneTime to EnteringZoneTime+VTEtime
% VTEthresh     (default 2.1)           minimum log10(IdPhi) to be considered VTE.
% fd            (default all subdirs)   RR directories to analyze
% plotFlag      (default false)         plot performance
% nBins         (default 51)            number of bins for zIdPhi histograms.
% doseToUse     (default all)           drug doses to use.
% forceInit     (default false)         force RRInit on all sessions.

%% defaults

maxPellets = 3;
nZones = 4;
nLaps = 200;
VTEtime = 2;
VTEthresh = 2.1;
nBins = 51;
doseToUse = [];
forceInit = false;
fn = FindFiles('RR-*.mat');
for f = 1 : length(fn); fd{f} = fileparts(fn{f}); end;
fd = unique(fd);

%%
process_varargin(varargin);

%% Init
disp('Init...')

fn = cell(length(fd),1);

for d = 1 : length(fd)
    pushdir(fd{d});
    disp(fd{d});
    
    folderName = fd{d};
    delim = regexpi(folderName,'\');
    SSN = folderName(max(delim)+1:end);
    sdfn = [SSN '-sd.mat'];
    
    if ~exist(sdfn,'file')==2 | forceInit
        sd=RRInit;
        save(sdfn,'sd');
    else
        disp([fd{d} ' already init''ed.']);
    end
    
    fn{d} = fullfile(fd{d},sdfn);
    popdir;
end

%% Identify drug conditions
disp('Get drug conditions... ')
[Drug,Doses]=RRGetDrugs(fn);

idCNO = strncmpi(condition,Drug,length(condition));

if ~isempty(doseToUse)
    
    idDose = doseToUse == Doses;
    idCNO = idCNO & idDose;
end

%% Restrict sdfn.
fn = fn(idCNO);

%% Check that there's data there.
uniqueDrugs = unique(Drug);
validConditions = '';
for iDrug = 1 : length(uniqueDrugs)
    validConditions = [validConditions sprintf('%s, ',uniqueDrugs{iDrug})];
end
validConditions = validConditions(1:end-2);
if ~isempty(doseToUse)
    uniqueDoses = unique(Doses);
    validDoses = '';
    for iDose = 1 : length(uniqueDoses)
        validDoses = [validDoses sprintf('%.1f, ',uniqueDoses(iDose))];
    end
    validDoses = validDoses(1:end-2);
    
    errorStr = ['Condition name ''' condition ''' at a dose of ' num2str(doseToUse) ' mg/kg does not match any keys file condition fields. Valid conditions are ' validConditions ' at doses of ' validDoses 'mg/kg.'];
else
    errorStr = ['Condition name ''' condition ''' does not match any keys file condition fields. Valid conditions are ' validConditions '.'];
end
assert(~isempty(fn),errorStr);

%% IdPhi, zIdPhi
disp('Calculating IdPhi, zIdPhi information...')
[IdPhi,Z] = RRGetIdPhi(fn,'VTEtime',VTEtime);
A.IdPhi = IdPhi;
A.zIdPhi = Z;

%% Gaussian mixture model
disp('Fitting Gaussian mixture model... ')
if ~isempty(A.IdPhi(~isnan(A.IdPhi)&A.IdPhi~=0))
    gmobj = gmmfit(log10(A.IdPhi(~isnan(A.IdPhi)&A.IdPhi~=0)),2);
    [tauLo,tauHi,tauMean,tauMedian] = gmmfitTauCI(gmobj,log10(A.IdPhi(~isnan(A.IdPhi)&A.IdPhi~=0)));
    mixCoeffbySess = nan(size(A.IdPhi,1),2);
    disp('Fitting GMM mixture coefficients by session... ')
    parfor iSess = 1 : size(A.IdPhi,1)
        idnan = isnan(A.IdPhi(iSess,:))|A.IdPhi(iSess,:)==0;
        mixCoeffbySess(iSess,:) = nanmean(gmobj.posterior(log10(A.IdPhi(iSess,~idnan))'));
    end
else
    gmobj = gmdistribution([nan;nan],nan(1,1,2),[nan;nan]);
    tauLo = nan(1,2);
    tauHi = nan(1,2);
    tauMean = nan(1,2);
    tauMedian = nan(1,2);
    mixCoeffbySess = nan(size(A.IdPhi,1),2);
end


A.pVTE.gmm = gmobj;
A.pVTE.mixCoeffs = tauMean;
A.pVTE.mixCoeffbySess = mixCoeffbySess;
A.pVTE.mixCoeffCIs = [tauLo; tauHi];
A.pVTE.mixCoeffMedian = tauMedian;
A.pVTE.VTEthresh = VTEthresh;
A.pVTE.isVTE = nan(size(A.IdPhi));
A.pVTE.isVTE(log10(A.IdPhi)<VTEthresh) = 0;
A.pVTE.isVTE(log10(A.IdPhi)>=VTEthresh) = 1;
A.pVTE.byThreshold = nansum(double(A.pVTE.isVTE==1),2)./nansum(double(~isnan(A.pVTE.isVTE)),2);


%% entering zone times
disp('Getting EnteringZoneTime field... ')
EnteringZoneTime = RRGetField(fn,'EnteringZoneTime');

A.EnteringZoneTime = EnteringZoneTime;

%% feeder times
disp('Getting FeederTimes field... ')
FeederTimes = RRGetField(fn,'FeederTimes');

A.FeederTimes = FeederTimes;

%% exit zone times
disp('Getting ExitZoneTime... ')
ExitZoneTime = RRGetField(fn,'ExitZoneTime');

A.ExitZoneTime = ExitZoneTime;

%% Stay/Go, pellets, delays, zones for each session of CNO condition
A.fn = fn;

disp('Getting stay/go booleans... ')
A.staygo = RRGetStaygo(A.fn);
disp('Getting pellet values... ')
A.pellets = RRGetPellets(A.fn);
disp('Getting delay values... ')
A.delays = RRGetDelays(A.fn);
disp('Extracting zone occupancy... ')
A.zones = RRGetZones(A.fn);

%% Thresholds for each zone in each session.
disp('Calculating thresholds... ')
A.thresholds = nan(size(A.staygo,1),nZones,maxPellets);
A.correct = nan(size(A.staygo,1),nZones,maxPellets);
A.error= nan(size(A.staygo,1),nZones,maxPellets);
A.LSE= nan(size(A.staygo,1),nZones,maxPellets);
A.marginalPelletbyZone = nan(size(A.staygo,1),nZones,1);
A.marginalZonebyPellet = nan(size(A.staygo,1),1,maxPellets);

for iSess = 1 : size(A.staygo,1);
    for iZ = 1 : nZones
        zoneRows = A.zones(iSess,:)==iZ;
        uniqueNs = unique(A.pellets(iSess,zoneRows));
        uniqueNs = uniqueNs(~isnan(uniqueNs));
        for iN = 1 : length(uniqueNs)
            pellets = uniqueNs(iN);
            idPellets = A.pellets(iSess,:)==pellets;
        
            delays = A.delays(iSess,zoneRows&idPellets);
            staygo = A.staygo(iSess,zoneRows&idPellets);
            [th,correct,error,LSE] = RRheaviside(delays(:),staygo(:));
            A.thresholds(iSess,iZ,pellets) = th;
            A.correct(iSess,iZ,pellets) = correct;
            A.error(iSess,iZ,pellets) = error;
            A.LSE(iSess,iZ,pellets) = LSE;
        end
        % Marginal: any Pellets by each zone
        delays = A.delays(iSess,zoneRows);
        staygo = A.staygo(iSess,zoneRows);
        th = RRheaviside(delays(:),staygo(:));
        A.marginalPelletbyZone(iSess,iZ,1) = th;
    end
    uniqueNs = unique(A.pellets(iSess,:));
    uniqueNs(isnan(uniqueNs)) = [];
    for iN = 1 : length(uniqueNs)
        pellets = uniqueNs(iN);
        idPellets = A.pellets(iSess,:)==pellets;
        
        delays = A.delays(iSess,idPellets);
        staygo = A.staygo(iSess,idPellets);
        th = RRheaviside(delays(:),staygo(:));
        A.marginalZonebyPellet(iSess,1,pellets) = th;
    end
end


%% Effect of flavour on choice:
%  for each number of pellets, find RMS deviation of threshold of zones
%  from overall across all zones
disp('Calculating degree of flavour preference for each pellet amount... ')
delta = A.thresholds - repmat(A.marginalZonebyPellet,[1,size(A.thresholds,2),1]);
uniqueNs = unique(A.pellets(~isnan(A.pellets)));

RMS = nan(size(delta,1),size(delta,3));
for iN = 1 : length(uniqueNs)
    pellets = uniqueNs(iN);
    for iSess = 1 : size(delta,1)
        sessDev = squeeze(delta(iSess,:,pellets));
        SS = sessDev(:)'*sessDev(:);
        MS = SS/numel(sessDev);
        RMS(iSess,pellets) = sqrt(MS);
    end
end
A.RMSflavor = RMS;

%% Effect of pellets on choice:
%  for each zone, find RMS deviation of threshold of pellets from overall
%  across all pellets
disp('Calculating degree of pellet amount preference for each flavour... ')
delta = A.thresholds - repmat(A.marginalPelletbyZone,[1,1,size(A.thresholds,3)]);

RMS = nan(size(delta,1),size(delta,2));
for iZ = 1 : 4
    for iSess = 1 : size(delta,1)
        sessDev = squeeze(delta(iSess,iZ,uniqueNs));
        SS = sessDev(:)'*sessDev(:);
        MS = SS/numel(sessDev);
        RMS(iSess,iZ) = sqrt(MS);
    end
end
A.RMSamount = RMS;

%%
disp('Restaurant row summary complete.')