function [X,Y,fh]=RRplotCPpasses(fn,varargin)
% Produces structures X,Y with fields for x and y position and time stamps,
% aligned to zone entry point and rotated so the feeder is in the upper
% right and the next zone is mid-left.
% Also plots the trajectory on all passes through choice points for each
% zone and for all zones together.
%
% [X,Y,fh]=RRplotCPpasses(fn)
% where     X,Y             are structures with fields
%               .data       nSess x nZones x nTrials x nTimestamps matrix
%                               of X (or Y) positions aligned to zone entry
%                               X (or Y) and rotated appropriately.
%               .time       nSess x nZones x nTrials x nTimestamps matrix
%                               of time stamps of the above-mentioned
%                               positions.
%           fh              is a vector of handles to produced figures.
%
%           fn              is an nSess x 1 cell array of sd files for
%                               pulling the restaurant row data.
%
% OPTIONAL ARGUMENTS:
% ******************
% rotations     (default is {[0 -1] [1  0];
%                            [1  0] [0  1];
%                            [0  1] [-1 0];
%                            [-1 0] [0 -1]})
%               nZones x 2 cell array defines the linear combinations of X
%                   and Y positions to rotate the positions. The rotated x
%                   value is given by unrotated x * cell 1, sub-element 1 +
%                   unrotated y * cell 1, sub-element 2. The rotated y
%                   value is given by unrotated x * cell 2, sub-element 1 +
%                   unrotated y * cell 2, sub-element 2. For example, for
%                   zone 1, the default rotated x is -unrotated y, and the
%                   default rotated y is unrotated x.
% VTEtime       (default is 2)
%               number of seconds following zone entry time to plot.
% nZones        (default is 4)
%               number of zones in the restaurant row.
% flavor        (default is {'Cherry' 'Banana' 'Plain White' 'Chocolate'})
%               1 x nZones cell array of zone names for each zone
% fh            (default is next)
%               1 x nZones vector of handles to figures produced.
%
rotations = {[0 -1] [1  0];
             [1  0] [0  1];
             [0  1] [-1 0];
             [-1 0] [0 -1]};
VTEtime = 2;
nZones = 4;
flavor = {'Cherry' 'Banana' 'Plain White' 'Chocolate'};
curFigs = get(0,'children');
if isempty(curFigs);
    lastFig=0;
else
    lastFig=max(curFigs);
end
fh = [lastFig+1:lastFig+1+nZones];

process_varargin(varargin);

disp('Calculating number of time stamps and laps necessary...')
Tres = nan(length(fn),1);
trials = nan(length(fn),1);
for iSess = 1 : length(fn)
    load(fn{iSess});
    Tres(iSess) = mean([sd.x.dt sd.y.dt]);
    trials(iSess) = length(sd.ZoneIn);
end
nTstamps = ceil(VTEtime/min(Tres))+2;
nTrials = max(trials);

Xdata = nan(length(fn),nZones,nTrials,nTstamps);
Xtime = nan(length(fn),nZones,nTrials,nTstamps);
Ydata = nan(length(fn),nZones,nTrials,nTstamps);
Ytime = nan(length(fn),nZones,nTrials,nTstamps);
CPx = nan(length(fn),nZones,nTrials);
CPy = nan(length(fn),nZones,nTrials);
disp(sprintf('Aggregating x,y positions in first %d seconds from zone entry',VTEtime))
for iSess = 1 : length(fn)
    load(fn{iSess});
    disp(fn{iSess});
    EnterZone = sd.EnteringZoneTime;
    CPend = sd.EnteringZoneTime+VTEtime;
    ZoneIn = sd.ZoneIn;
    for iTrial = 1 : length(EnterZone)
        x = sd.x.restrict(EnterZone(iTrial),CPend(iTrial));
        y = sd.y.restrict(EnterZone(iTrial),CPend(iTrial));
        % x,y positions within VTEtime seconds of zone entry.
        x0 = sd.x.restrict(EnterZone(iTrial)-sd.x.dt,EnterZone(iTrial)+sd.x.dt);
        y0 = sd.y.restrict(EnterZone(iTrial)-sd.y.dt,EnterZone(iTrial)+sd.y.dt);
        % x,y positions at zone entry.
        Xdata(iSess,ZoneIn(iTrial),iTrial,1:length(x.data)) = x.data;
        Xtime(iSess,ZoneIn(iTrial),iTrial,1:length(x.range)) = x.range;
        Ydata(iSess,ZoneIn(iTrial),iTrial,1:length(y.data)) = y.data;
        Ytime(iSess,ZoneIn(iTrial),iTrial,1:length(y.range)) = y.range;
        CPx(iSess,ZoneIn(iTrial),iTrial) = nanmean(x0.data);
        CPy(iSess,ZoneIn(iTrial),iTrial) = nanmean(y0.data);
    end
