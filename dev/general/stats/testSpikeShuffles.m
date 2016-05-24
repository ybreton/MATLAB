function [h,p,d,x,H0,bootstat] = testSpikeShuffles(S,tIn,tOut,varargin)
% Tests whether spike rate between tIn and tOut is different from shuffled
% spikes.
%
% [h] = testSpikeShuffles(S,tIn,tOut)
% where     h           is nCell x 1 indicator of significantly different
%                           spike rates within windows
%
%           tIn         is nTimes x 1 vector of start times for spike rate
%                           calculation
%           tOut        is nTimes x 1 vector of stop times for spike rate
%                           calculation
%
% [h,p,d,x,H0,bootstat] = testSpikeShuffles(...)
% where     p           is nCell x 1 proportion of shuffled spike rate means
%                           greater/smaller/more extreme than those in S
%           d           is nCell x 1 difference between spike rate and
%                           shuffled spike rate
%           x           is nCell x 1 sample spike rate
%           H0          is nCell x 1 shuffled null hypothesis spike rate
%           bootstat    is nBoot x nCell shuffled spike rate means
%
% OPTIONAL ARGUMENTS:
% ******************
% alpha     (default: 0.05)
%           Significance level to test
% tails     (default: 2)
%           Number of tails to test. Valid values are:
%           -1:     mean spike rate between tIn and tOut is significantly
%                       lower than shuffled spikes
%            1:     mean spike rate between tIn and tOut is significantly
%                       greater than shuffled spikes
%            2:     mean spike rate between tIn and tOut is significantly
%                       different from shuffled spikes
% t0        (default: minimum start time of S)
% t1        (default: maximum end time of S)
%           Range within which to restrict spikes to shuffle.
% nBoots    (default: 10^(ceil(-log10(alpha/abs(tails))+1))
%           Number of boots (times to reshuffle spikes). The above equation
%           ensures that each tail gets a minimum of 10 boots for comparing
%           the sample.
% bootfun   (default: @nanmean)
%           Function handle to apply to sampling distribution of rates in
%           each boot. The default assumes a sampling distribution of the
%           mean. bootfun defines what type of sampling distribution the
%           null hypothesis distribution will be. By default, a
%           distribution of sample mean rates is assumed.
% difffun   (default: @nanmean)
%           Function handle of central tendency of sampling distribution
%           for difference between observed rate and null hypothesis rate.
%           difffun defines what the central tendency of the sampling
%           distribution will be taken to be. By default, the central
%           tendency of the distribution of sample rates is the mean.
%

if isa(S,'ts')
    S = {S};
end

alpha=0.05;
tails=2;
t0 = min(cellfun(@starttime,S(~cellfun(@isempty,S))));
t1 = max(cellfun(@endtime,S(~cellfun(@isempty,S))));
bootfun = @nanmean;
difffun = @nanmean;
process_varargin(varargin);
assert(tails==-1||tails==1||tails==2,'tails must be 1 (Ha: x-bar>mu0), -1 (Ha: x-bar<mu0) or 2 (Ha: x-bar~=mu0).');
if isa(tIn,'ts')
    tIn=tIn.data;
end
if isa(tOut,'ts')
    tOut=tOut.data;
end
tIn=tIn(:);
tOut=tOut(:);
assert(length(tIn)==length(tOut),'tIn must have same number of elements as tOut.')
if isa(S,'ts')
    S={S};
end

nBoots = 10^(ceil(-log10(alpha/abs(tails))+1));
process_varargin(varargin);

disp(['Testing spikes of ' num2str(length(S(~cellfun(@isempty,S)))) ' cells within ' num2str(length(tIn)) ' time windows with ' num2str(nBoots) ' shuffled ISIs.'])

h = false(length(S),1);
xbar=nan(length(S),1);
pLo=nan(length(S),1);
pHi=nan(length(S),1);
p=nan(length(S),1);
bootstat=nan(nBoots,length(S));
k=0;
for iC=1:length(S)
    Sc = S{iC};
    if ~isempty(Sc)
        time1 = clock;
        k=k+1;
        bootStat0=nan(nBoots,1);
        xbar(iC) = bootfun(spikeCount(Sc,tIn,tOut)./(tOut-tIn));
        parfor boot=1:nBoots;
            Sboot=ShuffleISIs({Sc},t0,t1);
            Sboot=Sboot{1};
            nBoot=spikeCount(Sboot,tIn,tOut);
            rBoot=nBoot./(tOut-tIn);
            bootStat0(boot) = bootfun(rBoot);
        end
        pLo(iC) = prctile(bootStat0,(alpha/abs(tails))*100);
        pHi(iC) = prctile(bootStat0,(1-alpha/abs(tails))*100);
        bootstat(:,iC) = sort(bootStat0);
        time2 = clock;
        elapsed = etime(time2,time1);
        fprintf('\nCell %d (%d spikes): %.1fsec',k,length(Sc.data),elapsed)
    end
end
fprintf('\n\n')

switch tails
    case -1
        % sample S is less than null
        h=xbar<pLo;
        idLo=repmat(xbar',[size(bootstat,1) 1])>bootstat;
        p=(nansum(idLo,1))'./(nansum(~isnan(bootstat),1))';
    case 1
        % sample S is greater than null
        h=xbar>pHi;
        idHi=repmat(xbar',[size(bootstat,1) 1])<bootstat;
        p=(nansum(idHi,1))'./(nansum(~isnan(bootstat),1))';
    case 2
        % sample S is different from null
        h=(xbar<pLo)|(xbar>pHi);
        idLo=repmat(xbar',[size(bootstat,1) 1])<bootstat;
        idHi=repmat(xbar',[size(bootstat,1) 1])>bootstat;
        pLo=(nansum(idLo,1))';
        pHi=(nansum(idHi,1))';
        p=min([pLo pHi],[],2)./(nansum(~isnan(bootstat),1))'*2;
end

if nargout>2
    d=xbar-(difffun(bootstat))';
end
if nargout>3
    x=xbar;
end
if nargout>4
    H0=difffun(bootstat)';
end


function nSpikes = spikeCount(S,tIn,tOut)
nSpikes=nan(length(tIn),1);
for iT=1:length(tIn)
    Dboot=data(S.restrict(tIn(iT),tOut(iT)));
    nSpikes(iT)=length(Dboot);
end