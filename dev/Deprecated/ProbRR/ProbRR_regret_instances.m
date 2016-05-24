function fh = ProbRR_regret_instances(VelocityTab,varargin)

filter = 'RR-*.mat';
fn = FindFiles(filter);
ZF = 10;
conversion = 1e-6;
process_varargin(varargin);

clf

% For each zone/pellet, obtain threshold probability.
Thresholds = VelocityTab.Thresholds;

DATA = nan((size(Thresholds,1)-1)*(size(Thresholds,2)-1),3);
k = 1;
for r = 1 : size(Thresholds,1)-1
    for c = 1 : size(Thresholds,2)-1
        % each row is a pellet number.
        n = Thresholds(r,c).IVr;
        z = Thresholds(r,c).IVc;
        
        theta = Thresholds(r,c).Theta;
        DATA(k,:) = [n z theta];
        k = k+1;
    end
end

for f = 1 : length(fn)
    filename = fn{f};
    pathname = fileparts(filename);
    
    pushdir(pathname);
    nvt = FindFiles('*.nvt');
    zipped = false;
    if isempty(nvt)
        zipfile = FindFiles('*VT1*.zip');
        unzip(zipfile{1})
        zipped = true;
        nvt = FindFiles('*.nvt');
    end
    [x,y] = LoadVT_lumrg(nvt{1});
    SessionData = load(filename);
    t = x.range;
    t = sort(t);
    d = x.data;
    x = tsd(t,d);
    t = y.range;
    t = sort(t);
    d = y.data;
    y = tsd(t,d);
    try
        thresh = nan(length(SessionData.ZoneIn),1);
        High = false(length(SessionData.ZoneIn),1);
        Low = false(length(SessionData.ZoneIn),1);
        Entry = false(length(SessionData.ZoneIn),1);
        Skip = false(length(SessionData.ZoneIn),1);
        RowID = nan(length(SessionData.ZoneIn),1);
        NextZone = nan(length(SessionData.ZoneIn),1);
        k = 1;
        for visit = 1 : length(SessionData.ZoneIn)-2
            z = SessionData.ZoneIn(visit);
            if z<ZF
                % Enters a zone.
                prob = SessionData.ZoneProbability(visit);
                n = SessionData.nPelletsPerDrop(z);

                id = DATA(:,1)==n & DATA(:,2)==z;

                thresh(k) = DATA(id,3);
                High(k) = prob>thresh(k);
                Low(k) = prob<thresh(k);
                RowID(k) = visit;
                if SessionData.ZoneIn(visit+1)>ZF
                    % Entry
                    Entry(k) = true;
                    NextZone(k) = visit+2;
                else
                    Skip(k) = true;
                    NextZone(k) = visit+1;
                end
                k = k+1;
            end
        end
        idnan = isnan(thresh);
        thresh(idnan) = [];
        High(idnan) = [];
        Low(idnan) = [];
        Entry(idnan) = [];
        Skip(idnan) = [];
        RowID(idnan) = [];

        % We now have a list of:
        % threshold probability for the visit,
        % probability of visit is greater than threshold,
        % probability of visit is less than threshold,
        % feeder arm was entered,
        % feeder arm was skipped.

        % We want to isolate all times the following are true:
        % above threshold
        % followed by below threshold
        % feeder arm skipped
        idRegret = High(1:end-1)&Low(2:end)&Skip(1:end-1);
        % and the following are true:
        % above threshold
        % followed by below threshold
        % feeder arm entered
        idControl = High(1:end-1)&Low(2:end)&Entry(1:end-1);

        RegretVisits = NextZone(idRegret);
        ControlVisits = NextZone(idControl);

        cmap = jet(length(RegretVisits));
        for v = 1 : length(RegretVisits)
            t0 = SessionData.EnteringZoneTime(RegretVisits(v))*conversion;
            t1 = SessionData.EnteringZoneTime(RegretVisits(v)+1)*conversion;
            x0 = x.restrict(t0,t1);
            y0 = y.restrict(t0,t1);
            subplot(1,2,1)
            title(sprintf('Regret\n(High Prob Skipped\\rightarrowLow Prob)'))
            hold on
            plot(x0.data,y0.data,'-','color',cmap(v,:));
            set(gca,'ylim',[0 480])
            set(gca,'xlim',[0 720])
            set(gca,'xtick',[])
            set(gca,'ytick',[])
            axis square
            hold off
        end
        cmap = jet(length(ControlVisits));
        for v = 1 : length(ControlVisits)
            t0 = SessionData.EnteringZoneTime(ControlVisits(v))*conversion;
            t1 = SessionData.EnteringZoneTime(ControlVisits(v)+1)*conversion;
            x0 = x.restrict(t0,t1);
            y0 = y.restrict(t0,t1);
            subplot(1,2,2)
            title(sprintf('Control\n(High Prob Entered\\rightarrowLow Prob)'))
            hold on
            plot(x0.data,y0.data,'-','color',cmap(v,:));
            set(gca,'ylim',[0 480])
            set(gca,'xlim',[0 720])
            set(gca,'xtick',[])
            set(gca,'ytick',[])
            axis square
            hold off
        end
    end
    popdir;
end
fh = gcf;