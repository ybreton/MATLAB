popdir all;
clear
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
    
    sd = RRInit('addUnderscored',true);
    nTrls(iD) = length(sd.ZoneIn);
    sdList(iD) = sd;
    popdir;
end
maxTrls = max(nTrls);
%%
Condition = cell(length(fd),1);

[X,Y] = meshgrid(linspace(-250,250,nBins),linspace(-250,250,nBins));

for iS=1:length(sdList)
    fdStr = fd{iS};
    disp(fdStr);
    idDelim = regexpi(fdStr,'\');
    SSN = fdStr(max(idDelim)+1:end);
    pushdir(fdStr);
    
    sd = sdList(iS);
    
    Condition{iD} = sd(1).ExpKeys.Condition;
    sd.x = sd.x.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);
    sd.y = sd.y.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);
    [sd.x,sd.y] = RRcentreMaze(sd);
    sd = RRFindQuadrant(sd);
    sd = RRrotateXYalign(sd);
    disp('Including underscore-t''s...')
    sd.S = cat(1,sd.S,sd.S_t);
    sd.fn = cat(2,sd.fn,sd.fn_t);
    sd.fc = cat(1,sd.fc,sd.fc_t);
    disp('Identifying hippocampal pyramidal cells...')
    S = RRGetHCplaceCells(sd);
    nCells = length(S);
    
    disp('Space-only decoding')
    disp('Tuning curves...')
    TC = TuningCurves(S,{{sd.x -250 250 nBins} {sd.y -250 250 nBins}});
    disp('Place fields...')
    
    for iC=1:length(S)
        figure(1);
        clf
        subplot(2,2,2)
        imagesc(linspace(-250,250,nBins),linspace(-250,250,nBins),squeeze(TC.H(iC,:,:))'./TC.Occ');
        hold on
        contour(X,Y,TC.Occ',[0 0],'w-')
        hold off
        colorbar;
        title('Occupancy-normed TC')
        axis xy
        
        subplot(2,2,1)
        hold on
        plot(sd.x.data,sd.y.data,'.','markeredgecolor',[0.8 0.8 0.8],'markerfacecolor',[0.8 0.8 0.8],'markersize',1);
        plot(sd.x.data(S{iC}.data),sd.y.data(S{iC}.data),'k.')
        hold off
        title(sprintf('Place firing\n(%d of %d cells)',iC,nCells))
        
        subplot(2,1,2)
        hold on
        for iCall=1:length(S)
            plot(S{iCall}.data,zeros(length(S{iCall}.data),1),'.','markeredgecolor',[0.8 0.8 0.8],'markerfacecolor',[0.8 0.8 0.8],'markersize',1)
        end
        plot(S{iC}.data,ones(length(S{iC}.data),1),'k.')
        hold off
        set(gca,'ylim',[-0.05 1.05])
        set(gca,'xlim',[sd(1).ExpKeys.TimeOnTrack sd(1).ExpKeys.TimeOffTrack])
        drawnow
    end
    
    disp('Q matrix...')
    Q = MakeQfromS(S,0.125);
    disp('Bayesian decoding...')
    B = BayesianDecoding(Q,TC);
    disp('Rotating decoding matrices...');
    B.rotPxs = RRrotateDecoding(B,sd);
    save([SSN '-DecodeXY.mat'],'TC','Q','B','S','nCells');
    popdir;
end