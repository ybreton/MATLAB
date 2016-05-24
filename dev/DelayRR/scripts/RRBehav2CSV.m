fn = FindFiles('RR*.mat');
fd = cell(length(fn),1);
for iF=1:length(fn); fd{iF} = fileparts(fn{iF}); end;
fd = unique(fd);

for iD = 1 : length(fd)
    pushdir(fd{iD});
    disp(fd{iD});
    sdfn = FindFiles('*-sd.mat','CheckSubdirs',false);
    if ~isempty(sdfn)
        sd = RRInit;

        nSess = length(sd);
        nTrials = nan(nSess,1);
        nLaps = nan(nSess,1);
        nZones = nan(nSess,1);
        for iSess=1:nSess
            nTrials(iSess) = length(sd(iSess).ZoneIn);
            nLaps(iSess) = sd(iSess).TotalLaps;
            nZones(iSess) = length(unique(sd(iSess).ZoneIn));
        end
        SSN = repmat({sd(1).ExpKeys.SSN},nSess,max(nTrials));
        Sess = repmat((1:nSess)',1,max(nTrials));
        Trial = repmat(1:max(nTrials),nSess,1);
        laps = repmat(1:max(nLaps)+1,max(nZones),1);
        laps = laps(:)';
        Lap = nan(nSess,max(nTrials));
        TIZ = nan(nSess,max(nTrials));
        ZIT = nan(nSess,max(nTrials));
        ZOT = nan(nSess,max(nTrials));
        StayGo = nan(nSess,max(nTrials));
        ZoneIn = nan(nSess,max(nTrials));
        ZD = nan(nSess,max(nTrials));
        N = nan(nSess,max(nTrials));

        for iSess=1:nSess
            Sess(iSess,nTrials(iSess)+1:end) = nan;
            Trial(iSess,nTrials(iSess)+1:end) = nan;
            Lap(iSess,1:nTrials(iSess)) = laps(1:nTrials(iSess));
            ZD(iSess,1:nTrials(iSess)) = sd(iSess).ZoneDelay;
            N(iSess,1:nTrials(iSess)) = sd(iSess).nPellets;
            ZoneIn(iSess,1:nTrials(iSess)) = sd(iSess).ZoneIn;
            ExitZoneTime = nan(1,nTrials(iSess));
            ExitZoneTime(1:length(sd(iSess).ExitZoneTime)) = sd(iSess).ExitZoneTime;
            EnteringZoneTime = nan(1,nTrials(iSess));
            EnteringZoneTime(1:length(sd(iSess).EnteringZoneTime)) = sd(iSess).EnteringZoneTime;
            TIZ(iSess,1:nTrials(iSess)) = ExitZoneTime - sd(iSess).EnteringZoneTime;
            ZIT(iSess,1:nTrials(iSess)) = EnteringZoneTime;
            ZOT(iSess,1:nTrials(iSess)) = ExitZoneTime;
            SG = RRGetStaygo(sd(iSess));
            StayGo(iSess,1:nTrials(iSess)) = SG(1:nTrials(iSess));
        end

        outputTable = makeTable('SSN', SSN', 'Subsession', Sess', 'Trial', Trial', 'Lap', Lap', 'ZoneIn', ZoneIn', 'Pellets', N', 'Delay', ZD', 'EnteringTime', ZIT', 'ExitingTime', ZOT', 'TimeInZone', TIZ', 'Stay1Skip0', StayGo');
        idEx = false(size(outputTable,1),1);
        for iR=2:size(outputTable,1)
            if isnan(outputTable{iR,2})
                idEx(iR) = true;
            end
        end
        outputTable = outputTable(~idEx,:);
        cell2csv([sd(1).ExpKeys.SSN '-Behav.csv'], outputTable, ', ')
    end
    popdir;
end