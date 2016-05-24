function [VEH,fh] = wrap_RR_pSkip(VEH,varargin)
% Adds and plots pSkip information by zone.
% analysisStructOut = wrap_RR_pSkip(analysisStruct)
% where         analysisStructOut   is a RR structure with added fields
%                                       .nskips, nSess x 4 x nPellets, number of skips
%                                       .nstays, nSess x 4 x nPellets, number of stays
%               fh                  is a vector of handles to produced figures 
%
% OPTIONAL ARGUMENTS:
% ******************
% titleStr      (default blank)     string to use as title for figures
% plotFlag      (default true)      logical to plot the figures
% fh            (default next two)  handle to figures for plots
% 

titleStr = '';
plotFlag = true;
figList = get(0,'children');
if isempty(figList)
    lastFig = 0;
else
    lastFig = max(figList);
end
fh = [lastFig+1 lastFig+2];
process_varargin(varargin);

skips = nan(size(VEH.thresholds));
stays = nan(size(VEH.thresholds));
for iSess = 1 : size(VEH.staygo,1)
    for iZone = 1 : 4
        idZone = VEH.zones(iSess,:)==iZone;
        uniqueNs = unique(VEH.pellets(iSess,idZone));
        uniqueNs(isnan(uniqueNs)) = [];
        for iN = 1 : length(uniqueNs)
            pellets = uniqueNs(iN);
            idPellets = VEH.pellets(iSess,:)==pellets;
            skips(iSess,iZone,pellets) = nansum(double(VEH.staygo(iSess,idZone&idPellets)==0));
            stays(iSess,iZone,pellets) = nansum(double(VEH.staygo(iSess,idZone&idPellets)==1));
        end
    end
end

VEH.nskips = skips;
VEH.nstays = stays;

if plotFlag

    pSkips = VEH.nskips./(VEH.nskips+VEH.nstays);

    mSkips = squeeze(nanmean(pSkips))';
    sSkips = nan(size(mSkips));
    for iN = 1 : size(pSkips,3)
        sSkips(iN,:) = nanstderr(pSkips(:,:,iN))';
    end

    idnan = all(isnan(mSkips),2);

    mSkips = mSkips(~idnan,:);
    sSkips = sSkips(~idnan,:);

    figure(fh(1));
    title(titleStr);
    if size(mSkips,1)>1
        % Multiple pellet numbers.
        bh=bar(mSkips);
        childs = get(bh,'children');
        hold on
        for iChild = 1 : length(childs)
            xpos = nanmean(get(childs{iChild},'xdata'));
            eh=errorbar(xpos,mSkips(:,iChild),sSkips(:,iChild));
            set(eh,'linestyle','none')
            set(eh,'color','k')
            ph = childs{iChild};
            legendStr = sprintf('Zone %d',iChild);
        end
        hold off
        xlabel('Number of pellets');
    else
        % Just one pellet number.
        bh=bar(mSkips);
        childs = get(bh,'children');
        hold on
        eh=errorbar(1:length(mSkips),mSkips,sSkips);
        set(eh,'linestyle','none')
        set(eh,'color','k')
        set(childs,'facecolor',[0.8 0.8 0.8])
        hold off
        xlabel('Zone number');
    end
    ylabel(sprintf('P[Skip]\n(mean across sessions \\pm SEM)'))

    figure(fh(2));
    pSkipMarginalByPellet = nansum(VEH.nskips,2)./nansum(VEH.nskips+VEH.nstays,2);
    pSkipMarginalByZone = nansum(VEH.nskips,3)./nansum(VEH.nskips+VEH.nstays,3);

    subplot(1,2,1)
    title(titleStr);
    mMarginalByPellet = squeeze(nanmean(pSkipMarginalByPellet));
    sMarginalByPellet = nan(size(mMarginalByPellet));
    xMarginal = (1:length(mMarginalByPellet))';
    for iN = 1 : size(pSkipMarginalByPellet,3)
        sMarginalByPellet(iN,:) = (nanstderr(pSkipMarginalByPellet(:,:,iN)));
    end

    bh=bar(mMarginalByPellet);
    childs=get(bh,'children');
    idnan = isnan(mMarginalByPellet);
    mMarginalByPellet = mMarginalByPellet(~idnan,:);
    sMarginalByPellet = sMarginalByPellet(~idnan,:);
    xMarginal = xMarginal(~idnan);
    hold on
    eh=errorbar(xMarginal,mMarginalByPellet,sMarginalByPellet);
    set(eh,'linestyle','none')
    set(eh,'color','k')
    set(childs,'facecolor',[0.8 0.8 0.8])
    hold off
    xlabel('Number of pellets');
    ylabel('P[Skip]')

    subplot(1,2,2)
    title(titleStr);
    mMarginalByZone = squeeze(nanmean(pSkipMarginalByZone));
    sMarginalByZone = nan(size(mMarginalByZone));
    xMarginal = (1:length(mMarginalByZone));
    for iZ = 1 : size(pSkipMarginalByZone,2)
        p = squeeze(pSkipMarginalByZone(:,iZ,:));
        sMarginalByZone(iZ) = (nanstderr(p));
    end

    bh=bar(mMarginalByZone);
    childs=get(bh,'children');
    idnan = isnan(mMarginalByZone);
    mMarginalByZone = mMarginalByZone(~idnan);
    sMarginalByZone = sMarginalByZone(~idnan);
    xMarginal = xMarginal(~idnan);
    hold on
    eh=errorbar(xMarginal,mMarginalByZone,sMarginalByZone);
    set(eh,'linestyle','none')
    set(eh,'color','k')
    set(childs,'facecolor',[0.8 0.8 0.8])
    hold off
    xlabel('Zone')
    ylabel('P[Skip]')
end