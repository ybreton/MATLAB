fn = FindFiles('RR-*.mat');
fd = cell(length(fn),1);
for iF=1:length(fn); fd{iF}=fileparts(fn{iF}); end;
fd = unique(fd);
%%
nBins = 64;
nTrls = nan(length(fd),1);
for iD = 1 : length(fd)
    pushdir(fd{iD});
    disp(fd{iD});
    
    sd = RRInit;
    sd.Tones = RRtones(sd);
    nTrls(iD) = length(sd.ZoneIn);
    sdList(iD) = sd;
    popdir;
end
maxTrls = max(nTrls);

%%
Condition = cell(length(fd),1);
nCells = nan(length(fd),1);
for iD=1:length(sdList)
    disp(fd{iD})
    pushdir(fd{iD});
    
    fdStr = fd{iD};
    idDelim = regexpi(fdStr,'\');
    SSN = fdStr(max(idDelim)+1:end);
    sd = sdList(iD);
    
    Condition{iD} = sd(1).ExpKeys.Condition;
    
    sd.x = sd.x.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);
    sd.y = sd.y.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);
    [sd.x,sd.y] = RRcentreMaze(sd);
    sd = RRFindQuadrant(sd);
    sd = RRrotateXYalign(sd);
    
    idTT = RRassignTetrodeClusters(sd);
    ISI = nan(length(sd.S),1);
    spikes = nan(length(sd.S),1);
    for iC=1:length(sd.S);
        ISI(iC) = nanmean(diff(sd.S{iC}.data));
        spikes(iC) = length(data(sd.S{iC}.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack)));
    end
    idInterNrn = ISI<0.5;
    idSpks = spikes>=40;
    idHC = idTT(1,:)';
    
    S = sd.S(idHC&~idInterNrn(:)&idSpks(:));
    nCells(iD) = length(S);
    
    TC(iD) = TuningCurves(S,{{sd.x -250 250 nBins} {sd.y -250 250 nBins} {sd.Tones 30}});
    TCxy = TuningCurves(S,{{sd.x -250 250 nBins} {sd.y -250 250 nBins}});
    
    figure(1);
    clf
    nP = ceil(sqrt(size(TCxy.H,1)+1));
    x = linspace(TCxy.min(1),TCxy.max(1),TCxy.nBin(1));
    y = linspace(TCxy.min(2),TCxy.max(2),TCxy.nBin(2));
    [X,Y] = meshgrid(x,y);
    for iP=1:size(TCxy.H,1);
        subplot(nP,nP,iP)
        imagesc(x,y,squeeze(TCxy.H(iP,:,:))'./TCxy.Occ');
        hold on
        contour(X,Y,TCxy.Occ',[0 0],'w-')
        hold off
        axis xy
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        axis([-250 250 -250 250])
    end
    subplot(nP,nP,nP.^2)
    pos=get(gca,'position');
    pos(3) = pos(3)/4;
    pos(1) = pos(1)+3*pos(3);
    cbh=colorbar;
    set(cbh,'position',pos)
    set(get(cbh,'xlabel'),'string',sprintf('Occ-normed tuning'));
    set(gca,'visible','off')
    
    set(gcf,'name',sprintf('Overall spatial tuning %s - %s',SSN,Condition{iD}))
    saveas(gcf,[SSN '-TuningXY_byCell.fig'])
    drawnow
    
    figure(2);
    clf
    nP = ceil(sqrt(size(TC(iD).H,1)+1));
    x = linspace(TC(iD).min(1),TC(iD).max(1),TC(iD).nBin(1));
    y = linspace(TC(iD).min(2),TC(iD).max(2),TC(iD).nBin(2));
    [X,Y] = meshgrid(x,y);
    
    for iP=1:size(TC(iD).H,1);
        subplot(nP,nP,iP)
        plot(sd.x.data,sd.y.data,'.','markerfacecolor',[0.8 0.8 0.8],'markeredgecolor',[0.8 0.8 0.8],'markersize',1);
        hold on
        plot(sd.x.data(S{iP}.data),sd.y.data(S{iP}.data),'.k','markersize',5)
        if ~isempty(sd.x.data(S{iP}.data(sd.Tones.range)))
            scatterplotc(sd.x.data(S{iP}.data(sd.Tones.range)),sd.y.data(S{iP}.data(sd.Tones.range)),sd.Tones.data(S{iP}.data(sd.Tones.range)),'crange',[TC(iD).min(3) TC(iD).max(3)],'NumColors',TC(iD).nBin(3),'plotchar','.')
        end
        hold off
        axis xy
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        axis([-250 250 -250 250])
    end
    subplot(nP,nP,nP.^2)
    pos=get(gca,'position');
    pos(3) = pos(3)/4;
    pos(1) = pos(1)+3*pos(3);
    cbh=colorbar;
    set(cbh,'position',pos)
    set(get(cbh,'xlabel'),'string',sprintf('Delay signalled by tone'));
    set(gca,'visible','off')
    
    set(gcf,'name',sprintf('XY/tone firing %s - %s',SSN,Condition{iD}))
    saveas(gcf,[SSN '-XYfiring_byTone_byCell.fig'])
    drawnow
    
%     figure(3);
%     clf
%     nP = ceil(sqrt(size(TC(iD).H,1)));
%     x = linspace(TC(iD).min(1),TC(iD).max(1),TC(iD).nBin(1));
%     y = linspace(TC(iD).min(2),TC(iD).max(2),TC(iD).nBin(2));
%     [X,Y] = meshgrid(x,y);
%     cmap = jet(30);
%     for iP=1:size(TC(iD).H,1);
%         subplot(nP,nP,iP)
%         plot3(sd.x.data,sd.y.data,ones(length(sd.x.data),1)*TC(iD).min(3),'.','markerfacecolor',[0.8 0.8 0.8],'markeredgecolor',[0.8 0.8 0.8],'markersize',1);
%         spikeTimes = S{iP}.data;
%         toneSpikes = S{iP}.data(sd.Tones.range);
%         travelSpikes = spikeTimes(~ismember(spikeTimes,toneSpikes));
%         
%         hold on
%         if ~isempty(travelSpikes)
%             plot3(sd.x.data(travelSpikes),sd.y.data(travelSpikes),ones(length(sd.x.data(travelSpikes)),1)*TC(iD).min(3),'.k','markersize',5)
%         end
%         if ~isempty(toneSpikes)
%             plot3(sd.x.data(toneSpikes),sd.y.data(toneSpikes),sd.Tones.data(toneSpikes),'.');
%         end
%         hold off
%         axis xy
%         set(gca,'xtick',[])
%         set(gca,'ytick',[])
%         set(gca,'ztick',[TC(iD).min(3) TC(iD).max(3)])
%         axis([-250 250 -250 250 TC(iD).min(3) TC(iD).max(3)])
%     end
%     
%     set(gcf,'name',sprintf('X-Y-tone firing %s - %s',SSN,Condition{iD}))
%     saveas(gcf,[SSN '-XYToneFiring_byCell.fig'])
%     drawnow
    
    popdir;
end