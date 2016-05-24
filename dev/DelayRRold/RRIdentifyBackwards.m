function VEH = RRIdentifyBackwards(VEH,varargin)
% identifies trials on which the rat went backward and indicates the
% timestamp corresponding to the time the rat unambiguously enters the
% previous zone and the time the rat unambiguously leaves the previous
% zone.
% VEH = RRIdentifyBackwards(VEH)
% where         VEH             is a structure with added fields:
%                   .idGlitch        is nSess x nTrials matrix of glitches
%                                   in tracking.
%                   .idBackward      is nSess x nTrials matrix with trials on
%                                   which the rat went back one zone.
%                   .startBackward   is nSess x nTrials matrix with time stamps
%                                   of entry into previous zone.
%                   .leaveBackward   is nSess x nTrials matrix with time stamps
%                                   of exit from previous zone.
%
%               VEH             is a structure produced by the
%                                   wrap_RR_analysis function with RRow
%                                   data.
%
% OPTIONAL ARGUMENTS:
% ******************
% Bounds    (default is {[720   0] [nan nan];
%                        [720 nan] [nan 480];
%                        [nan nan] [0   480];
%                        [nan   0] [0   nan]};)
%                               lower right, upper left [x y] coordinates
%                               of each zone. NaNs indicate use of mean
%                               coordinate when rat is said to have
%                               entered.
% thresh    (default is 2)
%                               number of seconds in previous zone to
%                               establish the rat went backwards.
% extendedZone (default is 60)
%                               number of pixels to extend current zone
%                               boundaries before establishing rat is in
%                               previous zone.

% F = {[568 4];
%      [577 448];
%      [119 453];
%      [107 19]}; % x,y locations of feeders for each zone.
Bounds = {[720   0] [nan nan];
          [720 nan] [nan 480];
          [nan nan] [0   480];
          [nan   0] [0   nan]};
debug=false;
thresh=2;
extendedZone = 60;
process_varargin(varargin);
nFeeders = size(Bounds,1);

nvt = cell(size(VEH.fn,1),1);
disp('Finding NVT files.')
toDelete = cell(0,1);
for f = 1 : size(VEH.fn,1)
    fn = VEH.fn{f};
    fd = fileparts(fn);
    
    pushdir(fd);
    disp(fd)
    nvtfn = FindFiles('*.nvt');
    if isempty(nvtfn)
        contentsPre = FindFiles('*.*','CheckSubdirs',false);
        zipfiles = FindFiles('*.zip','CheckSubdirs',false);
        for iZ = 1 : length(zipfiles)
            unzip(zipfiles{iZ});
        end
        nvtfn = FindFiles('*.nvt','CheckSubdirs',false);
        contentsPost = FindFiles('*.*','CheckSubdirs',false);
        zipContents = contentsPost(~ismember(contentsPost,contentsPre));
        toDelete = cat(1,toDelete,zipContents);
    end
    if ~isempty(nvtfn)
        nvt{f} = nvtfn{1};
    end
    
    popdir;
end

disp('Processing nvt files for x,y location of zone entry point')
xEntry = nan(size(VEH.zones));
yEntry = nan(size(VEH.zones));
for f = 1 : length(nvt)
    if ~isempty(nvt{f})
        fd = fileparts(nvt{f});
        pushdir(fd);
        disp(fd)
        [x,y] = LoadVT_lumrg(nvt{f});
        dt = mean([x.dt y.dt]);
        
        zones = VEH.zones(f,:);
        nTrials = find(~isnan(zones),1,'last');
        
        for iT = 1 : nTrials
            x0 = x.restrict(VEH.EnteringZoneTime(iT)-dt,VEH.EnteringZoneTime(iT)+dt);
            y0 = y.restrict(VEH.EnteringZoneTime(iT)-dt,VEH.EnteringZoneTime(iT)+dt);
            xEntry(f,iT) = nanmean(x0.data);
            yEntry(f,iT) = nanmean(y0.data);
        end
        popdir;
    end
end

disp('Boundaries of zones...')
uniqueZones = unique(VEH.zones(~isnan(VEH.zones)));
zoneEntryX = nan(1,length(uniqueZones));
zoneEntryY = nan(1,length(uniqueZones));
for iZ = 1 : length(uniqueZones)
    idZ = uniqueZones(iZ)==VEH.zones;
    zoneEntryX(iZ) = nanmean(xEntry(idZ));
    zoneEntryY(iZ) = nanmean(yEntry(idZ));
end
if debug
    figure(1);
    clf
    set(gca,'xlim',[0 720])
    set(gca,'ylim',[0 480])
