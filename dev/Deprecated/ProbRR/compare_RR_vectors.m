function [data,fh] = compare_RR_vectors(varargin)
% compares velocity vectors in RR task as projected onto the line toward
% the feeder and toward the next zone.
%
% [data,fh] = compare_RR_vectors(varargin)
% data is an n x 9 table with columns
%           SSN SubSESS ZI IVr IVx Entry Vin Vout Vdiff
% fh is a handle to the figure produced
% 
% input arguments:
% filter        filter for workspaces to load. 
%               (Default 'RR-*.mat'.)
% fn            cell array of workspace filenames. 
%               (Default is all in current directory and children.)
% IVx           x-axis variable.
%               (Default 'ZoneProbability'.)
% IVr           row variable. 
%               (Default 'nPelletsPerDrop'.)
% ZI            column variable. 
%               (Default 'ZoneIn'.)
% 
% ZT                variable with zone entry times. 
%                   (Default 'EnteringZoneTime'.)
% timescale         conversion scalar of ZT times to nvt times. 
%                   (Default 1e-6.)
% FeederZoneVar     variable with feeder coordinates. 
%                   (Default 'F'.)
% C                 cell array of choice coordinates.
%                   (Default {[398 135],[393 301],[214 291],[222 134]})
% Rc                radii of feeder and choice points. 
%                   (Default [40 40 40 40])
% plotEntries       logical for plotting feeder velocities 
%                   (Default false)
% plotSkips         logical for plotting next zone velocities 
%                   (Default false)
% plotMean          logical for plotting difference in velocities
%                   (Default true)
% Thresh            logical for identifying the threshold IVx at each
%                   combination of IVr and ZI, each marginal IVr, each
%                   marginal ZI, and overall marginal.
%                   (Default true)
%
% ZF                scalar indicator for at-feeder zones. (Default 10.)
%

filter = 'RR-*.mat'; % filter for RR-*.mat workspaces.
IVx = 'ZoneProbability'; % variable with x-axis variable
IVr = 'nPelletsPerDrop'; % variable incrementing along rows.
ZT = 'EnteringZoneTime'; % variable indicating when a zone was entered.
ZI = 'ZoneIn'; % variable incrementing along columns indicating which zone was entered.
ZF = 10; % variable indicating which zones are "at feeder" and which are not.
FeederZoneVar = 'F'; % variable indicating feeder positions.
debugFlag = false; % plot visit-by-visit position/velocity.
C = {[398 135],[393 301],[214 291],[222 134]}; % location of choice point for each feeder.
Rc = [40 40 40 40]; % radius of choice point.

plotEntries = false; % plot average speed toward feeder
plotSkips = false; % plot average speed toward next zone
plotMean = true; % plot average difference in feeder velocity to next zone velocity
Thresh = true; % calculate the threshold

timescale = 1e-6; % time scale of entering times relative to position tsds.

fn = FindFiles(filter);
assert(~isempty(fn),'No RR workspace found.')

process_varargin(varargin);
if all([~plotEntries;~plotSkips;~plotMean]) & nargout<2
    producePlot = false;
else
    producePlot = true;
    clf
end

% SSN SubSESS ZoneIn nPelletsPerDrop ZoneProbability Entry vIn vOut vDiff

