function fh=wrap_RR_stayDuration2DHist(analysisStruct,varargin)
%
%
%
%
%

titleStr = '';
figs = get(0,'children');
if isempty(figs)
    lastFig = 0;
else
    lastFig = max(figs);
end
fh = [lastFig+1];
process_varargin(varargin);

zones = analysisStruct.zones;
delays = analysisStruct.delays;
EnteringZoneTime = analysisStruct.EnteringZoneTime;
ExitZoneTime = analysisStruct.ExitZoneTime;
nTrials = min(length(ExitZoneTime),length(EnteringZoneTime));

delays = delays(:,1:nTrials);
zones = zones(:,1:nTrials);
EnteringZoneTime = EnteringZoneTime(:,1:nTrials);
ExitZoneTime = ExitZoneTime(:,1:nTrials);
stayDuration = ExitZoneTime - EnteringZoneTime;
anomaly = stayDuration>delays;
stayDuration(anomaly) = delays(anomaly);

figure(fh);
for iZ = 1 : 4
    subplot(2,2,iZ);
    cla
    hold on
    if ~isempty(titleStr)
        title([titleStr ': ' sprintf('Zone %d',iZ)])
    else
        title(sprintf('Zone %d',iZ))
    end
    delayList = unique(delays(zones==iZ));
    stayList = 1:max(delays(zones==iZ));
    HA = histcn([stayDuration(zones==iZ) delays(zones==iZ)],delayList,stayList);
    HS = repmat(sum(HA,1),size(HA,1),1);
    imagesc(delayList,stayList,HA./HS);
    axis xy
    xlabel('Delay (s)')
    ylabel('Stay duration (s)')
    caxis([0 1])
    cbh=colorbar;
    set(get(cbh,'ylabel'),'string','Proportion of laps at delay')
    set(get(cbh,'ylabel'),'rotation',-90)
    set(gca,'xlim',[min(delayList) max(delayList)])
    set(gca,'ylim',[min(stayList) max(stayList)])
    hold off
end