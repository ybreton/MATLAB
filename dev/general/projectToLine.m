function [x0,y0] = projectToLine(sd)
%
%
%
%
step = 1;
debug = true;

x = sd.x;
y = sd.y;

X = 0:step:ceil(max(x.data)/step)*step;
Y = 0:step:ceil(max(y.data)/step)*step;
x0 = nan(length(Y),length(X));
y0 = nan(length(Y),length(X));

vx = dxdt(x);
vy = dxdt(y);

tin = nan(length(sd.ZoneIn),1);
tout = nan(length(sd.ZoneIn),1);
for iTrl=1:length(sd.ZoneIn)-1
    tin(iTrl) = sd.EnteringZoneTime(iTrl);
    tout(iTrl) = sd.EnteringZoneTime(iTrl+1);
end
tin(end) = sd.EnteringZoneTime(end);
tout(end) = sd.ExpKeys.TimeOffTrack;
zin = sd.ZoneIn;
zones = unique(zin);

for iZ=1:length(zones)
    zone = zones(iZ);
    Zvx = data(vx.restrict(tin(zin==zone),tout(zin==zone)));
    Zvy = data(vy.restrict(tin(zin==zone),tout(zin==zone)));
    S = sqrt(Zvx.^2+Zvy.^2);
    Tv = range(vy.restrict(tin(zin==zone),tout(zin==zone)));
    Zx = x.data(Tv);
    Zy = y.data(Tv);
    disp('Finding high-speed running mode...')
    gmm = gmmfit(log10(S),[],'Replicates',25);
%     p = gmm.posterior(log10(S));
%     [~,MAP] = max(p,[],2);
%     I0 = MAP==size(p,2);
    I0 = log10(S)>gmm.mu(end);
    D = [Zx(I0) Zy(I0) Zvx(I0) Zvy(I0)];
    Inan = any(isnan(D),2);
    D = D(~Inan,:);
    disp('Finding clusters of position/velocity quartets...')
    gmobj = gmmfit(D,[],'Replicates',10);
    
    xc = nan(gmobj.NComponents,1);
    yc = nan(gmobj.NComponents,1);
    vxc = nan(gmobj.NComponents,1);
    vyc = nan(gmobj.NComponents,1);
    for iComp=1:gmobj.NComponents
        mu = gmobj.mu(iComp,:);
        xc(iComp) = mu(1);
        yc(iComp) = mu(2);
        vxc(iComp) = mu(3);
        vyc(iComp) = mu(4);
    end
    sc = sqrt(vxc.^2+vyc.^2);
    stopped = sc<median(S);
    % Calculate posterior of each.
    p = gmobj.posterior([Zx, Zy, Zvx, Zvy]);
    % Remove stopped periods.
    p(:,stopped) = nan;
    
    [~,MAP] = max(p,[],2);
    disp('Linearizing clusters to velocity vector translated to cluster center...')
    for iComp=min(MAP):max(MAP);
        I = MAP==iComp;
        mux = gmobj.mu(iComp,1);
        muy = gmobj.mu(iComp,2);
        nux = gmobj.mu(iComp,3);
        nuy = gmobj.mu(iComp,4);
        ZxC = Zx(I);
        ZyC = Zy(I);
        
        vv = [nux; nuy]/norm([nux; nuy]);
        pxy = [ZxC-mux ZyC-muy]*vv;
        xy = nan(length(pxy),2);
        for iN=1:length(pxy)
            xy(iN,:) = pxy(iN)*vv'+[mux muy];
        end
        Xlist = find(X>=min(ZxC)&X<=max(ZxC));
        Ylist = find(Y>=min(ZyC)&Y<=max(ZyC));
        k=0;
        fprintf('\n')
        for iX=Xlist
            idX = ZxC>X(iX)-step/2 & ZxC<=X(iX)+step/2;
            for iY=Ylist
                k = k+1;
                if mod(k,100)==1
                    fprintf('\n')
                end
                fprintf('.');
                
                idY = ZyC>Y(iY)-step/2 & ZyC<=Y(iY)+step/2;
                if any(idX&idY)
                    L = nanmean(xy(idX&idY,:),1);

                    x0(iY,iX) = L(1);
                    y0(iY,iX) = L(2);
                end
            end
        end
        fprintf('\n')
    end
    
    if debug
        clf
        subplot(2,2,1)
        hold on
        quiver(Zx(I0), Zy(I0), Zvx(I0), Zvy(I0));
        for iComp=1:gmobj.NComponents
            mu = gmobj.mu(iComp,:);
            quiver(mu(1), mu(2), mu(3), mu(4), 'r', 'linewidth', 3)
        end
        hold off
        subplot(2,2,2)
        hold on
        scatterplotc(Zx, Zy, MAP,'crange',[min(MAP), max(MAP)]);
        caxis([min(MAP), max(MAP)])
        colorbar;
        hold off
        
        subplot(2,2,3)
        imagesc(X,Y,x0)
        caxis([min(X) max(X)])
        axis xy
        colorbar
        
        subplot(2,2,4)
        imagesc(X,Y,y0)
        caxis([min(Y) max(Y)])
        axis xy
        colorbar
        
        drawnow
    end 
end