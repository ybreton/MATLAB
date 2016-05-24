function RatFPTSummary = summarize_FPT_aging(varargin)

s=dir;
d=arrayfun(@(x) isdir(x.name)&~strcmp(x.name,'.')&~strcmp(x.name,'..'),s);
fd=s(d);
rats = cell(0,1);
for id = 1 : length(fd)
    name = fd(id).name;
    dashes = regexpi(name,'-');
    if isempty(dashes)
        multiplerats = true;
        r = name(1:end);
    else
        multiplerats = false;
        r = name(1:min(dashes)-1);
    end
    rats{length(rats)+1,1} = r;
    rats = unique(rats);
end
process_varargin(varargin);

for ratnum = 1 : length(rats)
    ratname = rats{ratnum};
    fprintf('%s\n',ratname);
    if multiplerats
        pushdir(ratname);
    end

    fn = FindFiles([ratname '*-sd.mat']);
%     HEADER = {'SESSION NUMBER' 'PELLET RATIO' 'STARTING DELAY' 'ZONE IN' 'DELAY ZONE' 'CHOICE' 'DELAY' 'ENTER CP TIME' 'EXIT CP TIME' 'FEEDER TIME' 'LOG IdPHI'};
    HEADER = {'SESSION NUMBER' 'PELLET RATIO' 'STARTING DELAY' 'ZONE IN' 'DELAY ZONE' 'CHOICE' 'DELAY'};
    DATA = [];
    SSN = {};
    for f = 1 : length(fn)
        load(fn{f})
        sd = kludge_zone_times_FPT(sd);
        nL = min(length(sd.EnteringCPTime),length(sd.FeederTimes));
        sd = zIdPhi(sd,'tstart',sd.EnteringCPTime(1:nL),'tend',sd.FeederTimes(1:nL));

        ZoneIn = sd.ZoneIn;
        ZoneDelay = sd.ZoneDelay;
        DelayZone = sd.DelayZone;
        InDelay = ZoneIn == DelayZone;
%         EnterCP = sd.EnteringCPTime;
%         ExitCP = sd.ExitingCPTime;
%         Feeder = sd.FeederTimes;
%         LogIdPhi = log10(sd.IdPhi);

        PR = max(sd.World.nPleft,sd.World.nPright)/min(sd.World.nPleft,sd.World.nPright);
        % contingency
        % ZoneIn == 3 : L
        % ZoneIn == 4 : R
        
        laps = 1:length(ZoneIn);
        firstDelay = min(laps(InDelay));
        DelaySideDelay = nan(length(ZoneIn),1);
        
        StartingDelay = ZoneDelay(firstDelay);
        if isempty(StartingDelay)
            StartingDelay = nan;
        end
        
        DelaySideDelay(firstDelay) = ZoneDelay(firstDelay);
        LastZone = ZoneIn(firstDelay);
        for lap = firstDelay+1 : length(ZoneIn)
            CurZone = ZoneIn(lap);
            if InDelay(lap-1)
                DelaySideDelay(lap) = max(1,DelaySideDelay(lap-1)+1);
            else
                DelaySideDelay(lap) = max(1,DelaySideDelay(lap-1)-1);
            end
            LastZone = CurZone;
        end

%         DATA = [DATA;
%             ones(length(InDelay),1)*f ones(length(InDelay),1)*PR ones(length(InDelay),1)*DelaySideDelay(firstDelay) ZoneIn(:) ones(length(InDelay),1)*DelayZone InDelay(:) DelaySideDelay(:) EnterCP(:) ExitCP(:) Feeder(:) LogIdPhi(:)];
        DATA = [DATA;
            ones(length(InDelay),1)*f ones(length(InDelay),1)*PR ones(length(InDelay),1)*StartingDelay ZoneIn(:) ones(length(InDelay),1)*DelayZone InDelay(:) DelaySideDelay(:)];
        SSN = [SSN;
            repmat(fn(f),length(InDelay),1)];
    end

    RatFPTSummary.RatName = ratname;
    RatFPTSummary.HEADER.Col = HEADER;
    RatFPTSummary.HEADER.Row = SSN;
    RatFPTSummary.DATA = DATA;
    
    if multiplerats
        save('RatFPTSummary.mat','RatFPTSummary')
        popdir;
    end
    if ~multiplerats & nargout==0
        save('RatFPTSummary.mat','RatFPTSummary')
    end
end