end
BoundX = nan(2,size(Bounds,1));
BoundY = nan(2,size(Bounds,1));
Fxy = nan(2,size(Bounds,1));
for iZ = 1 : size(Bounds,1)
    LR = Bounds{iZ,1};
    UL = Bounds{iZ,2};
    if isnan(LR(1))
        LR(1) = zoneEntryX(iZ);
    end
    if isnan(UL(1))
        UL(1) = zoneEntryX(iZ);
    end
    if isnan(LR(2))
        LR(2) = zoneEntryY(iZ);
    end
    if isnan(UL(2))
        UL(2) = zoneEntryY(iZ);
    end
    if debug
        hold on
        ph=patch([LR(1) LR(1) UL(1) UL(1)],[LR(2) UL(2) UL(2) LR(2)],[1 1 1]);
        set(get(ph,'children'),'facealpha',0.3);
        set(get(ph,'children'),'edgecolor',[0 0 0]);
        set(get(ph,'children'),'facecolor',[1 1 1]);
        text(mean([LR(1) UL(1)]),mean([LR(2) UL(2)]),sprintf('Zone %d',iZ));
        hold off
    end
    BoundX(:,iZ) = [UL(1); LR(1)];
    BoundY(:,iZ) = [UL(2); LR(2)];
%     F{iZ} = [nanmean(BoundX(:,iZ)) nanmean(BoundY(:,iZ))];
    Fxy(:,iZ) = [nanmean(BoundX(:,iZ)); nanmean(BoundY(:,iZ))];
end


