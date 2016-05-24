function fh = check_nvt_mpg_tracking(LEDxy,NVTfn)
% Ensure that LEDxy is first in the same time range as the nvt file.
% MATLAB_LED_TRACK will do this automagically.
fh=[];
curDir = cd;
id = regexpi(curDir,'\');
SSN = curDir(max(id)+1:end);
SSN = strrep(SSN,'_','@');
% load('VT1_mpeg1\LED.mat')

if isstr(LEDxy)
    load(LEDxy,'x');
    load(LEDxy,'y');
    load(LEDxy,'LEDx');
    load(LEDxy,'LEDy');
    load(LEDxy,'RatTrackData')
    try
        id = 1:min(length(RatTrackData.timestamp),length(RatTrackData.LEDx));
        x = tsd(RatTrackData.timestamp(id),RatTrackData.LEDx(id));
        id = 1:min(length(RatTrackData.timestamp),length(RatTrackData.LEDy));
        y = tsd(RatTrackData.timestamp(id),RatTrackData.LEDy(id));
        Tnlynx = RatTrackData.nlynx;
        offset = min(RatTrackData.movieTime)-min(RatTrackData.frameTime);
    catch
        Tnlynx = [-inf inf];
    end
    if ~(exist('x','var')==1)
        x = LEDx;
    end
    if ~(exist('y','var')==1)
        y = LEDy;
    end
    LEDxy = tsd(x.range,[x.data y.data]);
end

XYmpeg = LEDxy.data;
Xmpg0 = XYmpeg(:,1);
Ympg0 = XYmpeg(:,2);
Tmpg0 = LEDxy.range;
mpegStart = Tmpg0(1);
mpegFinish = Tmpg0(end);

[pathname,fn,ext] = fileparts(NVTfn);
if strcmp(ext,'.zip')
    unzip('VT1.zip')
    [x,y]=LoadVT_lumrg('VT1.nvt');
    delete('VT1.nvt')
elseif strcmp(ext,'.nvt')
    [x,y]=LoadVT_lumrg('VT1.nvt');
end
x = x.restrict(mpegStart-offset,mpegFinish-offset);
y = y.restrict(mpegStart-offset,mpegFinish-offset);
SSN = sprintf('%s\n%.1fs - %.1fs',SSN,mpegStart,mpegFinish);

Xnvt = x.data;
Ynvt = y.data;
Tnvt = x.range;
% Tnvt = Tnvt - min(Tnvt);
% Tmpg = Tmpg - min(Tmpg);
Xmpg = interp1(Tmpg0,Xmpg0,Tnvt+offset);
Ympg = interp1(Tmpg0,Ympg0,Tnvt+offset);
Tmpg = Tnvt+offset;

idnanMpg = isnan(Xmpg)|isnan(Ympg);
idnanNvt = isnan(Xnvt)|isnan(Ynvt);
dtMpg = [nan;diff(Tmpg)];
dtNvt = [nan;diff(Tnvt)];

% Xmpg = nan(length(Tnvt),1);
% Ympg = nan(length(Tnvt),1);
% Tmpg = nan(length(Tnvt),1);
% timediff = nan(length(Tnvt),1);
% for t = 2 : length(Tnvt)-1
%     t0 = Tnvt(t-1);
%     t1 = Tnvt(t+1);
%     xy0 = LEDxy.restrict(t0,t1);
%     if ~isempty(xy0.data)&~isempty(xy0.data)
%         ts = xy0.range;
%         [d,id] = min(ts-Tnvt(t));
%         Tmpg(t) = ts(id);
%         xy0 = xy0.data;
%         x0 = xy0(:,1);
%         y0 = xy0(:,2);
%         Xmpg(t) = x0(id);
%         Ympg(t) = y0(id);
%         timediff(t) = d;
%     end
%     
% end


D = sqrt((Xmpg-Xnvt).^2+(Ympg-Ynvt).^2);

dXdT_mpg = [nan; diff(Xmpg)./diff(Tmpg)];
dYdT_mpg = [nan; diff(Ympg)./diff(Tmpg)];
vMpg = sqrt(dXdT_mpg.^2+dYdT_mpg.^2);

% dx = dxdt(tsd(Tmpg(:),Xmpg(:)));
% dy = dxdt(tsd(Tmpg(:),Ympg(:)));
% TvMpg = dx.range;
% dx = dx.data;
% dy = dy.data;
% 
% dx = interp1(TvMpg,dx,min(Tmpg)+T);
% dy = interp1(TvMpg,dy,min(Tmpg)+T);

% vMpg = sqrt(dx.^2+dy.^2);

% dx = dxdt(x);
% dy = dxdt(y);
% 
% TvNvt = dx.range;
% dx = dx.data;
% dy = dy.data;
% 
% dx = interp1(TvNvt,dx,min(Tnvt)+T);
% dy = interp1(TvNvt,dy,min(Tnvt)+T);

dXdT_nvt = [nan; diff(Xnvt)./diff(Tnvt)];
dYdT_nvt = [nan; diff(Ynvt)./diff(Tnvt)];

vNvt = sqrt(dXdT_nvt.^2+dYdT_nvt.^2);



% seconds of lag.
fh(length(fh)+1) = figure;
clf
subplot(2,1,1)
hold on
% id = ~isnan(LAG)&~isinf(LAG);
% h=hist(LAG(id));
% hist(LAG(id),ceil(sqrt(length(LAG(id)))));
% xlabel('Lag: Distance / speed on NVT.')
distVec = [Xmpg Ympg] - [Xnvt Ynvt];
vVec = [dXdT_nvt dYdT_nvt];
for F = 1 : length(Tnvt)
    p(F) = dot(distVec(F,:),vVec(F,:)./sqrt(dot(vVec(F,:),vVec(F,:))));
end
LAG =p(:)./vNvt(:); 
hist(LAG,ceil(sqrt(length(p))));
h=hist(LAG,ceil(sqrt(length(p))));
plot([nanmean(LAG) nanmean(LAG)],[0 max(h)],'c-')
text(nanmean(LAG),max(h),sprintf('%.4f',nanmean(LAG)),'verticalalignment','bottom','horizontalalignment','center');
text(0,0,sprintf('Offset=%.4f',offset),'verticalalignment','bottom')
xlim=get(gca,'xlim');
set(gca,'xlim',[-max(abs(xlim)) max(abs(xlim))])
xlabel(sprintf('Lag in sec\n((XY_{MPEG}-XY_{NVT})\\cdot(V/||V||))/||V||\n(Ahead of MPEG\\leftarrow\\rightarrowTrailing MPEG)'))

hold off
subplot(2,1,2)
hold on
LAG = D./vNvt;
id = ~isnan(LAG)&~isinf(LAG);
h=histcn([vMpg(id) (LAG(id))],linspace(min(vMpg(id)), max(vMpg(id)), 200), linspace(min(LAG(id)), max(LAG(id)), 100));
imagesc(h)
xlabel('Absolute Lag: Distance / speed on NVT')
ylabel('Speed on MPG')
set(gca,'xlim',[1 100])
set(gca,'xtick',[1 100])
set(gca,'xticklabel',[min(LAG(id)) max(LAG(id))])
set(gca,'ylim',[1 200])
set(gca,'ytick',[1 200])
set(gca,'yticklabel',[min(vMpg(id)) max(vMpg(id))])

hold off

fh(length(fh)+1) = figure;
clf
hold on
title(sprintf('%s',SSN))
h=histcn([vMpg D],linspace(min(vMpg), max(vMpg), 200), linspace(min(D), max(D), 100));
[Xgrid,Ygrid] = meshgrid(linspace(min(D), max(D), 100),linspace(min(vMpg), max(vMpg), 200));

imagesc(log10(h))

% contourf(Xgrid,Ygrid,log10(h))

dtick = linspace(min(D),max(D),100);
xtick = linspace(1,100,100);
x0 = interp1(dtick,xtick,0);
xticklabel = [min(D);max(D);0];
[xtick,id] = unique([min(xtick);max(xtick);x0]);
xticklabel = xticklabel(id);

vtick = linspace(min(vMpg),max(vMpg),200);
ytick = linspace(1,200,200);
y0 = interp1(vtick,ytick,0);
yticklabel = [min(vMpg);max(vMpg);0];
[ytick,id] = unique([min(ytick);max(ytick);y0]);
yticklabel = yticklabel(id);

set(gca,'xtick',xtick)
set(gca,'ytick',ytick)
set(gca,'xlim',[min(xtick) max(xtick)])
set(gca,'ylim',[min(ytick) max(ytick)])
set(gca,'xticklabel',xticklabel)
set(gca,'yticklabel',yticklabel)

plot([x0 x0],[1 200],'w-')
plot([1 100],[y0 y0],'w-')

xlabel(sprintf('XY_{MPEG}-XY_{NVT}\n(MPEG downsampled to NVT)')); ylabel(sprintf('V_{MPEG}'));
ch=colorbar;
set(get(ch,'ylabel'),'string',sprintf('Log_{10}[Number of points]'))
set(get(ch,'ylabel'),'rotation',-90)
hold off

fh(2)=figure;
clf
subplot(1,2,1)
hold on
title(sprintf('%s',SSN))
V = [dXdT_mpg dYdT_mpg];
for t = 1 : length(V)
    V0(t,1) = dot(V(t,:),abs(V(t,:)));
end
V = V0;
clear V0
h=histcn([V Xmpg-Xnvt],linspace(min(V), max(V), 200), linspace(min(Xmpg-Xnvt), max(Xmpg-Xnvt), 100));
[Xgrid,Ygrid] = meshgrid(linspace(min(Xmpg-Xnvt), max(Xmpg-Xnvt), 100),linspace(min(V), max(V), 200));

imagesc(log10(h))

% contourf(Xgrid,Ygrid,log10(h))

dtick = linspace(min(Xmpg-Xnvt),max(Xmpg-Xnvt),100);
xtick = linspace(1,100,100);
x0 = interp1(dtick,xtick,0);
xticklabel = [min(Xmpg-Xnvt);max(Xmpg-Xnvt);0];
[xtick,id] = unique([min(xtick);max(xtick);x0]);
xticklabel = xticklabel(id);

vtick = linspace(min(V),max(V),200);
ytick = linspace(1,200,200);
y0 = interp1(vtick,ytick,0);
yticklabel = [min(V);max(V);0];
[ytick,id] = unique([min(ytick);max(ytick);y0]);
yticklabel = yticklabel(id);

set(gca,'xtick',xtick)
set(gca,'ytick',ytick)
set(gca,'xlim',[min(xtick) max(xtick)])
set(gca,'ylim',[min(ytick) max(ytick)])
set(gca,'xticklabel',xticklabel)
set(gca,'yticklabel',yticklabel)

plot([x0 x0],[1 200],'w-')
plot([1 100],[y0 y0],'w-')

xlabel(sprintf('X_{MPEG}-X_{NVT}\n(MPEG downsampled to NVT)')); ylabel(sprintf('V_{MPEG} \\cdot | V_{MPEG} |'));
ch=colorbar;
set(get(ch,'ylabel'),'string',sprintf('Log_{10}[Number of points]'))
set(get(ch,'ylabel'),'rotation',-90)
hold off
subplot(1,2,2)
hold on
h=histcn([V Ympg-Ynvt],linspace(min(V), max(V), 200), linspace(min(Ympg-Ynvt), max(Ympg-Ynvt), 100));
[Xgrid,Ygrid] = meshgrid(linspace(min(Ympg-Ynvt), max(Ympg-Ynvt), 100),linspace(min(V), max(V), 200));

imagesc(log10(h))

% contourf(Xgrid,Ygrid,log10(h))

dtick = linspace(min(Ympg-Ynvt),max(Ympg-Ynvt),100);
xtick = linspace(1,100,100);
x0 = interp1(dtick,xtick,0);
xticklabel = [min(Ympg-Ynvt);max(Ympg-Ynvt);0];
[xtick,id] = unique([min(xtick);max(xtick);x0]);
xticklabel = xticklabel(id);

vtick = linspace(min(V),max(V),200);
ytick = linspace(1,200,200);
y0 = interp1(vtick,ytick,0);
yticklabel = [min(V);max(V);0];
[ytick,id] = unique([min(ytick);max(ytick);y0]);
yticklabel = yticklabel(id);

set(gca,'xtick',xtick)
set(gca,'ytick',ytick)
set(gca,'xlim',[min(xtick) max(xtick)])
set(gca,'ylim',[min(ytick) max(ytick)])
set(gca,'xticklabel',xticklabel)
set(gca,'yticklabel',yticklabel)

plot([x0 x0],[1 200],'w-')
plot([1 100],[y0 y0],'w-')

xlabel(sprintf('Y_{MPEG}-Y_{NVT}\n(MPEG downsampled to NVT)')); ylabel(sprintf('V_{MPEG} \\cdot | V_{MPEG} |'));
ch=colorbar;
set(get(ch,'ylabel'),'string',sprintf('Log_{10}[Number of points]'))
set(get(ch,'ylabel'),'rotation',-90)
hold off

% fh(3)=figure;
% clf
% subplot(3,1,2)
% cla
% hold on
% ph(1)=plot(Tmpg,vMpg,'r-');
% ph(2)=plot(Tnvt,vNvt,'k-');
% xlabel('Time since start (sec)')
% ylabel('Running Speed')
% legendStr = {'mpg' 'nvt'};
% legend(ph,legendStr)
% hold off
% 
% subplot(3,1,1)
% cla
% hold on
% title(sprintf('%s',curDir))
% plot(T,D,'b-')
% xlabel('Time since start (sec)')
% ylabel('Euclidean distance from mpeg LED to NVT')
% hold off
% subplot(3,2,5)
% cla
% hold on
% plot(T,Xmpg-Xnvt)
% xlabel('Time since start (sec)')
% ylabel('MPEG x-coordinate - NVT x-coordinate')
% hold off
% subplot(3,2,6)
% cla
% hold on
% plot(T,Xmpg-Xnvt)
% xlabel('Time since start (sec)')
% ylabel('MPEG y-coordinate - NVT y-coordinate')
% hold off

fh(4) = figure;
clf
hold on
title(sprintf('%s',SSN))
sh=scatter3(Xmpg,Ympg,ones(length(Xmpg),1),8,D);
view(0,90)
ch=colorbar;
set(get(ch,'ylabel'),'string','Euclidean Distance')
set(get(ch,'ylabel'),'rotation',-90)
set(gca,'xlim',[0 720])
set(gca,'ylim',[0 480])
hold off

fh(5) = figure;
clf
subplot(1,2,1)
title(sprintf('%s',SSN))
axis equal
hold on
idx = linspace(1,length(Xmpg),500);
idx = unique(round(idx));
ph=quiver(Xmpg(idx),Ympg(idx),Xmpg(idx)-Xnvt(idx),Ympg(idx)-Ynvt(idx));
set(ph,'color','r')
ph(2)=quiver(Xmpg(idx),Ympg(idx),dXdT_mpg(idx),dYdT_mpg(idx));
set(ph(2),'color','k')
legendStr = {'Distance' 'Velocity'};
legend(ph,legendStr,'location','northoutside')
hold off
subplot(1,2,2)
hold on
N = nan(length(Xmpg),1);
V = nan(length(Xmpg),1);
for t = 1 : length(Xmpg)
    v = [dXdT_mpg(t);dYdT_mpg(t)];
    u = [Xmpg(t)-Xnvt(t);Ympg(t)-Ynvt(t)];
    N(t) = dot(u,abs(v));
    V(t) = dot(v,abs(v));
end
h=histcn([V N],linspace(min(V), max(V), 200), linspace(min(N), max(N), 100));
[Xcont,Ycont] = meshgrid(linspace(min(N),max(N),100),linspace(min(V),max(V),200));

imagesc(log10(h))

dtick = linspace(min(N),max(N),100);
xtick = linspace(1,100,100);
x0 = interp1(dtick,xtick,0);
xticklabel = ([min(N);max(N);0]);
[xtick,id] = unique([min(xtick);max(xtick);x0]);
xticklabel = xticklabel(id);

vtick = linspace(min(V),max(V),200);
ytick = linspace(1,200,200);
y0 = interp1(vtick,ytick,0);
yticklabel = ([min(V);max(V);0]);
[ytick,id] = unique([min(ytick);max(ytick);y0]);
yticklabel = yticklabel(id); 

set(gca,'xtick',xtick)
set(gca,'ytick',ytick)
set(gca,'xlim',[min(xtick) max(xtick)])
set(gca,'ylim',[min(ytick) max(ytick)])
set(gca,'xticklabel',xticklabel)
set(gca,'yticklabel',yticklabel)

plot([x0 x0],[1 200],'w-')
plot([1 100],[y0 y0],'w-')

xlabel(sprintf('V_{MPEG} \\cdot | V_{MPEG} |'))
ylabel(sprintf('(XY_{MPEG}-XY_{NVT}) \\cdot | V_{MPEG} |'))
ch=colorbar;
set(get(ch,'ylabel'),'string',sprintf('Log_{10}[Number of points]'))
set(get(ch,'ylabel'),'rotation',-90)
hold off