function [data,fh] = compare_RR_velocity(varargin)
%
%
%
%

filter = 'RR-*.mat'; % filter for RR-*.mat workspaces.
IVx = 'ZoneProbability'; % variable with x-axis variable
IVr = 'nPelletsPerDrop'; % variable incrementing along rows.
ZT = 'EnteringZoneTime'; % variable indicating when a zone was entered.
ZI = 'ZoneIn'; % variable incrementing along columns indicating which zone was entered.
ZF = 10; % variable indicating which zones are "at feeder" and which are not.
timescale = 1e-6; % time scale of entering times relative to position tsds.

fn = FindFiles(filter);
assert(~isempty(fn),'No RR workspace found.')

process_varargin(varargin);
clf

% SSN SubSESS ZoneIn nPelletsPerDrop ZoneProbability Entry v

DATA = nan(1,7);
SSN = 0;
SubSESS = 1;
lastPath = '';
for f = 1 : length(fn)
    filename = fn{f};
    pathname = fileparts(filename);
    
    if ~strcmp(pathname,lastPath)
        % new path, new SSN.
        SSN = SSN+1;
        SubSESS = 1;
    else
        SubSESS = SubSESS+1;
    end
    
    pushdir(pathname);
    
    SessionData = load(fn{f});
    zipfn = FindFiles('*.zip','CheckSubdirs',0);
    if ~isempty(zipfn)
        for z = 1 : length(zipfn)
            unzip(zipfn{z});
        end
    end
    nvtfn = FindFiles('*.nvt','CheckSubdirs',0);
    if ~isempty(nvtfn)
        [x,y] = LoadVT_lumrg(nvtfn{1});
    end
    if ~isempty(zipfn)
        for n = 1 : length(nvtfn)
            delete(nvtfn{n});
        end
    end
    t = x.range;
    t = sort(t);
    d = x.data;
    x = tsd(t,d);
    t = y.range;
    t = sort(t);
    d = y.data;
    y = tsd(t,d);
    dx = dxdt(x);
    dy = dxdt(y);
    v = sqrt(dx.data.^2+dy.data.^2);
    v = tsd(dx.range,v(:));
    
    IVlist = eval(['SessionData.' IVx ';']);
    EnterTimes = eval(['SessionData.' ZT ';']);
    EnterTimes = EnterTimes*timescale;
    ZoneIn = eval(['SessionData.' ZI ';']);
    ZoneProbability = eval(['SessionData.' IVx ';']);
    nPelletsPerDrop = eval(['SessionData.' IVr ';']);
    if numel(nPelletsPerDrop)<length(ZoneProbability)
        nP = nPelletsPerDrop;
        clear nPelletsPerDrop
        for z = 1 : length(ZoneIn)
            if ZoneIn(z)<ZF
                nPelletsPerDrop(z) = nP(ZoneIn(z));
            else
                nPelletsPerDrop(z) = nP(ZoneIn(z-1));
            end
        end
    end
    
    InFeeder = ZoneIn>=ZF;
    InZone = ZoneIn<ZF;
    Visits = 1:length(ZoneIn);
    
    for c = 1 : length(ZoneIn-1)
        if InZone(c)
            % Every time he's in zone,
            %   calculate when that happened
            %   find when he left
            %   find where he went (next zone)
            %   restrict velocity estimate to zone entry and zone exit
            t0 = EnterTimes(c);
            visitNumber = Visits(c);
            
            if visitNumber<max(Visits)
                c1 = Visits(c+1);

                if InFeeder(c1)
                    entry=true;
                else
                    entry=false;
                end

                t1 = EnterTimes(c1);

                v0 = v.restrict(t0,t1);
                s = nanmean(v0.data);
                pellets = nPelletsPerDrop(c);
                prob = ZoneProbability(c);
                DATA = [DATA; 
                    SSN SubSESS ZoneIn(c) pellets prob double(entry) s];
            end
        end
    end
    
    lastPath = pathname;
    
    popdir;
end
DATA = DATA(2:end,:);

