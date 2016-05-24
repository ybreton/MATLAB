function Rs = RRreinfRate(sd,varargin)
%
%
%
%
aversion = 0;
process_varargin(varargin);

sd.stayGo = RRGetStaygo(sd);

zoneIn = sd.ZoneIn;
nPellets = sd.nPellets;
delays = sd.ZoneDelay;
stayGo = sd.stayGo;
tIn = sd.EnteringZoneTime;
uniqueZones = unique(zoneIn);
nT = length(sd.EnteringZoneTime)-1;

stays = nan(length(uniqueZones),max(delays(:)));
skips = stays;
nP = stays;
D = stays;
for iZ=1:length(uniqueZones)
    idZ = zoneIn==uniqueZones(iZ);
    uniqueDelays = unique(delays(idZ));
    for iD=uniqueDelays(:)'
        idD = delays==iD;
        idZD = idZ&idD;
        stays(iZ,iD) = nansum(double(stayGo(idZD)==1));
        skips(iZ,iD) = nansum(double(stayGo(idZD)==0));
        nP(iZ,iD) = nanmean(nPellets(idZD));
        D(iZ,iD) = iD;
    end
end
Pwait = stays./(stays+skips);


% For all skips, how long does it take him to get to the next zone?
iSkip = find(stayGo==0);
iSkip(iSkip>nT) = [];
skipEntry = tIn(iSkip);
skipExit = tIn(iSkip+1);
skipTravel = skipExit-skipEntry;
medianSkipTravel = nanmedian(skipTravel);

iStay = find(stayGo==1);
iStay(iStay>nT) = [];
stayDelay = delays(iStay);
stayEntry = tIn(iStay);
stayExit = tIn(iStay+1);
stayTotal = stayExit-stayEntry;
stayTravel = stayTotal-stayDelay;
medianStayTravel = nanmedian(stayTravel);

A = repmat(aversion,size(Pwait));
S = repmat(medianSkipTravel,size(Pwait));
N = (Pwait(:)'*nP(:)+(1-Pwait(:)')*A(:));
T = (1+Pwait(:)'*(D(:)+medianStayTravel)+(1-Pwait(:)')*S(:));
R = N/T;