disp('Processing nvt files for backwards times.')
startBackward = nan(size(VEH.EnteringZoneTime));
leaveBackward = nan(size(VEH.EnteringZoneTime));
idBackward = nan(size(VEH.EnteringZoneTime));
idGlitch = nan(size(VEH.EnteringZoneTime));
for f = 1 : length(nvt)
    if ~isempty(nvt{f})
        fd = fileparts(nvt{f});
        pushdir(fd);
        disp(fd)
        idDelim = regexp(fd,'\');
        SSN = fd(max(idDelim)+1:end);
        
        [x,y] = LoadVT_lumrg(nvt{f});
        dt = mean([x.dt y.dt]);
        
        enteringZoneTime = VEH.EnteringZoneTime(f,:);
        exitZoneTime = VEH.ExitZoneTime(f,:);
        zones = VEH.zones(f,:);
        delays = VEH.delays(f,:);
        thresholds = VEH.thresholdByTrial(f,:);
        staygo = VEH.staygo(f,:);
        shouldstay = VEH.ShouldStay(f,:);
        
        zoneList = zones(1:nFeeders);
        prevList = nan(size(zoneList));
        prevList(2:end) = zoneList(1:end-1);
        prevList(1) = zoneList(end);
        
        load(VEH.fn{f});
        nTrials = min(length(enteringZoneTime),length(exitZoneTime));
        for trial = 1 : nTrials
            if ~isnan(enteringZoneTime(trial)) && ~isnan(exitZoneTime(trial));
                xT = x.restrict(enteringZoneTime(trial)-dt,exitZoneTime(trial)+dt);
                yT = y.restrict(enteringZoneTime(trial)-dt,exitZoneTime(trial)+dt);
                xy = [xT.data yT.data];
                t = xT.range;

                n = size(xy,1);
                inZone = false(n,nFeeders);
                inZoneExt = false(n,nFeeders);
                for iZ = 1 : nFeeders
                    inZone(:,iZ) = xy(:,1)>=min(BoundX(:,iZ)) &  xy(:,1)<=max(BoundX(:,iZ)) &  xy(:,2)>=min(BoundY(:,iZ)) & xy(:,2)<=max(BoundY(:,iZ));
                    inZoneExt(:,iZ) = xy(:,1)>=min(BoundX(:,iZ))-extendedZone &  xy(:,1)<=max(BoundX(:,iZ))+extendedZone &  xy(:,2)>=min(BoundY(:,iZ))-extendedZone & xy(:,2)<=max(BoundY(:,iZ))+extendedZone;
                end
                
                curZone = inZoneExt(:,zones(trial))==1;
                lastZone = inZone(:,prevList(zones(trial)))==1;
                
                firstEntryZone = find(curZone&~lastZone,1,'first');
                
                if debug
                    figure(1);
                    clf
                    plot(xT.data,yT.data,'k.','markersize',1)
                    hold on

                    set(gca,'xlim',[0 720])
                    set(gca,'ylim',[0 480])
                    set(gca,'xcolor','w')
                    set(gca,'ycolor','w')
                    set(gca,'xtick',[])
                    set(gca,'ytick',[])
                    title(sprintf('%s trial %d',SSN,trial));
                    hold off
                    drawnow
                end
                
                if ~isempty(firstEntryZone)
                    firstEntryPrev = find(~curZone&lastZone&(1:n)'>=firstEntryZone,1,'first');
                    if ~isempty(firstEntryPrev)
                        firstExitPrev = find(curZone&~lastZone&(1:n)'>=firstEntryPrev,1,'first');
                        if isempty(firstExitPrev)
                            firstExitPrev=find(~curZone&lastZone&(1:n)'>=firstEntryPrev,1,'last');
                        end
                        tInPrev = t(firstExitPrev)-t(firstEntryPrev);
                        if tInPrev<thresh
                            firstEntryPrev = [];
                            firstExitPrev = [];
                        end
                    end
                end
                tInZone = max(t(curZone))-min(t(curZone));
                if tInZone<0.9 || isempty(firstEntryZone)
                    firstEntryPrev = [];
                    firstExitPrev = [];
                    idGlitch(f,trial) = 1;
                else
                    idGlitch(f,trial) = 0;
                end
                
                if ~isempty(firstEntryPrev)
                    firstEntryPrev = find(lastZone&(1:n)'>=firstEntryZone,1,'first');

                    disp(sprintf('Backwards trial found on trial %d.',trial));
                    tBack = t(firstEntryPrev:firstExitPrev);
                    tIn = t(firstEntryZone:firstEntryPrev-1);
                    startBackward(f,trial) = min(tBack);
                    leaveBackward(f,trial) = max(tBack);
                    idBackward(f,trial) = 1;
                    xBack = xT.restrict(min(tBack),max(tBack));
                    yBack = yT.restrict(min(tBack),max(tBack));
                    xCur = xT.restrict(min(tIn),max(tIn));
                    yCur = yT.restrict(min(tIn),max(tIn));
                    figure;
                    cla
                    plot(x.data,y.data,'.','markerfacecolor',[0.7 0.7 0.7],'markeredgecolor',[0.7 0.7 0.7])
                    
                    hold on
                    th=text(Fxy(1,zones(trial)),Fxy(2,zones(trial)),sprintf('D=%.1fs\n\\theta=%.1fs',delays(trial),thresholds(trial)));
                    set(th,'fontsize',14);set(th,'fontname','Arial');
                    if trial>1
                        if staygo(trial-1)==1
                            th=text(Fxy(1,prevList(zones(trial))),Fxy(2,prevList(zones(trial))),sprintf('D=%.1fs\n\\theta=%.1fs\n(Stayed)',delays(trial-1),thresholds(trial-1)));
                        elseif staygo(trial-1)==0
                            % skipped zone he's backing up to.
                            if shouldstay(trial-1)==1
                                % should have stayed.
                                th=text(Fxy(1,prevList(zones(trial))),Fxy(2,prevList(zones(trial))),sprintf('D=%.1fs*\n\\theta=%.1fs\n(Skipped)',delays(trial-1),thresholds(trial-1)));
                            elseif shouldstay(trial-1)==0
                                % should have skipped.
                                th=text(Fxy(1,prevList(zones(trial))),Fxy(2,prevList(zones(trial))),sprintf('D=%.1fs\n\\theta=%.1fs\n(Skipped)',delays(trial-1),thresholds(trial-1)));
                            end
                        end
                        set(th,'fontsize',14);set(th,'fontname','Arial');
                    end
                    plot(xT.data,yT.data,'k.','markersize',1)

                    set(gca,'xlim',[0 720])
                    set(gca,'ylim',[0 480])
                    set(gca,'xcolor','w')
                    set(gca,'ycolor','w')
                    set(gca,'xtick',[])
                    set(gca,'ytick',[])
                   
                    plot(xBack.data,yBack.data,'r.','markersize',10)
                    plot(xCur.data,yCur.data,'g.','markersize',10)
                    
                    LR = [BoundX(2,zones(trial))+extendedZone BoundY(2,zones(trial))-extendedZone];
                    UL = [BoundX(1,zones(trial))-extendedZone BoundY(1,zones(trial))+extendedZone];
                    ph=patch([LR(1) LR(1) UL(1) UL(1)],[LR(2) UL(2) UL(2) LR(2)],[1 1 1]);
                    set(ph,'facealpha',0.3);
                    set(ph,'edgecolor',[0 1 0]);
                    set(ph,'facecolor',[1 1 1]);
                    set(ph,'linestyle',':')
                    set(ph,'linewidth',1)
                    LR = [BoundX(2,prevList(zones(trial))) BoundY(2,prevList(zones(trial)))];
                    UL = [BoundX(1,prevList(zones(trial))) BoundY(1,prevList(zones(trial)))];
                    ph=patch([LR(1) LR(1) UL(1) UL(1)],[LR(2) UL(2) UL(2) LR(2)],[1 1 1]);
                    set(ph,'facealpha',0.3);
                    set(ph,'edgecolor',[1 0 0]);
                    set(ph,'facecolor',[1 1 1]);
                    set(ph,'linestyle',':')
                    set(ph,'linewidth',1)
                    title(sprintf('%s trial %d',SSN,trial));
                    hold off
                    drawnow
                    saveas(gcf,[SSN sprintf('-trial%d-Backwards.fig',trial)],'fig')
                    saveas(gcf,[SSN sprintf('-trial%d-Backwards.eps',trial)],'epsc')
                else
                    idBackward(f,trial) = 0;
                end
            end
        end
        
        popdir;
    end
end
VEH.idBackward = idBackward;
VEH.idGlitch = idGlitch;
VEH.startBackward = startBackward;
VEH.leaveBackward = leaveBackward;

disp('Cleaning up extracted files...')
for iZ = 1 : length(toDelete)
    delete(toDelete{iZ});
end