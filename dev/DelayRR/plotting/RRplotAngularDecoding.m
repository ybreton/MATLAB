function p = RRplotAngularDecoding(B,theta,Tregret)
%
%
%
%

thetaRegret = theta.data(Tregret);
pRegret = B.pxs.data(Tregret);
thetaList = linspace(B.min,B.max,B.nBin);

dTheta = nan(length(Tregret),length(thetaList));
for iTrl = 1 : length(Tregret)
    dTheta(iTrl,:) = thetaList-thetaRegret(iTrl);
end

thetaBin = linspace(-pi,pi,64);
binw = mean(diff(thetaBin));
p = nan(size(pRegret,1),length(thetaBin));
for iTrl = 1:size(pRegret,1)
    for iTheta=2:length(thetaBin)-1;
        idT = dTheta(iTrl,:)>=thetaBin(iTheta)-binw/2&dTheta(iTrl,:)<thetaBin(iTheta)+binw/2;
        p0 = pRegret(iTrl,idT);
        if ~isempty(p0)
            p(iTrl,iTheta) = nansum(p0);
        end
    end
    idT = (dTheta(iTrl,:)>=thetaBin(1)-binw/2&dTheta(iTrl,:)<thetaBin(1)+binw/2)|(dTheta(iTrl,:)>=thetaBin(end)-binw/2&dTheta(iTrl,:)<thetaBin(end)+binw/2);
    p0 = pRegret(iTrl,idT);
    p(iTrl,[1 length(thetaBin)]) = nansum(p0);
end
bh=bar(thetaBin,nanmean(p,1),1);
set(get(bh,'children'),'facecolor',[0.8 0.8 0.8])
xtick = [-pi -3/4*pi -pi/2 -pi/4 0 pi/4 pi/2 3/4*pi pi];
set(gca,'xtick',xtick)
xticklabel = {'Opposite\nzone' 'Opposite\nfeeder' 'Last\nzone' 'Last\nfeeder' 'Current\nzone' 'Current\nfeeder' 'Next\nzone' 'Next\nfeeder' 'Opposite\nzone'};
set(gca,'xticklabel',[])
set(gca,'xlim',[-pi-binw/2 pi+binw/2])
for iTick = 1 :2: length(xticklabel)
    th=text(xtick(iTick),0,sprintf(xticklabel{iTick}));
    set(th,'VerticalAlignment','Top')
    set(th,'HorizontalAlignment','Center')
end
ylim = get(gca,'ylim');
for iTick = 2 :2: length(xticklabel)
    th=text(xtick(iTick),ylim(2),sprintf(xticklabel{iTick}));
    set(th,'VerticalAlignment','Bottom')
    set(th,'HorizontalAlignment','Center')
end
set(gca,'tickDir','in')
ylabel('Mean decoded probability of angular position')