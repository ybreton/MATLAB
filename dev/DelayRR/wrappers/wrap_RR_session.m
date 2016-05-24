function sess = wrap_RR_session(sd,varargin)
% Wrapper to add fields to sd session data.
% sd = wrap_RR_session(sd)
% where     sd            is a nSubsess x 1 structure array with fields
%               .fd                 directory name,
%               .SSN                session number,
%               .Weight             rat weights (g),
%               .PostFeed           post-feedings (g),
%               .Behavior           behavioural protocol,
%               .Condition          drug condition string,
%               .Dose               drug doses (mg/kg),
%
%               .Staygo             1 x nTrials vector of stay/go values, 
%               .Zones              1 x nTrials vector of zone numbers, 
%               .Pellets            1 x nTrials vector of food pellets, 
%               .Delays             1 x nTrials vector of delays, 
%               .LogIdPhi           1 x nTrials vector of Log10(IdPhi) values,
%               .zIdPhi             1 x nTrials vector  of Z(IdPhi) values,
%               .WholeSession       (the following are basesd on the entire
%                                   session)
%                   .Thresholds.FlavourAmount   
%                                   nZones x nPellets matrix of thresholds,
%                   .Thresholds.FlavourMarginalByAmount
%                                   nZones x nPellets matrix of threshold
%                                       ignoring flavours at amount,
%                   .Thresholds.AmountMarginalByFlavour
%                                   nZones x nPellets matrix of threshold
%                                       ignoring amounts at flavour,
%                   .Thresholds.GrandOverall
%                                   nZones x nPellets matrix of threshold
%                                       ignoring amount and flavour,
%
%                   .RMSD.Amount        nZones x 1 vector of RMS deviations of
%                                       amount from AmountMarginalByFlavour
%                                       for each flavour,
%                   .RMSD.Flavour       1 x nPellets vector of RMS deviations
%                                       of flavour from
%                                       FlavourMarginalByAmount for each
%                                       amount,
%                   .RMSD.Overall       scalar of RMS deviation of session
%                                       thresholds for amount and flavour
%                                       from GrandOverall,
%                   .ThreshByTrial      1 x nTrials vector of threshold values
%                                       for trial
%
%                   .ShouldSkip         1 x nTrials vector of should/shouldn't skip zone,
%                   .ShouldStay         1 x nTrials vector of should/shouldn't stay in zone,
%                   .isError            1 x nTrials vector of incorrect trial (skip & shouldstay or stay & shouldskip),
%                   .isCorrect          1 x nTrials vector of correct trial (skip & shouldskip or stay & shouldstay),
%
%               .Subsession     (The following are based on only the
%                               subsession in sd(s).)
%   
%                   .Thresholds.FlavourAmount   
%                   .Thresholds.FlavourMarginalByAmount
%                   .Thresholds.AmountMarginalByFlavour
%                   .Thresholds.GrandOverall
%                   .RMSD.Amount
%                   .RMSD.Flavour
%                   .RMSD.Overall
%                   .ThreshByTrial
%                   .ShouldSkip
%                   .ShouldStay
%                   .isError
%                   .isCorrect
%
%          sd           is an nSubsess x 1 stucture of sd.
%
% OPTIONAL ARGUMENTS:
% ******************
% VTEtime   (default 3)         seconds for LogIdPhi and zIdPhi data.
%

VTEtime = 3;
process_varargin(varargin);

[condition,dose] = RRGetDrugs(sd);
staygo = RRGetStaygo(sd);
zones = RRGetZones(sd);
pellets = RRGetPellets(sd);
delays = RRGetDelays(sd);
thresholds = RRThresholds(sd);
threshByTrial = RRthreshByTrial(sd);
[marginalAmountByFlavour,marginalFlavourByAmount,marginalAmountFlavour] = RRThresholdMarginals(sd);

disp(sprintf('Obtaining IdPhi, using VTE time of %.1f seconds...',VTEtime))
[IdPhi,zidphi] = RRGetIdPhi(sd,'VTEtime',VTEtime);
[ShouldSkip,ShouldStay] = RRIdentifyShouldStayGo(sd);
[isError,isCorrect] = RRDecisionInstability(sd);

disp('Calculating RMSD values...')
% RMSamount:
% variance of threshold for zone/amount around any amount of zone
dev = thresholds-marginalAmountByFlavour;
SS = nan(size(dev,1),1);
n = nan(size(dev,1),1);
for iZ=1:size(dev,1)
    idInc = ~isnan(dev(iZ,:));
    n(iZ) = sum(double(idInc));
    SS(iZ) = dev(iZ,idInc)*dev(iZ,idInc)';
end
MS = SS./n;
RMSamount = sqrt(MS);

% RMSflavour:
% variance of threshold for amount/zone around any zone of amount
dev = thresholds-marginalFlavourByAmount;
SS = nan(1,size(dev,2));
n = nan(1,size(dev,2));
for nP=1:size(dev,2)
    idInc = ~isnan(dev(:,nP));
    n(nP) = sum(double(idInc));
    SS(nP) = dev(idInc,nP)'*dev(idInc,nP);