end

ZoneEntryXY = nan(nZones,2);
for iZ = 1 : nZones
    X = squeeze(Xdata(:,iZ,:,:));
    Y = squeeze(Ydata(:,iZ,:,:));
    xEntry = CPx(:,iZ,:);
    yEntry = CPy(:,iZ,:);
    xEntry = nanmean(xEntry(:));
    yEntry = nanmean(yEntry(:));
    ZoneEntryXY(iZ,:) = [xEntry yEntry];
    X = X-xEntry;
    Y = Y-yEntry;
    
    xRot = rotations{iZ,1}; % rotated x value is equal to xRot(1)*x+xRot(2)*y value.
    yRot = rotations{iZ,2}; % rotated y value is equal to yRot(1)*x+yRot(2)*y value.
    
    x = X.*xRot(1)+Y.*xRot(2);
    y = X.*yRot(1)+Y.*yRot(2);
    
    figure(fh(iZ))
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    hold on
    for iSess = 1 : size(X,1)
        for iTrial = 1 : size(X,2)
            plot(squeeze(x(iSess,iTrial,:)),squeeze(y(iSess,iTrial,:)),'-','color',[0.8 0.8 0.8])
        end
    end
    hold off
    set(gca,'xcolor','w')
    set(gca,'xtick',[])
    set(gca,'ycolor','w')
    set(gca,'ytick',[])
    title(flavor{iZ}) 
end

figure(fh(end))
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
for iZ = 1 : nZones
    X = squeeze(Xdata(:,iZ,:,:))-ZoneEntryXY(iZ,1);
    Y = squeeze(Ydata(:,iZ,:,:))-ZoneEntryXY(iZ,2);
    
    xRot = rotations{iZ,1}; % rotated x value is equal to xRot(1)*x+xRot(2)*y value.
    yRot = rotations{iZ,2}; % rotated y value is equal to yRot(1)*x+yRot(2)*y value.
    
    x = X.*xRot(1)+Y.*xRot(2);
    y = X.*yRot(1)+Y.*yRot(2);
    
    hold on
    for iSess = 1 : size(x,1)
        for iTrial = 1 : size(x,2)
            plot(squeeze(x(iSess,iTrial,:)),squeeze(y(iSess,iTrial,:)),'-','color',[0.8 0.8 0.8]);
        end
    end
    hold off
    set(gca,'xcolor','w')
    set(gca,'xtick',[])
    set(gca,'ycolor','w')
    set(gca,'ytick',[])
    set(gca,'xlim',[-150 100])
    set(gca,'ylim',[-50 150])
    title('All passes aligned to zone entry')
end
X = Xdata;
Y = Ydata;
for iZ = 1:nZones
    xRot = rotations{iZ,1};
    yRot = rotations{iZ,2};
    X(:,iZ,:,:) = (Xdata(:,iZ,:,:)-ZoneEntryXY(iZ,1)).*xRot(1)+(Ydata(:,iZ,:,:)-ZoneEntryXY(iZ,2)).*xRot(2);
    Y(:,iZ,:,:) = (Xdata(:,iZ,:,:)-ZoneEntryXY(iZ,1)).*yRot(1)+(Ydata(:,iZ,:,:)-ZoneEntryXY(iZ,2)).*yRot(2);
end
Xdata = X;
Ydata = Y;
clear X Y
X.data = Xdata;
X.time = Xtime;
Y.data = Ydata;
Y.time = Ytime;