function wrap_RR_VTEvalidation(fn,varargin)
%
%
%
%
%

VTEtime = 2;
k = 2;
figList = get(0,'children');
if isempty(figList)
    lastFig = 1;
else
    lastFig = max(figList);
end
fh = lastFig;
process_varargin(varargin);

disp('Getting entering zone time...')
EnteringZoneTime = RRGetField(fn,'EnteringZoneTime');
ExitingZoneTime = EnteringZoneTime+VTEtime;

disp('Getting x position...')
xPos = RRGetField(fn,'x','numeric',false);
disp('Getting y position...')
yPos = RRGetField(fn,'y','numeric',false);

disp('Getting speed...')
speed = RRGetVelocity(fn);

disp('Getting IdPhi...')
[IdPhi,Zidphi] = RRGetIdPhi(fn,'VTEtime',VTEtime);

disp('Calculating position and mean speed at choice point...')
meanSpeed = nan(size(EnteringZoneTime));
x = cell(size(EnteringZoneTime));
y = cell(size(EnteringZoneTime));
nmax = 0;
for iSess = 1 : size(EnteringZoneTime,1);
    disp(fn{iSess});
    for jTrial = 1 : size(EnteringZoneTime,2); 
        if ~isnan(EnteringZoneTime(iSess,jTrial)); 
            t1 = EnteringZoneTime(iSess,jTrial); 
            t2 = ExitingZoneTime(iSess,jTrial); 
            V = speed{iSess}.restrict(t1,t2); 
            meanSpeed(iSess,jTrial) = nanmean(V.data); 
            x{iSess,jTrial} = xPos{iSess}.restrict(t1,t2);
            y{iSess,jTrial} = yPos{iSess}.restrict(t1,t2);
            nmax = max(nmax,length(x{iSess,jTrial}.data));
        end; 
    end; 
end
disp('2D Histogram of Log[I dPhi] and speed...')
[Hf,Hb] = histcn([log10(IdPhi(:)) log10(meanSpeed(:))],linspace(1,3,51),linspace(0.9,2.1,31));
disp([num2str(k) ' component fit.'])
gmobj = gmmfit([log10(IdPhi(:)) log10(meanSpeed(:))],k); hold on; plot(gmobj.mu(:,1),gmobj.mu(:,2),'w.');hold off

figure(fh(1));
subplot(2,2,1); 
imagesc(Hb{1},Hb{2},Hf'/sum(Hf(:))); 
hold on;
title('Joint distribution');
axis xy
[X,Y] = meshgrid(Hb{1},Hb{2});
Z = gmobj.pdf([X(:) Y(:)]);
Z = reshape(Z,size(X));
contour(X,Y,Z/sum(Z(:)));
plot(gmobj.mu(:,1),gmobj.mu(:,2),'ko','markerfacecolor','w');
hold off;
xlabel(sprintf('Log_{10}[I d\\phi]')); 
ylabel('Speed in pixels/sec');
drawnow

[X,Y] = meshgrid(Hb{1},Hb{2});
binw = [mean(diff(Hb{1})) mean(diff(Hb{2}))];

subplot(2,2,2);
[f,bin] = hist(log10(meanSpeed(:)),Hb{2}); 
bh=bar(bin,f/sum(f),1);
hold on;
set(get(bh,'children'),'facecolor',[0.8 0.8 0.8])
xlabel(sprintf('Log_{10}[Speed] \n(pixels/sec)'));
title('Marginal speed distribution')
Z = gmobj.cdf([X(:) Y(:)+binw(2)/2])-gmobj.cdf([X(:) Y(:)-binw(2)/2]);
Z = reshape(Z,size(X));
Zm = nanmean(Z,2);
ph=plot(Y(:,1),Zm/sum(Zm(:)));
legendStr = '';
for iComponent = 1 : k
    legendStr = [legendStr sprintf('\\mu_{%d} = %.2f, \\tau_{%d} = %.2f\n',iComponent, gmobj.mu(iComponent,2), iComponent, gmobj.PComponents(iComponent))];    
end
set(ph,'linestyle','-')
set(ph,'color','r')
set(ph,'linewidth',2)
legend(ph,legendStr)
plot(gmobj.mu(:,2),zeros(k,1),'ko','markerfacecolor','w');
hold off;
set(gca,'xlim',[min(Hb{2}) max(Hb{2})])
drawnow

subplot(2,2,3); 
[f,bin] = hist(log10(IdPhi(:)),Hb{1}); 
bh=bar(bin,f/sum(f),1);
set(get(bh,'children'),'facecolor',[0.8 0.8 0.8])
hold on;
title(sprintf('Marginal Log_{10}[I d\\phi] distribution'))
xlabel(sprintf('Log_{10}[I d\\phi]')); 
[X,Y] = meshgrid(Hb{1},Hb{2});
binw = mean(diff(Hb{1}));
Z = gmobj.cdf([X(:)+binw(1)/2 Y(:)])-gmobj.cdf([X(:)-binw(1)/2 Y(:)]);
Z = reshape(Z,size(X));
Zm = nanmean(Z,1);
ph=plot(X(1,:),Zm/sum(Zm(:)));
legendStr = '';
for iComponent = 1 : k
    legendStr = [legendStr sprintf('\\mu_{%d} = %.2f, \\tau_{%d} = %.2f\n',iComponent, gmobj.mu(iComponent,1),iComponent, gmobj.PComponents(iComponent))];    
end
set(ph,'linestyle','-')
set(ph,'color','r')
set(ph,'linewidth',2)
legend(ph,legendStr)
plot(gmobj.mu(:,1),zeros(k,1),'ko','markerfacecolor','w');
hold off;
set(gca,'xlim',[min(Hb{1}) max(Hb{1})])
drawnow

[idSess,idTrl] = meshgrid(1:size(EnteringZoneTime,1),1:size(EnteringZoneTime,2));
LogIdPhiList = IdPhi(:);
idSess = idSess(:);
idTrl = idTrl(:);
x = x(:);
y = y(:);
[LogIdPhiList,idSort] = sort(LogIdPhiList);
idSess = idSess(idSort);
idTrl = idTrl(idSort);
x = x(idSort);
y = y(idSort);
idnan = isnan(LogIdPhiList);

subplot(2,2,4)
cla
title(sprintf('Passes'))
hold on
axis image
set(gca,'xlim',[0 720])
set(gca,'ylim',[0 480])
set(gca,'xtick',[])
set(gca,'ytick',[])
view(2)
x0 = nan(nmax,length(LogIdPhiList(~idnan)));
y0 = x0;
z0 = x0;
for iPass = 1 : length(LogIdPhiList(~idnan))
    n = length(x{iPass}.data);
    x0(1:n,iPass) = x{iPass}.data;
    y0(1:n,iPass) = y{iPass}.data;
    z0(1:n,iPass) = ones(n,1)*LogIdPhiList(iPass);
end
scatterplotc(x0(:),y0(:),z0(:),'plotchar','.','solid_face',true)
caxis([min(Hb{1}) max(Hb{1})])
cbh=colorbar;
set(get(cbh,'ylabel'),'string',sprintf('Log_{10}[I d\\phi]'))
set(get(cbh,'ylabel'),'rotation',-90)
set(gca,'xcolor','w')
set(gca,'ycolor','w')
hold off