DATA = nan(1,9);
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
    V = tsd(dx.range,[dx.data dy.data]);
    P = tsd(x.range,[x.data y.data]);
    try
        IVlist = eval(['SessionData.' IVx ';']);
        EnterTimes = eval(['SessionData.' ZT ';']);
        EnterTimes = EnterTimes*timescale;
        ZoneIn = eval(['SessionData.' ZI ';']);
        ZoneProbability = eval(['SessionData.' IVx ';']);
        nPelletsPerDrop = eval(['SessionData.' IVr ';']);
        F = eval(['SessionData.' FeederZoneVar ';']);
        
        % Distance to each feeder and choice zone.
        P0 = P.data;
        Px = P0(:,1);
        Py = P0(:,2);
        Dc = nan(length(Px),length(C));
        Df = nan(length(Px),length(F));
        for z = 1 : length(C)
            Cz = C{z};
            Fz = F{z};
            Dc(:,z) = sqrt((Px-Cz(1)).^2+(Py-Cz(2)).^2);
            Df(:,z) = sqrt((Px-Fz(1)).^2+(Py-Fz(2)).^2);
        end
        InCP = Dc <= repmat(Rc(:)',size(Dc,1),1);
        InF = Df <= repmat(Rc(:)',size(Df,1),1);
        ChoicePointTSD = tsd(P.range,InCP);
        FeederPointTSD = tsd(P.range,InF);

        % Find projection lines and unit projection vectors.
        U = nan(2,length(F));
        W = nan(2,length(F));
        for n0 = 1 : length(F)
            n1 = mod(n0+1,length(F));
            if n1==0
                n1 = length(F);
            end
            f0xy = F{n0};
            z0xy = C{n0};
            z1xy = C{n1};
            Lf = f0xy(:)-z0xy(:); % Projection line
            Lx = z1xy(:)-z0xy(:);
            U(:,n0) = Lf/sqrt(Lf'*Lf); % Unit projection vector
            W(:,n0) = Lx/sqrt(Lx'*Lx);
        end
        if numel(nPelletsPerDrop)<length(unique(ZoneIn))
            nPelletsPerDrop = repmat(nPelletsPerDrop(:)',1,length(unique(ZoneIn(ZoneIn<ZF))));
            nPelletsPerDrop = nPelletsPerDrop(1:length(unique(ZoneIn(ZoneIn<ZF))));
        end
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

        for c = 1 : length(ZoneIn)-1
            if InZone(c)
                curZone = ZoneIn(c);
                nextZone = mod(ZoneIn(c)+1,4);
                if nextZone==0
                    nextZone=4;
                end
                % Every time he's in zone,
                %   calculate when that happened
                %   find when he left
                %   find where he went (next zone)
                %   restrict velocity estimate to zone entry and zone exit
                t0 = EnterTimes(c);
                P0 = P.restrict(t0,max(P.range));
                Feeder0 = FeederPointTSD.restrict(t0,max(P.range));
                Choice0 = ChoicePointTSD.restrict(t0,max(P.range));
                Px = P0.D(:,1);
                Py = P0.D(:,2);
                Txy = P0.range;
                
                t1 = ones(3,1)*max(P.range);
                entry = [true false false];
                
                T = Feeder0.range;
                D = Feeder0.data;
                Tf = T(D(:,curZone));
                if isempty(Tf(Tf>t0))
                    t1(1) = inf;
                else
                    t1(1) = min(Tf(Tf>t0));
                end

                T = Choice0.range;
                D = Choice0.data;
                Ts = T(D(:,nextZone));
                if isempty(Ts(Ts>t0))
                    t1(2) = inf;
                else
                    t1(2) = min(Ts(Ts>t0));
                end
                [t1,id] = min(t1);
                entry = entry(id);

                v0 = V.restrict(t0,t1);
                vt = v0.data';
                vr = v0.range;
                if numel(vr)>1
                    Tdiff = diff(vr)/2;
                    Tdiff = [Tdiff(1);Tdiff(:)];
                else
                    Tdiff = median(diff(V.range));
                end

                P0 = P.restrict(t0,t1);
                Px = P0.D(:,1);
                Py = P0.D(:,2);

                if debugFlag && ZoneIn(c)==1
                    cla
                    axis equal
                    set(gca,'xlim',[0 720])
                    set(gca,'ylim',[0 480])
                    set(gca,'ydir','reverse')
                    set(gca,'xtick',[])
                    set(gca,'ytick',[])
                end

                Vu = nan(2,size(vt,2));
                Vw = nan(2,size(vt,2));
                Nu = nan(1,size(vt,2));
                Nw = nan(1,size(vt,2));
                Pt = nan(2,size(vt,2));
                u = U(:,curZone);
                w = W(:,curZone);
                parfor t = 1 : size(vt,2)
                    % Projection of velocity onto unit vector toward entry,
                    % Projection of velocity onto unit vector toward skip
                    Vu(:,t) = projection_vector(vt(:,t),u);
                    Vw(:,t) = projection_vector(vt(:,t),w);

                    % signed norm of projection onto u, w.
                    Nu(:,t) = dot(vt(:,t),u);
                    Nw(:,t) = dot(vt(:,t),w);
                    if debugFlag
                        tt = vr(t);
                        ti = Tdiff(t);
                        pt = P.restrict(tt-ti,tt+ti);
                        Pt(:,t) = mean(pt.data,1);
                    end
                end

                Se = nanmean(Nu);

                Sx = nanmean(Nw);

                Sd = nanmean(Nu-Nw);

                if debugFlag
                    hold on
                    plot(cp0(1),cp0(2),'ko','markerfacecolor','k','markersize',12)
                    plot(f0(1),f0(2),'go','markerfacecolor','g','markersize',12)
                    plot(cp1(1),cp1(2),'ro','markerfacecolor','r','markersize',12)
                    plot(Px,Py,'k-','linewidth',2)
                    xPlot = Pt(1,1:2:end)';
                    yPlot = Pt(2,1:2:end)';
                    uxPlot = Vu(1,1:2:end)';
                    uyPlot = Vu(2,1:2:end)';
                    wxPlot = Vw(1,1:2:end)';
                    wyPlot = Vw(2,1:2:end)';
                    vxPlot = vt(1,1:2:end)';
                    vyPlot = vt(2,1:2:end)';
                    ph=quiver(xPlot,yPlot,uxPlot,uyPlot);
                    set(ph(1),'color',[0 1 0])
                    ph(2)=quiver(xPlot,yPlot,wxPlot,wyPlot);
                    set(ph(2),'color',[1 0 0])
                    ph(3)=quiver(xPlot,yPlot,vxPlot,vyPlot);
                    set(ph(3),'color',[0 0 1])
                    set(ph(3),'linewidth',0.25)
                    set(ph(3),'linestyle',':')
                    hold off
                    drawnow
                end

                pellets = nPelletsPerDrop(c);
                prob = ZoneProbability(c);
                DATA = [DATA; 
                    SSN SubSESS ZoneIn(c) pellets prob entry Se Sx Sd];
            end
        end
    catch exception
        disp('DEBUG.')
    end
    lastPath = pathname;
    
    popdir;
end
DATA = DATA(2:end,:);

if producePlot
clf
cla
if Thresh
    zonePreds = repmat(DATA(:,3),1,length(unique(DATA(:,3))))==repmat(1:length(unique(DATA(:,3))),size(DATA,1),1);
    xThresh = [zonePreds DATA(:,4) DATA(:,5)];
    
    [xThresh,id] = sortrows(xThresh,[size(xThresh,2)]);
    yThresh = DATA(:,9);
    yThresh = yThresh(id);

    [B,R,rsq] = sigmoid_fit_lss(xThresh,yThresh,false);
    zoneB = B(1:length(unique(DATA(:,3))));
    pelletB = B(end-1);
    probB = B(end);
end

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
            ylabel(sprintf('Velocity vector\n(Toward Exit \\leftarrow \\rightarrow Toward Entry)'))
        end
        panelData = DATA(idRC,:);
        [mEnter,semEnter,mExit,semExit,mDiff,semDiff] = panel_data(panelData);
        hold on
        
        if plotEntries
            eh=errorbar(uniqueIVx,mEnter,semEnter);
            set(eh,'linestyle','none')
            set(eh,'color','g')
        end
        if plotSkips
            eh(2)=errorbar(uniqueIVx,-mExit,semExit);
            set(eh(2),'linestyle','none')
            set(eh(2),'color','r')
        end
        if plotMean
            eh(3)=errorbar(uniqueIVx,mDiff,semDiff);
            set(eh(3),'linestyle','none')
            set(eh(3),'color','k')
        end
        if plotEntries
            ph=plot(uniqueIVx,mEnter,'gx','markersize',8);
        end
        if plotSkips
            ph(2)=plot(uniqueIVx,-mExit,'rx','markersize',8);
        end
        if plotMean
            ph(3)=plot(uniqueIVx,mDiff,'ko','markersize',10);
            plot(uniqueIVx,mDiff,'k.');
        end
        drawnow
        if Thresh
            Thresholds(r,c).b = B;
            Thresholds(r,c).r = R;
            Thresholds(r,c).Rsq = rsq;
            Thresholds(r,c).zoneB = zoneB(c);
            Thresholds(r,c).pelletB = pelletB;
            Thresholds(r,c).probB = probB;
            
            theta = threshold_from_logit(zoneB,pelletB,probB,zone,nPellets);
            
            Thresholds(r,c).Theta = theta;
            Thresholds(r,c).IVr = nPellets;
            Thresholds(r,c).IVc = zone;
            
            zonesPred = zeros(length(uniqueIVx),length(uniqueIVc));
            zonesPred(:,zone) = 1;
            xThresh = [zonesPred ones(length(uniqueIVx),1)*nPellets uniqueIVx(:)];
            
            ph(4)=plot(uniqueIVx(:),scaled_logit(xThresh,B,R,false),'k-','linewidth',2);
            tStr = sprintf('\\theta_{Z_{%d},p_{%d}}=%.3f',zone,nPellets,theta);
            th=text(theta,min(DATA(:,9)),tStr);
            set(th,'verticalalignment','middle')
            set(th,'horizontalalignment','left')
            set(th,'fontangle','italic')
        else
            Thresholds(r,c).b = [];
            Thresholds(r,c).r = [];
            Thresholds(r,c).zoneB = [];
            Thresholds(r,c).pelletB = [];
            Thresholds(r,c).probB = [];
            Thresholds(r,c).Rsq = [];
            Thresholds(r,c).Theta = [];
            Thresholds(r,c).IVr = [];
            Thresholds(r,c).IVc = [];
        end
        
        
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
    
    if plotEntries
        eh=errorbar(uniqueIVx,mEnter,semEnter);
        set(eh,'linestyle','none')
        set(eh,'color','g')
    end
    if plotSkips
        eh(2)=errorbar(uniqueIVx,-mExit,semExit);
        set(eh(2),'linestyle','none')
        set(eh(2),'color','r')
    end
    if plotMean
        eh(3)=errorbar(uniqueIVx,mDiff,semDiff);
        set(eh(3),'linestyle','none')
        set(eh(3),'color','k')
    end
    if plotEntries
        ph=plot(uniqueIVx,mEnter,'gx','markersize',8);
    end
    if plotSkips
        ph(2)=plot(uniqueIVx,-mExit,'rx','markersize',8);
    end
    if plotMean
        ph(3)=plot(uniqueIVx,mDiff,'ko','markersize',10);
        plot(uniqueIVx,mDiff,'k.');
    end
    drawnow
    if Thresh
        Thresholds(r,nc).b = B;
        Thresholds(r,nc).r = R;
        Thresholds(r,nc).Rsq = rsq;
        Thresholds(r,c).zoneB = zoneB(c);
        Thresholds(r,c).pelletB = pelletB;
        Thresholds(r,c).probB = probB;

        theta = threshold_from_logit(zoneB,pelletB,probB,0,nPellets);

        Thresholds(r,nc).Theta = theta;
        Thresholds(r,nc).IVr = nPellets;
        Thresholds(r,nc).IVc = nan;
        zonesPred = repmat(DATA(:,3),1,length(unique(DATA(:,3))))==repmat(1:length(unique(DATA(:,3))),size(DATA,1),1);
        zonesPred = repmat(mean(zonesPred),length(uniqueIVx),1);
        xThresh = [zonesPred ones(length(uniqueIVx),1)*nPellets uniqueIVx(:)];
        ph(4)=plot(uniqueIVx(:),scaled_logit(xThresh,B,R,false),'k-','linewidth',2);
        tStr = sprintf('\\theta_{p_{%d}}=%.3f',nPellets,theta);
        th=text(theta,min(DATA(:,9)),tStr);
        set(th,'verticalalignment','middle')
        set(th,'horizontalalignment','left')
        set(th,'fontangle','italic')
    else
        Thresholds(r,nc).b = [];
        Thresholds(r,nc).r = [];
        Thresholds(r,nc).Rsq = [];
        Thresholds(r,c).zoneB = [];
        Thresholds(r,c).pelletB = [];
        Thresholds(r,c).probB = [];
        Thresholds(r,nc).Theta = [];
        Thresholds(r,nc).IVr = [];
        Thresholds(r,nc).IVc = [];
    end

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
        ylabel(sprintf('Velocity vector\n(Toward Exit \\leftarrow \\rightarrow Toward Entry)'))
    end
    panelData = DATA(idC,:);
    [mEnter,semEnter,mExit,semExit,mDiff,semDiff] = panel_data(panelData);
    hold on

    if plotEntries
        eh=errorbar(uniqueIVx,mEnter,semEnter);
        set(eh,'linestyle','none')
        set(eh,'color','g')
    end
    if plotSkips
        eh(2)=errorbar(uniqueIVx,-mExit,semExit);
        set(eh(2),'linestyle','none')
        set(eh(2),'color','r')
    end
    if plotMean
        eh(3)=errorbar(uniqueIVx,mDiff,semDiff);
        set(eh(3),'linestyle','none')
        set(eh(3),'color','k')
    end
    if plotEntries
        ph=plot(uniqueIVx,mEnter,'gx','markersize',8);
    end
    if plotSkips
        ph(2)=plot(uniqueIVx,-mExit,'rx','markersize',8);
    end
    if plotMean
        ph(3)=plot(uniqueIVx,mDiff,'ko','markersize',10);
        plot(uniqueIVx,mDiff,'k.');
    end
    drawnow
    if Thresh
        Thresholds(nr,c).b = B;
        Thresholds(nr,c).r = R;
        Thresholds(nr,c).Rsq = rsq;
        Thresholds(r,c).zoneB = zoneB(c);
        Thresholds(r,c).pelletB = pelletB;
        Thresholds(r,c).probB = probB;

        theta = threshold_from_logit(zoneB,pelletB,probB,zone,mean(panelData(:,4)));
        Thresholds(nr,c).Theta = theta;
        Thresholds(nr,c).IVr = nan;
        Thresholds(nr,c).IVc = zone;
        
        zonesPred = zeros(length(uniqueIVx),length(uniqueIVc));
        zonesPred(:,zone) = 1;
        xThresh = [zonesPred ones(length(uniqueIVx),1)*mean(panelData(:,4)) uniqueIVx(:)];
        ph(4)=plot(uniqueIVx(:),scaled_logit(xThresh,B,R,false),'k-','linewidth',2);
        tStr = sprintf('\\theta_{Z_{%d}}=%.3f',zone,theta);
        th=text(theta,min(DATA(:,9)),tStr);
        set(th,'verticalalignment','middle')
        set(th,'horizontalalignment','left')
        set(th,'fontangle','italic')
    else
        Thresholds(nr,c).b = [];
        Thresholds(nr,c).r = [];
%         Thresholds(nr,c).bCI = [];
%         Thresholds(nr,c).rCI = [];
        Thresholds(nr,c).Rsq = [];
        Thresholds(r,c).zoneB = [];
        Thresholds(r,c).pelletB = [];
        Thresholds(r,c).probB = [];
        Thresholds(nr,c).Theta = [];
    end
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
if plotEntries
    eh=errorbar(uniqueIVx,mEnter,semEnter);
    set(eh,'linestyle','none')
    set(eh,'color','g')
end
if plotSkips
    eh(2)=errorbar(uniqueIVx,-mExit,semExit);
    set(eh(2),'linestyle','none')
    set(eh(2),'color','r')
end
if plotMean
    eh(3)=errorbar(uniqueIVx,mDiff,semDiff);
    set(eh(3),'linestyle','none')
    set(eh(3),'color','k')
end
ph = nan(4,1);
if plotEntries
    ph(1)=plot(uniqueIVx,mEnter,'gx','markersize',8);
end
if plotSkips
    ph(2)=plot(uniqueIVx,-mExit,'rx','markersize',8);
end
if plotMean
    ph(3)=plot(uniqueIVx,mDiff,'ko','markersize',10);
    plot(uniqueIVx,mDiff,'k.');
end
legendStr{1} = sprintf('mean(V_t \\cdot Entry)');
legendStr{2} = sprintf('-mean(V_t \\cdot Exit');
legendStr{3} = sprintf('mean(V_t \\cdot Entry - V_t \\cdot Exit)');
legendStr{4} = sprintf('Fit');
drawnow
if Thresh
    Thresholds(nr,nc).b = B;
    Thresholds(nr,nc).r = R;
    Thresholds(nr,nc).IVr = nan;
    Thresholds(nr,nc).IVc = nan;
    
    Thresholds(nr,nc).Rsq = rsq;
    Thresholds(r,c).zoneB = zoneB(c);
    Thresholds(r,c).pelletB = pelletB;
    Thresholds(r,c).probB = probB;

    theta = threshold_from_logit(zoneB,pelletB,probB,0,mean(DATA(:,4)));
    Thresholds(nr,nc).Theta = theta;
    
    
    zonesPred = repmat(DATA(:,3),1,length(unique(DATA(:,3))))==repmat(1:length(unique(DATA(:,3))),size(DATA,1),1);
    zonesPred = repmat(mean(zonesPred),length(uniqueIVx),1);
    xThresh = [zonesPred ones(length(uniqueIVx),1)*mean(DATA(:,4)) uniqueIVx];
    
    ph(4)=plot(uniqueIVx(:),scaled_logit(xThresh,B,R,false),'k-','linewidth',2);
    tStr = sprintf('\\theta=%.3f\nR=%.1f to %.1f',theta,R(2),R(1));
    th=text(theta,min(DATA(:,9)),tStr);
    set(th,'verticalalignment','middle')
    set(th,'horizontalalignment','left')
    set(th,'fontangle','italic')
else
    Thresholds(nr,c).b = [];
    Thresholds(nr,c).r = [];
    Thresholds(nr,c).Rsq = [];
    Thresholds(r,c).zoneB = [];
    Thresholds(r,c).pelletB = [];
    Thresholds(r,c).probB = [];
    Thresholds(nr,c).Theta = [];
end
    
id = ~isnan(ph);
ph = ph(id);
legendStr = legendStr(id);
if ~isempty(ph)
    lh=legend(ph,legendStr);
    set(lh,'location','northoutside')
    set(lh,'fontsize',8)
    set(lh,'color','none')
    set(lh,'edgecolor','w')
end
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
end
drawnow
data.HEADER = {'SSN' 'SubSESS' ZI IVr IVx 'Entered Arm' 'Velocity Toward Feeder' 'Velocity Toward Next Zone' 'Difference'};
data.DATA = DATA;
data.Thresholds = Thresholds;

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

    vEnter = ptData(:,7);
    vExit = ptData(:,8);
    vDiff = ptData(:,9);
    
    mEnter(xi,1) = nanmean(vEnter);
    semEnter(xi,1) = nanstderr(vEnter);
    mExit(xi,1) = nanmean(vExit);
    semExit(xi,1) = nanstderr(vExit);
    
    mDiff(xi,1) = nanmean(vDiff);
    semDiff(xi,1) = nanstderr(vDiff);
end

function proj = projection_vector(v,u)
% Projection of vector v onto u.
%
%
%

proj = dot(v,u)/dot(u,u)*u;

function theta = threshold_from_logit(zoneB,pelletB,probB,Z,n)
if Z==0
    theta = (mean(zoneB)+pelletB*n)/-probB;
else
    theta = (zoneB(Z)+pelletB*n)/-probB;
end