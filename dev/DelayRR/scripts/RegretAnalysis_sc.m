sd = RRinit;
%%
CoM = [nanmean(sd.x.data) nanmean(sd.y.data)];
theta = tsd(sd.x.range,atan2(sd.y.data-CoM(2),sd.x.data-CoM(1)));

idTT = RRassignTetrodeClusters(sd);

TC = TuningCurves(sd.S(idTT(1,:)),theta);

Q = MakeQfromS(sd.S(idTT(1,:)),0.125);
B = BayesianDecoding(Q,TC);

%%
regret = RRGetRegret(sd);
disapp = RRGetDisappointment(sd);
rejoice = RRGetRejoice(sd);

Tregret = sd.EnteringZoneTime(regret(1:length(sd.ZoneIn))==1);
Tdisapp1 = sd.EnteringZoneTime(disapp.Disapp1(1:length(sd.ZoneIn))==1);
Tdisapp2 = sd.EnteringZoneTime(disapp.Disapp2(1:length(sd.ZoneIn))==1);
Trejoice = sd.EnteringZoneTime(rejoice(1:length(sd.ZoneIn))==1);

%%
figure;
RRplotAngularDecoding(B,theta,Tregret);
ylim=get(gca,'ylim');
xlim=get(gca,'xlim');
th=text(xlim(1),ylim(2),'Regret');
set(th,'fontweight','bold')
set(th,'VerticalAlignment','top')
set(th,'HorizontalAlignment','left')
set(gca,'xGrid','on')
set(gca,'box','off')

%%
figure;
RRplotAngularDecoding(B,theta,Tdisapp1);
ylim=get(gca,'ylim');
xlim=get(gca,'xlim');
th=text(xlim(1),ylim(2),'Disappointment');
set(th,'fontweight','bold')
set(th,'VerticalAlignment','top')
set(th,'HorizontalAlignment','left')
set(gca,'xGrid','on')
set(gca,'box','off')

%%
figure;
RRplotAngularDecoding(B,theta,Tdisapp2);
ylim=get(gca,'ylim');
xlim=get(gca,'xlim');
th=text(xlim(1),ylim(2),'Bad luck');
set(th,'fontweight','bold')
set(th,'VerticalAlignment','top')
set(th,'HorizontalAlignment','left')
set(gca,'xGrid','on')
set(gca,'box','off')

%%
figure;
RRplotAngularDecoding(B,theta,Trejoice);
ylim=get(gca,'ylim');
xlim=get(gca,'xlim');
th=text(xlim(1),ylim(2),'Rejoice');
set(th,'fontweight','bold')
set(th,'VerticalAlignment','top')
set(th,'HorizontalAlignment','left')
set(gca,'xGrid','on')
set(gca,'box','off')

%%
figure;
RRplotAngularDecoding(B,theta,sd.EnteringZoneTime);
ylim=get(gca,'ylim');
xlim=get(gca,'xlim');
th=text(xlim(1),ylim(2),'All Zone Entries');
set(th,'fontweight','bold')
set(th,'VerticalAlignment','top')
set(th,'HorizontalAlignment','left')
set(gca,'xGrid','on')
set(gca,'box','off')