end
MS = SS./n;
RMSflavour = sqrt(MS);

% RMSoverall:
% variance of threshold for amount/zone around any amount of any zone
dev = thresholds(:)-marginalAmountFlavour(:);
idInc = ~isnan(dev);
n = sum(double(idInc));
SS = dev(idInc)'*dev(idInc);
MS = SS./n;
RMSoverall = sqrt(MS);

if numel(sd)==1
    disp('Updating sd structure...')
end
for s = 1 : numel(sd)
    if numel(sd)>1
        disp(sprintf('Processing sub-session %d',s))
    end
    sess0 = sd(s);
    sess0.fd = sd(s).ExpKeys.fd;
    sess0.SSN = sd(s).ExpKeys.SSN;
    sess0.Behavior = sd(s).ExpKeys.Behavior;
    sess0.Weight = sd(s).ExpKeys.Weight;
    sess0.PostFeed = sd(s).ExpKeys.PostFeed;
    sess0.Condition = condition{s};
    sess0.Dose = dose(s,:);
    sess0.Staygo = staygo(s,:);
    sess0.Zones = zones(s,:);
    sess0.Pellets = pellets(s,:);
    sess0.Delays = delays(s,:);
    sess0.LogIdPhi = log10(IdPhi(s,:));
    sess0.zIdPhi = zidphi(s,:);
        
    sess0.Subsession.Thresholds.FlavourAmount = RRThresholds(sd(s));
    [SubsessAmountByFlavour,SubsessFlavourByAmount,SubsessAmountFlavour] = RRThresholdMarginals(sd(s));
    [SubsessShouldSkip,SubsessShouldStay] = RRIdentifyShouldStayGo(sd);
    [SubsessisError,SubsessisCorrect] = RRDecisionInstability(sd);
    
    dev = sess0.Subsession.Thresholds.FlavourAmount-SubsessAmountByFlavour;
    SS = nan(size(dev,1),1);
    n = nan(size(dev,1),1);
    for iZ=1:size(dev,1)
        idInc = ~isnan(dev(iZ,:));
        n(iZ) = sum(double(idInc));
        SS(iZ) = dev(iZ,idInc)*dev(iZ,idInc)';
    end
    MS = SS./n;
    sess0.Subsession.RMSD.Amount = sqrt(MS);
    
    dev = sess0.Subsession.Thresholds.FlavourAmount-SubsessFlavourByAmount;
    SS = nan(1,size(dev,2));
    n = nan(1,size(dev,2));
    for nP=1:size(dev,2)
        idInc = ~isnan(dev(:,nP));
        n(nP) = sum(double(idInc));
        SS(nP) = dev(idInc,nP)'*dev(idInc,nP);
    end
    MS = SS./n;
    sess0.Subsession.RMSD.Flavour = sqrt(MS);
    
    dev = sess0.Subsession.Thresholds.FlavourAmount(:)-SubsessAmountFlavour(:);
    idInc = ~isnan(dev);
    n = sum(double(idInc));
    SS = dev(idInc)'*dev(idInc);
    MS = SS./n;
    sess0.Subsession.RMSD.Overall = sqrt(MS);
    
    sess0.Subsession.Thresholds.FlavourMarginalByAmount = SubsessFlavourByAmount;
    sess0.Subsession.Thresholds.AmountMarginalByFlavour = SubsessAmountByFlavour;
    sess0.Subsession.Thresholds.GrandOverall = SubsessAmountFlavour;
    sess0.Subsession.ThreshByTrial = RRthreshByTrial(sd(s));
    sess0.Subsession.ShouldSkip = SubsessShouldSkip;
    sess0.Subsession.ShouldStay = SubsessShouldStay;
    sess0.Subsession.isError = SubsessisError;
    sess0.Subsession.isCorrect = SubsessisCorrect;
    
    sess0.WholeSession.Thresholds.FlavourAmount = thresholds;
    sess0.WholeSession.Thresholds.FlavourMarginalByAmount = marginalFlavourByAmount;
    sess0.WholeSession.Thresholds.AmountMarginalByFlavour = marginalAmountByFlavour;
    sess0.WholeSession.Thresholds.GrandOverall = marginalAmountFlavour;
    sess0.WholeSession.RMSD.Amount = RMSamount;
    sess0.WholeSession.RMSD.Flavour = RMSflavour;
    sess0.WholeSession.RMSD.Overall = RMSoverall;
    sess0.WholeSession.ThreshByTrial = threshByTrial(s,:);
    sess0.WholeSession.ShouldSkip = ShouldSkip(s,:);
    sess0.WholeSession.ShouldStay = ShouldStay(s,:);
    sess0.WholeSession.isError = isError(s,:);
    sess0.WholeSession.isCorrect = isCorrect(s,:);
    
    sess(s,1) = sess0;
    clear sess0
end