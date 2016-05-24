function fh = RRplotStayDuration2DHists(sdfn,varargin)
%
%
%
%

if isempty(max(get(0,'children')));
    lastFig = 0;
else
    lastFig = max(get(0,'children'));
end
fh = [lastFig+1 lastFig+2];
process_varargin(varargin);
if nargin<1
    sdfn = FindFiles('*-sd.mat');
end
figure(fh(1));
figure(fh(2));

EnteringZoneTime = RRGetField(sdfn,'EnteringZoneTime');
ExitZoneTime = RRGetField(sdfn,'ExitZoneTime');
maxTrls = min(size(EnteringZoneTime,2),size(ExitZoneTime,2));

stayDuration = ExitZoneTime(:,1:maxTrls) - EnteringZoneTime(:,1:maxTrls);
delays = RRGetDelays(sdfn);
delays = delays(:,1:maxTrls);

anomaly = stayDuration>delays;
stayDuration(anomaly) = delays(anomaly);

drugs = RRGetDrugs(sdfn);
idCNO = strcmpi(drugs,'Drug') | strcmpi(drugs,'CNO');

CNOstays = stayDuration(idCNO,:);
SALstays = stayDuration(~idCNO,:);
CNOdelay = delays(idCNO,:);
SALdelay = delays(~idCNO,:);

figure(fh(1));
CNOh = histcn([CNOstays(:) CNOdelay(:)],[1:30],[1:30]);
imagesc([1:30],[1:30],CNOh./repmat(sum(CNOh),size(CNOh,1),1));
title('CNO stay durations')
xlabel('Delay')
ylabel('Stay duration')
cbh=colorbar;
set(get(cbh,'ylabel'),'string','Proportion of trials for delay')
set(get(cbh,'ylabel'),'rotation',-90)
caxis([0 1])
axis xy

figure(fh(2));
SALh = histcn([SALstays(:) SALdelay(:)],[1:30],[1:30]);
imagesc([1:30],[1:30],SALh./repmat(sum(SALh),size(SALh,1),1));
title('Vehicle stay durations')
xlabel('Delay')
ylabel('Stay duration')
cbh=colorbar;
set(get(cbh,'ylabel'),'string','Proportion of trials for delay')
set(get(cbh,'ylabel'),'rotation',-90)
caxis([0 1])
axis xy
