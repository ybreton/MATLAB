function f = find_regret_instance(varargin)
%
%
%
%

SSN = pwd;
delim = regexpi(SSN,'\');
SSN = SSN(max(delim)+1:end);
delim = regexpi(SSN,'-');
SSN = SSN(min(delim)+1:end);
process_varargin(varargin);

fn = FindFiles(['*' SSN '*.mat']);
fd = cell(length(fn),1);
for iF = 1 : length(fn);
    fd{iF} = fileparts(fn{iF});
end

[fn,idUnq] = unique(fn);
fd = fd(idUnq);

cmap = [255 0 0;
        255 204 51;
        0 0 0;
        150 75 0];
cmap = cmap./255;
cmap2 = cmap;
cmap2(3,:) = [1 1 1];
f = [];
for iF = 1 : length(fn)
    pushdir(fd{iF});
    sd(iF) = load(fn{iF});
    visits = 1:length(sd(iF).ZoneIn);
    nvtfile = FindFile('VT1.nvt','CheckSubdirs',0);
    if isempty(nvtfile)
        zipfile = FindFile('VT1.zip','CheckSubdirs',0);
        unzip(zipfile);
    end
    nvtfile = FindFile('VT1.nvt','CheckSubdirs',0);
    [x,y] = LoadVT_lumrg(nvtfile);
    clf
    b = nan(2,4);
    thresh = nan(1,4);
    sp = [6 2 1 5];
    for iZ = 1 : 4
        idZone = sd(iF).ZoneIn==iZ;
        ExitedZone = sd(iF).ExitZoneTime(idZone(1:length(sd(iF).ExitZoneTime)));
        ZoneVisits = visits(idZone);
        D = sd(iF).ZoneDelay(idZone);
        D = D(:);
        C = ismember(ExitedZone,sd(iF).FeederTimes);
        C = C(:);
        n = min(length(D),length(C));
        D = D(1:n);
        C = C(1:n);
        ZoneVisits = ZoneVisits(1:n);
        
        b(:,iZ) = glmfit(D,C,'binomial','link','logit');
        thresh(iZ) = -b(1,iZ)./b(2,iZ);
        
        subplot(2,4,sp(iZ))
        cla
        title(sprintf('Zone %d\n\\theta=%.1f',iZ,thresh(iZ)));
        hold on
        plot(unique(D),glmval(b(:,iZ),unique(D),'logit'),'-','color',cmap(iZ,:));
        ph=plot_grouped_Y(D,C,'dist','binomial');
        set(ph,'markerfacecolor',cmap(iZ,:));
        xlabel('Delay')
        ylabel('P[Entry]')
        hold off
        
    end
    
    z(1,:) = [720 0];
    z(2,:) = [720 480];
    z(3,:) = [0 480];
    z(4,:) = [0 0];
    vAlign = {'top' 'bottom' 'bottom' 'top'};
    hAlign = {'right' 'right' 'left' 'left'};
    lastZ = [4 1 2 3];
    
    EnteredZone = sd(iF).EnteringZoneTime;
    ExitedZone = sd(iF).ExitZoneTime;
    D = sd(iF).ZoneDelay;
    D = D(:);
    C = ismember(ExitedZone,sd(iF).FeederTimes);
    C = C(:);
    n = min(length(D),length(C));
    D = D(1:n);
    C = C(1:n);
    
    for iZ = 1 : 4
        iLast = lastZ(iZ);
        idZone = sd(iF).ZoneIn(:)==iZ;
        idZone = idZone(1:n);
        
        curZone = idZone(2:end);
        curAbove = D(2:end)>thresh(iZ);
        lastSkipped = ~C(1:end-1);
        lastBelow = D(1:end-1)<thresh(iZ);
        
        regret = false(1,n);
        regret(2:end) = lastSkipped&lastBelow & curZone&curAbove;%skip lo, then got high.
        rt = find(regret);
        RegretEntry = EnteredZone(regret)/1e6-10;
        RegretExit = EnteredZone(regret)/1e6+10;
        RegretDelay = D(rt);
        PrevDelay = D(rt-1);
        subplot(1,2,2);
        fprintf('\n');
        for instance = 1 : length(RegretEntry)
            cla
            hold on
            set(gca,'xcolor','w')
            set(gca,'ycolor','w')
            x0 = x.restrict(RegretEntry(instance),RegretExit(instance));
            y0 = y.restrict(RegretEntry(instance),RegretExit(instance));
            plot3(x.data,y.data,zeros(length(x.data),1),'.k');
            plot3(x0.data,y0.data,x0.range,'o','markeredgecolor',cmap2(iZ,:),'markerfacecolor',cmap2(iZ,:));
            zStr = sprintf('Regret Zone %d,\nD=%.1f (\\theta=%.1f)',iZ,RegretDelay(instance),thresh(iZ));
            lastStr = sprintf('Last Zone %d,\nD=%.1f (\\theta=%.1f)',iLast,PrevDelay(instance),thresh(iLast));
            th=text(z(iZ,1),z(iZ,2),iZ,zStr);
            set(th,'verticalalignment',vAlign{iZ})
            set(th,'horizontalalignment',hAlign{iZ})
            th=text(z(iLast,1),z(iLast,2),iLast,lastStr);
            set(th,'verticalalignment',vAlign{iLast})
            set(th,'horizontalalignment',hAlign{iLast})
            set(gca,'xlim',[0 720])
            set(gca,'ylim',[0 480])
            fprintf('Regret instance %d of %d\n',instance, length(RegretEntry));
            view(2);
            set(gca,'xtick',[])
            set(gca,'ytick',[])
            hold off
            pause;
        end
        fprintf('\n');
        f = [f rt];
    end
    popdir;
end