uniqueIVr = unique(DATA(:,4));
nr = length(uniqueIVr);
nr = nr+1;
uniqueIVx = unique(DATA(:,5));
nx = length(uniqueIVx);
uniqueIVc = unique(DATA(:,3));
nc = length(uniqueIVc);
nc = nc+1;

xDiff = median(diff(uniqueIVx));
xlim = [min(uniqueIVx)-xDiff/2 max(uniqueIVx)+xDiff/2];


% Create a series of subplots with nr rows and nc columns.

for r = 1 : nr-1
    nPellets = uniqueIVr(r);
    idR = DATA(:,4)==nPellets;
    
    for c = 1 :  nc-1
        zone = uniqueIVc(c);
        idC = DATA(:,3)==zone;
        
        idRC = idR&idC;
        
        p = (r-1)*nc+c;
        subplot(nr,nc,p)
            % title
            th=title(sprintf('Zone %d\n%s=%d',zone,IVr,nPellets));
            set(th,'fontsize',8)
        if r==nr
            % x-axis label
            xlabel(sprintf('%s',IVx));
        end
        if c==1
            % y-axis label
            ylabel(sprintf('Velocity vector\n(Exit \\leftarrow \\rightarrow Enter)'))
        end
        panelData = DATA(idRC,:);
        [mEnter,semEnter,mExit,semExit,mDiff,semDiff] = panel_data(panelData);
        hold on
        
        eh=errorbar(uniqueIVx,mEnter,semEnter);
        set(eh,'linestyle','none')
        set(eh,'color','g')
        eh(2)=errorbar(uniqueIVx,-mExit,semExit);
        set(eh(2),'linestyle','none')
        set(eh(2),'color','r')
        eh(3)=errorbar(uniqueIVx,mDiff,semDiff);
        set(eh(3),'linestyle','none')
        set(eh(3),'color','k')
        ph=plot(uniqueIVx,mEnter,'gx','markersize',8);
        ph(2)=plot(uniqueIVx,-mExit,'rx','markersize',8);
        ph(3)=plot(uniqueIVx,mDiff,'ko','markersize',10);
        plot(uniqueIVx,mDiff,'k.');
        
        hold off
    end
end
for r = 1 : nr-1
    nPellets = uniqueIVr(r);
    idR = DATA(:,4)==nPellets;

    p = r*nc;
    subplot(nr,nc,p)
    hold on
        % title
        th=title(sprintf('Overall %d %s',nPellets,IVr));
        set(th,'fontsize',8)
        set(th,'fontangle','italic')
    if r==nr
        % x-axis
        xlabel(sprintf('%s',IVx));
    end

    panelData = DATA(idR,:);
    [mEnter,semEnter,mExit,semExit,mDiff,semDiff] = panel_data(panelData);

    eh=errorbar(uniqueIVx,mEnter,semEnter);
    set(eh,'linestyle','none')
    set(eh,'color','g')
    eh(2)=errorbar(uniqueIVx,-mExit,semExit);
    set(eh(2),'linestyle','none')
    set(eh(2),'color','r')
    eh(3)=errorbar(uniqueIVx,mDiff,semDiff);
    set(eh(3),'linestyle','none')
    set(eh(3),'color','k')
    ph=plot(uniqueIVx,mEnter,'gx','markersize',8);
    ph(2)=plot(uniqueIVx,-mExit,'rx','markersize',8);
    ph(3)=plot(uniqueIVx,mDiff,'ko','markersize',10);
    plot(uniqueIVx,mDiff,'k.');

    hold off
