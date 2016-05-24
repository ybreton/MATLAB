fn = FindFiles('RR-*.mat');
fd = cell(length(fn),1);
for iF=1:length(fn); fd{iF}=fileparts(fn{iF}); end;
fd = unique(fd);
%%
Condition = cell(length(fd),1);
pRegret = nan(length(fd),64);
pRejoice = nan(length(fd),64);
pDisapp1 = nan(length(fd),64);
pDisapp2 = nan(length(fd),64);
pAll = nan(length(fd),64);
for iD = 1 : length(fd)
    pushdir(fd{iD});
    disp(fd{iD});
    
    sd = RRInit;
    Condition{iD} = sd(1).ExpKeys.Condition;
    CoM = [nanmean(sd.x.data(sd.EnteringZoneTime)) nanmean(sd.y.data(sd.EnteringZoneTime))];
    theta = tsd(sd.x.range,atan2(sd.y.data-CoM(2),sd.x.data-CoM(1)));
    r = nanmean(sqrt((sd.x.data(sd.EnteringZoneTime)-CoM(1)).^2+(sd.y.data(sd.EnteringZoneTime)-CoM(2)).^2));
    
    idTT = RRassignTetrodeClusters(sd);

    TC = TuningCurves(sd.S(idTT(1,:)),theta);
    for iC=1:size(TC.H,1);
        clf
        hold on
        plot(CoM(1),CoM(2),'kx')
        plot(sd.x.data,sd.y.data,'.','markerfacecolor',[0.8 0.8 0.8],'markeredgecolor',[0.8 0.8 0.8]);
        x0 = CoM(1)+r*cos(linspace(-pi,pi,64));
        y0 = CoM(2)+r*sin(linspace(-pi,pi,64));
        scatterplotc(x0,y0,TC.H(iC,:)./TC.Occ','solid_face',true)
        colorbar;
        hold off
        pause;
    end
        

    Q = MakeQfromS(sd.S(idTT(1,:)),0.125);
    B = BayesianDecoding(Q,TC);
    
    regret = RRGetRegret(sd);
    disapp = RRGetDisappointment(sd);
    rejoice = RRGetRejoice(sd);

    Tregret = sd.EnteringZoneTime(regret(1:length(sd.ZoneIn))==1);
    Tdisapp1 = sd.EnteringZoneTime(disapp.Disapp1(1:length(sd.ZoneIn))==1);
    Tdisapp2 = sd.EnteringZoneTime(disapp.Disapp2(1:length(sd.ZoneIn))==1);
    Trejoice = sd.EnteringZoneTime(rejoice(1:length(sd.ZoneIn))==1);
    
    pAll(iD,:) = nanmean(RRplotAngularDecoding(B,theta,sd.EnteringZoneTime));
    pRejoice(iD,:) = nanmean(RRplotAngularDecoding(B,theta,Trejoice));
    pDisapp1(iD,:) = nanmean(RRplotAngularDecoding(B,theta,Tdisapp1));
    pDisapp2(iD,:) = nanmean(RRplotAngularDecoding(B,theta,Tdisapp2));
    pRegret(iD,:) = nanmean(RRplotAngularDecoding(B,theta,Tregret));
    drawnow
    text(min(get(gca,'xlim')),max(get(gca,'ylim')),'Regret','VerticalAlignment','top')
    
    popdir;
end

idVeh = strcmp('Vehicle',Condition)|strcmp('Saline',Condition);
idCNO = strcmp('CNO',Condition)|strcmp('Drug',Condition);
%%
figure;
subplot(5,1,1)
title('Vehicle CA1')
hold on
theta = linspace(-pi,pi,64)';
binw = mean(diff(theta));

s = nanstderr(pAll(idVeh,:));
s = s';
m = nanmean(pAll(idVeh,:),1);
m = m';
eh=errorbar(theta,m,s);
set(eh,'linestyle','none')
hold on
bh=bar(theta,m,1);
legend(get(bh,'children'),'All entries')
hold off
xtick = [-pi -3/4*pi -pi/2 -pi/4 0 pi/4 pi/2 3/4*pi pi];
set(gca,'xtick',xtick)
xticklabel = {'Opposite\nzone' 'Opposite\nfeeder' 'Last\nzone' 'Last\nfeeder' 'Current\nzone' 'Current\nfeeder' 'Next\nzone' 'Next\nfeeder' 'Opposite\nzone'};
set(gca,'xticklabel',[])
set(gca,'xlim',[-pi-binw/2 pi+binw/2])
set(gca,'ylim',[0 max(pAll(:))])
ylim = get(gca,'ylim');
for iTick = 2 :2: length(xticklabel)
    th=text(xtick(iTick),ylim(2),sprintf(xticklabel{iTick}));
    set(th,'VerticalAlignment','Bottom')
    set(th,'HorizontalAlignment','Center')
end
hold off

subplot(5,1,2)
hold on
s = nanstderr(pRegret(idVeh,:));
s = s';
m = nanmean(pRegret(idVeh,:),1);
m = m';
eh=errorbar(theta,m,s);
set(eh,'linestyle','none')
hold on
bh=bar(theta,m,1);
legend(get(bh,'children'),'Regret')
hold off
xtick = [-pi -3/4*pi -pi/2 -pi/4 0 pi/4 pi/2 3/4*pi pi];
set(gca,'xtick',xtick)
xticklabel = {'Opposite\nzone' 'Opposite\nfeeder' 'Last\nzone' 'Last\nfeeder' 'Current\nzone' 'Current\nfeeder' 'Next\nzone' 'Next\nfeeder' 'Opposite\nzone'};
set(gca,'xticklabel',[])
set(gca,'xlim',[-pi-binw/2 pi+binw/2])
set(gca,'ylim',[0 max(pAll(:))])
hold off

subplot(5,1,3)
hold on
s = nanstderr(pDisapp1(idVeh,:));
s = s';
m = nanmean(pDisapp1(idVeh,:),1);
m = m';
eh=errorbar(theta,m,s);
set(eh,'linestyle','none')
hold on
bh=bar(theta,m,1);
legend(get(bh,'children'),'Disappointment')
hold off
xtick = [-pi -3/4*pi -pi/2 -pi/4 0 pi/4 pi/2 3/4*pi pi];
set(gca,'xtick',xtick)
xticklabel = {'Opposite\nzone' 'Opposite\nfeeder' 'Last\nzone' 'Last\nfeeder' 'Current\nzone' 'Current\nfeeder' 'Next\nzone' 'Next\nfeeder' 'Opposite\nzone'};
set(gca,'xticklabel',[])
set(gca,'xlim',[-pi-binw/2 pi+binw/2])
set(gca,'ylim',[0 max(pAll(:))])
hold off

subplot(5,1,4)
hold on
s = nanstderr(pDisapp2(idVeh,:));
s = s';
m = nanmean(pDisapp2(idVeh,:),1);
m = m';
eh=errorbar(theta,m,s);
set(eh,'linestyle','none')
hold on
bh=bar(theta,m,1);
legend(get(bh,'children'),'Bad luck')
hold off
xtick = [-pi -3/4*pi -pi/2 -pi/4 0 pi/4 pi/2 3/4*pi pi];
set(gca,'xtick',xtick)
xticklabel = {'Opposite\nzone' 'Opposite\nfeeder' 'Last\nzone' 'Last\nfeeder' 'Current\nzone' 'Current\nfeeder' 'Next\nzone' 'Next\nfeeder' 'Opposite\nzone'};
set(gca,'xticklabel',[])
set(gca,'xlim',[-pi-binw/2 pi+binw/2])
set(gca,'ylim',[0 max(pAll(:))])
hold off

subplot(5,1,5)
hold on
s = nanstderr(pRejoice(idVeh,:));
s = s';
m = nanmean(pRejoice(idVeh,:),1);
m = m';
eh=errorbar(theta,m,s);
set(eh,'linestyle','none')
hold on
bh=bar(theta,m,1);
legend(get(bh,'children'),'Rejoice')
hold off
xtick = [-pi -3/4*pi -pi/2 -pi/4 0 pi/4 pi/2 3/4*pi pi];
set(gca,'xtick',xtick)
xticklabel = {'Opposite\nzone' 'Opposite\nfeeder' 'Last\nzone' 'Last\nfeeder' 'Current\nzone' 'Current\nfeeder' 'Next\nzone' 'Next\nfeeder' 'Opposite\nzone'};
set(gca,'xticklabel',[])
set(gca,'xlim',[-pi-binw/2 pi+binw/2])
set(gca,'ylim',[0 max(pAll(:))])
for iTick = 1 :2: length(xticklabel)
    th=text(xtick(iTick),0,sprintf(xticklabel{iTick}));
    set(th,'VerticalAlignment','Top')
    set(th,'HorizontalAlignment','Center')
end
hold off
%%
figure;
subplot(5,1,1)
title('CNO CA1')
hold on
theta = linspace(-pi,pi,64)';
binw = mean(diff(theta));

s = nanstderr(pAll(idCNO,:));
s = s';
m = nanmean(pAll(idCNO,:),1);
m = m';
eh=errorbar(theta,m,s);
set(eh,'linestyle','none')
hold on
bh=bar(theta,m,1);
legend(get(bh,'children'),'All entries')
hold off
xtick = [-pi -3/4*pi -pi/2 -pi/4 0 pi/4 pi/2 3/4*pi pi];
set(gca,'xtick',xtick)
xticklabel = {'Opposite\nzone' 'Opposite\nfeeder' 'Last\nzone' 'Last\nfeeder' 'Current\nzone' 'Current\nfeeder' 'Next\nzone' 'Next\nfeeder' 'Opposite\nzone'};
set(gca,'xticklabel',[])
set(gca,'xlim',[-pi-binw/2 pi+binw/2])
set(gca,'ylim',[0 max(pAll(:))])
ylim = get(gca,'ylim');
for iTick = 2 :2: length(xticklabel)
    th=text(xtick(iTick),ylim(2),sprintf(xticklabel{iTick}));
    set(th,'VerticalAlignment','Bottom')
    set(th,'HorizontalAlignment','Center')
end
hold off

subplot(5,1,2)
hold on
s = nanstderr(pRegret(idCNO,:));
s = s';
m = nanmean(pRegret(idCNO,:),1);
m = m';
eh=errorbar(theta,m,s);
set(eh,'linestyle','none')
hold on
bh=bar(theta,m,1);
legend(get(bh,'children'),'Regret')
hold off
xtick = [-pi -3/4*pi -pi/2 -pi/4 0 pi/4 pi/2 3/4*pi pi];
set(gca,'xtick',xtick)
xticklabel = {'Opposite\nzone' 'Opposite\nfeeder' 'Last\nzone' 'Last\nfeeder' 'Current\nzone' 'Current\nfeeder' 'Next\nzone' 'Next\nfeeder' 'Opposite\nzone'};
set(gca,'xticklabel',[])
set(gca,'xlim',[-pi-binw/2 pi+binw/2])
set(gca,'ylim',[0 max(pAll(:))])
hold off

subplot(5,1,3)
hold on
s = nanstderr(pDisapp1(idCNO,:));
s = s';
m = nanmean(pDisapp1(idCNO,:),1);
m = m';
eh=errorbar(theta,m,s);
set(eh,'linestyle','none')
hold on
bh=bar(theta,m,1);
legend(get(bh,'children'),'Disappointment')
hold off
xtick = [-pi -3/4*pi -pi/2 -pi/4 0 pi/4 pi/2 3/4*pi pi];
set(gca,'xtick',xtick)
xticklabel = {'Opposite\nzone' 'Opposite\nfeeder' 'Last\nzone' 'Last\nfeeder' 'Current\nzone' 'Current\nfeeder' 'Next\nzone' 'Next\nfeeder' 'Opposite\nzone'};
set(gca,'xticklabel',[])
set(gca,'xlim',[-pi-binw/2 pi+binw/2])
set(gca,'ylim',[0 max(pAll(:))])
hold off

subplot(5,1,4)
hold on
s = nanstderr(pDisapp2(idCNO,:));
s = s';
m = nanmean(pDisapp2(idCNO,:),1);
m = m';
eh=errorbar(theta,m,s);
set(eh,'linestyle','none')
hold on
bh=bar(theta,m,1);
legend(get(bh,'children'),'Bad luck')
hold off
xtick = [-pi -3/4*pi -pi/2 -pi/4 0 pi/4 pi/2 3/4*pi pi];
set(gca,'xtick',xtick)
xticklabel = {'Opposite\nzone' 'Opposite\nfeeder' 'Last\nzone' 'Last\nfeeder' 'Current\nzone' 'Current\nfeeder' 'Next\nzone' 'Next\nfeeder' 'Opposite\nzone'};
set(gca,'xticklabel',[])
set(gca,'xlim',[-pi-binw/2 pi+binw/2])
set(gca,'ylim',[0 max(pAll(:))])
hold off

subplot(5,1,5)
hold on
s = nanstderr(pRejoice(idCNO,:));
s = s';
m = nanmean(pRejoice(idCNO,:),1);
m = m';
eh=errorbar(theta,m,s);
set(eh,'linestyle','none')
hold on
bh=bar(theta,m,1);
legend(get(bh,'children'),'Rejoice')
hold off
xtick = [-pi -3/4*pi -pi/2 -pi/4 0 pi/4 pi/2 3/4*pi pi];
set(gca,'xtick',xtick)
xticklabel = {'Opposite\nzone' 'Opposite\nfeeder' 'Last\nzone' 'Last\nfeeder' 'Current\nzone' 'Current\nfeeder' 'Next\nzone' 'Next\nfeeder' 'Opposite\nzone'};
set(gca,'xticklabel',[])
set(gca,'xlim',[-pi-binw/2 pi+binw/2])
set(gca,'ylim',[0 max(pAll(:))])
for iTick = 1 :2: length(xticklabel)
    th=text(xtick(iTick),0,sprintf(xticklabel{iTick}));
    set(th,'VerticalAlignment','Top')
    set(th,'HorizontalAlignment','Center')
end
hold off

