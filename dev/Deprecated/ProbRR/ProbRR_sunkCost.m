function fh = ProbRR_sunkCost(VelocityTab,varargin)

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
LowList = [];
EList = [];
SList = [];
RunList = [];
RList = [];

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
    Rew = ZoneRewarded(SessionData.FireFeeder,SessionData.ZoneIn,'ZF',ZF);
    thresh = nan(length(SessionData.ZoneIn),1);
    High = false(length(SessionData.ZoneIn),1);
    Low = false(length(SessionData.ZoneIn),1);
    Entry = false(length(SessionData.ZoneIn),1);
    Skip = false(length(SessionData.ZoneIn),1);
    RowID = nan(length(SessionData.ZoneIn),1);
    NextZone = nan(length(SessionData.ZoneIn),1);
    Rewarded = nan(length(SessionData.ZoneIn),1);
    k = 1;
    for visit = 1 : length(SessionData.ZoneIn)-2
        z = SessionData.ZoneIn(visit);
        if z<ZF
            % Enters a zone.
            prob = SessionData.ZoneProbability(visit);
            n = SessionData.nPelletsPerDrop(z);
            Rewarded(k) = Rew(visit);
            
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
    Rewarded(idnan) = [];
    RowID(idnan) = [];
    
    n = 0;
    run = nan(length(Low),1);
    for k = 2 : length(Low)
        if Low(k)&Low(k-1)&~Rewarded(k-1)&Entry(k-1)
            n = n+1;
            run(k) = n;
        else
            n = 0;
        end
        if Low(k)&~Low(k-1)
            run(k) = n;
        end
    end
    LowList = [LowList;Low(:)];
    EList = [EList;Entry(:)];
    RList = [RList;Rewarded(:)];
    
    RunList = [RunList;run(:)];
    end
    
    popdir;
    
end
Low = LowList;
Entry = EList;
run = RunList;
Rewarded = RList;

% for each number of entries into unrewarded lows,
uniqueRuns = unique(run(~isnan(run)));
for xi = 1:length(uniqueRuns)
    id = run == uniqueRuns(xi);
    % Entries
    E(xi) = sum(double(Entry(id)&Low(id)));
    S(xi) = sum(double(~Entry(id)&Low(id)));
end
[P,Plo,Phi] = binocis(E,S,1,0.05);
Prand = sum(double(Low(~isnan(run))&Entry(~isnan(run)))/sum(double(Low(~isnan(run)))));
hold on
ph=plot(uniqueRuns,P,'r-','linewidth',2);
plot(uniqueRuns,P,'ro')
eh=errorbar(uniqueRuns,P,P-Plo,Phi-P);
set(eh,'linestyle','none')
set(eh,'color','r')
ph(2)=plot([min(uniqueRuns) max(uniqueRuns)],[Prand Prand],'k-','linewidth',1);
legendStr{1} = sprintf('Following a run of n low probabilities\n(\\pm 95%% CI)');
legendStr{2} = sprintf('Overall');
lh=legend(ph,legendStr);
set(lh,'location','northeastoutside')
xlabel('Number of unrewarded below-threshold probabilities already encountered')
ylabel('P[entry] to a low-probability feeder arm')
set(gca,'xlim',[-0.05 max(uniqueRuns)+0.05])
set(gca,'xtick',[0:max(uniqueRuns)])
hold off

fh = gcf;