end
for c = 1 : nc-1
    zone = uniqueIVc(c);
    idC = DATA(:,3)==zone;
    
    p = (nr-1)*nc+c;
    subplot(nr,nc,p)
    hold on
    th=title(sprintf('Overall %s=%d',ZI,zone));
    set(th,'fontangle','italic')
    set(th,'fontsize',8)
    xlabel(sprintf('%s',IVx));
    if c==1
        % y-axis label
        ylabel(sprintf('Velocity vector\n(Exit \\leftarrow \\rightarrow Enter)'))
    end
    panelData = DATA(idC,:);
    [mEnter,semEnter,mExit,semExit,mDiff] = panel_data(panelData);
    hold on

    eh=errorbar(uniqueIVx,mEnter,semEnter);
    set(eh,'linestyle','none')
    set(eh,'color','g')
    eh(2)=errorbar(uniqueIVx,-mExit,semExit);
    set(eh(2),'linestyle','none')
    set(eh(2),'color','r')
    eh(3)=errorbar(uniqueIVx,mDiff,semDiff);
    set(eh(3),'linestyle','none')
    set(eh(3),'color','k')
    ph=plot(uniqueIVx,mEnter,'gx','markersize',8);
    ph(2)=plot(uniqueIVx,-mExit,'rx','markersize',8);
    ph(3)=plot(uniqueIVx,mDiff,'ko','markersize',10);
    plot(uniqueIVx,mDiff,'k.');
    
    hold off
end

subplot(nr,nc,nr*nc)
hold on
th=title('Overall');
set(th,'fontsize',8)
set(th,'fontangle','italic')
xlabel(sprintf('%s',IVx));
panelData = DATA;
[mEnter,semEnter,mExit,semExit,mDiff] = panel_data(panelData);
eh=errorbar(uniqueIVx,mEnter,semEnter);
set(eh,'linestyle','none')
set(eh,'color','g')
eh(2)=errorbar(uniqueIVx,-mExit,semExit);
set(eh(2),'linestyle','none')
set(eh(2),'color','r')
eh(3)=errorbar(uniqueIVx,mDiff,semDiff);
set(eh(3),'linestyle','none')
set(eh(3),'color','k')

ph=plot(uniqueIVx,mEnter,'gx','markersize',8);
ph(2)=plot(uniqueIVx,-mExit,'rx','markersize',8);
ph(3)=plot(uniqueIVx,mDiff,'ko','markersize',10);
plot(uniqueIVx,mDiff,'k.');
legendStr{1} = 'Entry';
legendStr{2} = 'Exit';
legendStr{3} = 'Diff';
lh=legend(ph,legendStr);
set(lh,'location','southeast')
set(lh,'fontsize',8)
set(lh,'color','none')
set(lh,'edgecolor','w')
hold off
ymax = 0;
for p = 1 : nr*nc
    subplot(nr,nc,p)
    ylim=get(gca,'ylim');
    ymax = max(max(abs(ylim)),ymax);
end
for p = 1 : nr*nc
    subplot(nr,nc,p)
    set(gca,'ylim',[-ymax ymax]);
    set(gca,'xlim',xlim);
    hold on
    plot(xlim,[0 0],':','color',[0.8 0.8 0.8],'linewidth',1)
    hold off
end


data.HEADER = {'SSN' 'SubSESS' ZI IVr IVx 'Entered Arm' 'Velocity'};
data.DATA = DATA;

if nargout>1
    fh = gcf;
end

function [mEnter,semEnter,mExit,semExit,mDiff,semDiff] = panel_data(panelData)

uniqueX = unique(panelData(:,5));
mEnter = nan(length(uniqueX),1);
semEnter = nan(length(uniqueX),1);
mExit = nan(length(uniqueX),1);
semExit = nan(length(uniqueX),1);
mDiff = nan(length(uniqueX),1);
semDiff = nan(length(uniqueX),1);
for xi = 1 : length(uniqueX)
    idx = panelData(:,5)==uniqueX(xi);
    ptData = panelData(idx,:);

    idEnter = ptData(:,6)==1;
    idExit = ptData(:,6)==0;
    vEnter = ptData(idEnter,7);
    vExit = ptData(idExit,7);
    
    mEnter(xi,1) = nanmean(vEnter);
    semEnter(xi,1) = nanstd(vEnter)/sqrt(numel(vEnter(~isnan(vEnter))));
    mExit(xi,1) = nanmean(vExit);
    semExit(xi,1) = nanstd(vExit)/sqrt(numel(vExit(~isnan(vExit))));
    
    mDiff(xi,1) = nanmean([vEnter;-vExit]);
    semDiff(xi,1) = nanstd([vEnter;-vExit])/sqrt(numel([vEnter(~isnan(vEnter));-vExit(~isnan(vExit))]));
end