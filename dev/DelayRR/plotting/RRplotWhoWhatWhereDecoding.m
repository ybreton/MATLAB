function RRplotWhoWhatWhereDecoding(x,y,t,nvt,Target,S,TC,B)
%
%
%
%

if islogical(Target)&&size(Target,1)>1
    for iC = 1 : size(Target,2)
        TargetIdx(iC) = find(Target(:,iC));
    end
    Target = TargetIdx;
end

Pxy = B.pxs.data(t);
dt = B.pxs.dt;

x0 = x.data(t);
y0 = y.data(t);

[~,Rxy,Gxy,~,Lumxy]=getNVTframe(nvt,t);

T = [];
D = [];
for iC=1:length(S)
    s = S{iC}.restrict(t-dt,t);
    D = [D; ones(length(s.data),1)*iC];
    T = [T; s.data];
end
if ~isempty(T)&&~isempty(D)
    [T,id] = sort(T);
    D = D(id);
    repeat = [false; diff(D)==0];
    nrns = tsd(T(~repeat),D(~repeat));
    sequence = tsd(T,D);
else
    sequence = tsd(T,D);
    nrns = tsd(T,D);
end

xPos = linspace(TC.min(1),TC.max(1),TC.nBin(1));
yPos = linspace(TC.min(2),TC.max(2),TC.nBin(2));
xlim = [TC.min(1) TC.max(1)];
ylim = [TC.min(2) TC.max(2)];
[xMesh,yMesh]=meshgrid(xPos,yPos);
cmap = jet(length(S));

clf
subplot(3,1,1)
cla
imagesc(zeros(ceil(TC.max(2)),ceil(TC.max(1)),3))
set(gca,'xlim',xlim)
set(gca,'ylim',ylim)
set(gca,'xcolor','w')
set(gca,'ycolor','w')
set(gca,'xtick',[])
set(gca,'ytick',[])

subplot(3,1,2)
cla
for iC=1:6
    subplot(3,6,12+iC)
    cla
    imagesc(zeros(ceil(TC.max(2)),ceil(TC.max(1)),3))
    set(gca,'xlim',xlim)
    set(gca,'ylim',ylim)
    set(gca,'xcolor','w')
    set(gca,'ycolor','w')
    set(gca,'xtick',[])
    set(gca,'ytick',[])
end
cla

subplot(3,1,1)
imagesc(xPos,yPos,squeeze(Pxy)')
hold on
plot(x0,y0,'wo')
plot(Rxy.x.data,Rxy.y.data,'rx')
plot(Gxy.x.data,Gxy.y.data,'gx')
plot(Lumxy.x.data,Lumxy.y.data,'w.')
contour(xMesh,yMesh,TC.Occ',[0 0],'w')
hold off
axis image
title(sprintf('Decoding at t=%.2f',t))
set(gca,'xlim',xlim)
set(gca,'ylim',ylim)
set(gca,'xcolor','w')
set(gca,'ycolor','w')
set(gca,'xtick',[])
set(gca,'ytick',[])

subplot(3,1,2)
hold on
if ~isempty(sequence.range)&&~isempty(sequence.data)
    T = sequence.range-t;
    D = sequence.data;
    uniqueD = unique(D);
    for iD=1:length(unique(D));
        plot(T(D==uniqueD(iD)),D(D==uniqueD(iD)),'ko','markerfacecolor',cmap(D(iD),:));
    end
end
T = nrns.range-t;
D = nrns.data;
th = nan(length(T),1);
for iT=1:length(T)
    th(iT)=text(T(iT),D(iT),sprintf('%d',D(iT)));
end
hold off
th = th(~isnan(th));
set(th,'fontsize',12)
set(th,'VerticalAlignment','bottom')
set(th,'HorizontalAlignment','left')
xlabel('Time aligned to decoding frame')
ylabel('Neuron number')
set(gca,'ytick',[])
set(gca,'ylim',[0 length(S)+1])
set(gca,'xlim',[-dt 0])

nPlots = length(nrns.data);
D = nrns.data;
for iC = 1 : nPlots
    subplot(3,6,(2*6)+iC)
    imagesc(xPos,yPos,(squeeze(TC.H(D(iC),:,:))'./TC.Occ'))
    hold on
    plot(x0,y0,'wo')
    plot(Rxy.x.data,Rxy.y.data,'rx')
    plot(Gxy.x.data,Gxy.y.data,'gx')
    plot(Lumxy.x.data,Lumxy.y.data,'w.')
    contour(xMesh,yMesh,TC.Occ',[0 0],'w')
    hold off
    axis image
    if length(unique(Target))>1
        title(sprintf('Target %d\n#%d',Target(D(iC)),D(iC)))
    else
        title(sprintf('#%d',D(iC)))
    end
    set(gca,'xlim',xlim)
    set(gca,'ylim',ylim)
    set(gca,'xcolor','w')
    set(gca,'ycolor','w')
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    drawnow
end
