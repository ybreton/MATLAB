function [m,s,Z,bootsam] = shuffleFiringRateDist(S,t1,t2,tStart,tEnd,varargin)
% Returns the mean and standard deviation of the distribution of mean
% firing rates across. 
%
%
%

plotFlag=false;
assert(length(size(t1))==length(size(t2)),'t1 and t2 must have same dimensions.');
assert(all(size(t1)==size(t2)),'t1 and t2 must have same size.');
progressBar=false;
alpha=0.05;
process_varargin(varargin);
nBoot=ceil(10.^(-floor(log10(alpha/2))+1));
process_varargin(varargin);
updateInterval=(5/100);
process_varargin(varargin);

bootStep = ceil(updateInterval*nBoot);
nWorkers = matlabpool('size');
parallel = bootStep/nWorkers;
minParallel = 50;
% If there are fewer than 50 boots for each worker to work on per step,
% they shouldn't be parallelized.
isParallel = parallel>=minParallel && nWorkers>1;

t1 = t1(:);
t2 = t2(:);
[t1,I]=sort(t1);
t2 = t2(I);

nWindows = length(t1);
winSize = t2-t1;

bootStart=1:bootStep:nBoot;
bootFinish=[bootStart(2:end)-1 nBoot];
if progressBar; wbh=waitbar(0,sprintf('Randomly shuffling %.0f windows %.0f times...\n(%.1f%% complete)',nWindows,nBoot,0));end;
Rt = nan(nBoot,1);
bootsam = nan(nWindows,nBoot);
if isParallel
    for iStart=1:length(bootStart)
        parfor iBoot=bootStart(iStart):bootFinish(iStart);
            t1boot = sort((rand(nWindows,1)*(tEnd-tStart)+tStart));
            t2boot = t1boot+winSize;
            nSpikes = nan(length(t1boot),1);
            for iWin=1:length(t1boot)
                nSpikes(iWin) = length(data(S.restrict(t1boot(iWin),t2boot(iWin))));
            end
            if any(~isnan(nSpikes))
                Rt(iBoot) = nanmean(nSpikes./winSize);
            end
            bootsam(:,iBoot) = nSpikes./winSize;
        end
        pct = bootFinish(iStart)/nBoot*100;
        if progressBar; waitbar(pct/100,wbh,sprintf('%.0f randomly shuffled spike time windows...\n(%.0f boots done,%.1f%% complete)',nWindows,bootFinish(iStart),pct)); end;
    end
else
    for iBoot=1:nBoot
        t1boot = sort((rand(nWindows,1)*(tEnd-tStart)+tStart));
        t2boot = t1boot+winSize;
        nSpikes = nan(length(t1boot),1);
        for iWin=1:length(t1boot)
            nSpikes(iWin) = length(data(S.restrict(t1boot(iWin),t2boot(iWin))));
        end
        if any(~isnan(nSpikes))
            Rt(iBoot) = nanmean(nSpikes./winSize);
        end
        bootsam(:,iBoot) = nSpikes./winSize;
        pct = iBoot/nBoot*100;
        if progressBar; waitbar(pct/100,wbh,sprintf('%.0f randomly shuffled spike time windows...\n(%.0f boots done,%.1f%% complete)',nWindows,bootFinish(iStart),pct)); end;
    end
end
if progressBar;close(wbh);end;

m = nanmean(Rt);
s = nanstd(Rt);

if nargout>2
    nSpikes=nan(length(t1),1);
    for iWin=1:length(t1)
        nSpikes(iWin) = length(data(S.restrict(t1(iWin),t2(iWin))));
    end
    x0 = nSpikes./winSize;
    x = nanmean(x0);
    Z = (x-m)./s;
else
    Z=nan;
end

if plotFlag
    [h,bin]=hist(Rt,ceil(sqrt(nBoot)));
    bh=bar(bin,h/sum(h),1)
    set(bh,'facecolor','none')
    set(bh,'edgecolor','k')
    hold on
    plot([m m],[0 max(h/sum(h))],'-r')
    patch([m-s m-s m+s m+s],[0 max(h/sum(h)) max(h/sum(h)) 0],[1 0 0],'edgecolor','none','facecolor','r','facealpha',0.2);
    text(Z,0,sprintf('$\\star$'),'interpreter','latex','color','b','fontsize',32)
    hold off
end