function [h,p,d,z,x,H0,SD0,bootstat,xsam] = testTimeShuffles(S,tIn,tOut,tStart,tEnd,varargin)
% Tests whether spike rate between tIn and tOut is different from uniformly
% sampled windows between tStart to tEnd, excluding those overlapping with
% tIn to tOut.
%
% [h] = testSpikeShuffles(S,tIn,tOut,tStart,tEnd)
% where     h           is nCell x 1 indicator of significantly different
%                           spike rates within windows
%
%           tIn         is nTimes x 1 vector of start times for spike rate
%                           calculation
%           tOut        is nTimes x 1 vector of stop times for spike rate
%                           calculation
%           tStart      is 1x1 scalar with earliest time to sample from
%                           (e.g., sd.ExpKeys.TimeOnTrack)
%           tEnd        is 1x1 scalar with latest time to sample from
%                           (e.g., sd.ExpKeys.TimeOffTrack)
%
% [h,p,d,x,H0,SD0,bootstat] = testSpikeShuffles(...)
% where     p           is nCell x 1 proportion of spike rate means from
%                           shuffled times greater/smaller/more extreme
%                           than those in S
%           d           is nCell x 1 difference between spike rate and
%                           shuffled spike rate
%           z           is nCell x 1 normalized difference between spike
%                           rate and shuffled spike rate
%                           (using diffun of the distribution of bootfun
%                           estimates, in units of spreadfun of the
%                           distribution of bootfun estimates)
%           x           is nCell x 1 sample spike rate
%           H0          is nCell x 1 shuffled null hypothesis spike rate
%                           (using difffun of the distribution of bootfun
%                           estimates)
%           SD0         is nCell x 1 shuffled null hypothesis spread 
%                           (using spreadfun of the distribution of bootfun
%                           estimates)
%                           
%           bootstat    is nBoot x nCell spike rates from shuffled times
%                           (using bootfun for each sample estimate)
%           xsam        is nWindows x nCell raw spike rate in the windows
%                           for the sample.
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
% t0        (default: tStart)
% t1        (default: tEnd)
%           Range within which to restrict spikes to shuffle.
% nBoots    (default: 10^(ceil(-log10(alpha/abs(tails))+1))
%           Number of boots (times to reshuffle spikes). The above equation
%           ensures that each tail gets a minimum of 10 boots for comparing
%           the sample.
% ratefun   (default: @spikeRate)
%           Function handle to apply to each window between tIn and tOut of
%           S. The default assumes that we want the number of spikes
%           between tIn and tOut, divided by the tOut-tIn duration, for
%           each window in the sample.
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
% spreadfun (default: @nanstd)
%           Function handle of spread of sampling distribution for
%           standardized difference between observed rate and null
%           hypothesis rate. spreadfun defines what the spread of the
%           sampling distribution will be taken to be. By default, the
%           spread of the distribution of sample rates is the standard
%           deviation.
%

alpha=0.05;
tails=2;
t0 = tStart;
t1 = tEnd;
ratefun = @spikeRate;
bootfun = @nanmean;
difffun = @nanmean;
spreadfun = @nanstd;
process_varargin(varargin);

% Tails must be -1, 1 or 2.
assert(tails==-1||tails==1||tails==2,'tails must be 1 (Ha: x-bar>mu0), -1 (Ha: x-bar<mu0) or 2 (Ha: x-bar~=mu0).');

% tIn and tOut must be the same size.
if isa(tIn,'ts')
    tIn=tIn.data;
end
if isa(tOut,'ts')
    tOut=tOut.data;
end
tIn=tIn(:);
tOut=tOut(:);
[tIn,I]=sort(tIn);
tOut=tOut(I);
assert(length(tIn)==length(tOut),'tIn must have same number of elements as tOut.')
assert(all(tIn<tOut),'tIn must be less than tOut.')

if isa(S,'ts')
    S={S};
end
nBoots = 10^(ceil(-log10(alpha/abs(tails))+1));
process_varargin(varargin);

for iC=1:length(S)
    S0 = S{iC};
    if ~isempty(S0)
        S0 = S0.restrict(t0,t1);
    end
    S{iC} = S0;
end

disp(['Testing spikes of ' num2str(length(S(~cellfun(@isempty,S)))) ' cells within ' num2str(length(tIn)) ' time windows compared to ' num2str(nBoots) ' shuffled time windows.'])

for iC=1:length(S)
    S0 = S{iC};
    if ~isempty(S0)
        S0 = ts(S0.range-tStart);
    end
    S{iC} = S0;
end
tEnd = tEnd-tStart;
tIn = tIn-tStart;
tOut = tOut-tStart;
tStart = 0;
t0 = tStart+(tOut(1)-tIn(1))/2;
t1 = tEnd-(tOut(end)-tIn(end))/2;

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
        xbar(iC) = bootfun(ratefun(Sc,tIn,tOut));
        fprintf('\nCell %d (%d spikes):',k,length(Sc.data))
        parfor boot=1:nBoots;
            tc = sort(t0+rand(length(tIn),1)*(t1-t0))
            tShuffleStart = tc-(tOut-tIn)/2;
            tShuffleEnd = tc+(tOut-tIn)/2;
            stuck=false;
            %[tShuffleStart,tShuffleEnd,stuck] = ShuffleTimeWindows(tStart,tEnd,tIn,tOut);
            if ~stuck
                tBoot = [tShuffleStart tShuffleEnd];
                rBoot = ratefun(Sc,tBoot(:,1),tBoot(:,2));
                bootStat0(boot) = bootfun(rBoot);
            else
                bootStat0(boot) = nan;
            end
        end
        pLo(iC) = prctile(bootStat0,(alpha/abs(tails))*100);
        pHi(iC) = prctile(bootStat0,(1-alpha/abs(tails))*100);
        bootstat(:,iC) = sort(bootStat0);
        time2 = clock;
        elapsed = etime(time2,time1);
        fprintf(' %.1fsec',elapsed)
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
    z=(xbar-(difffun(bootstat))')./(spreadfun(bootstat)+eps)';
end
if nargout>4
    x=xbar;
end
if nargout>5
    H0=difffun(bootstat)';
end
if nargout>6
    SD0=spreadfun(bootstat)';
end
if nargout>7
    xsam= nan(length(tIn),length(S));
    for iC=1:length(S)
        for iWin=1:length(tIn)
            xsam(iWin,iC) = length(data(S{iC}.restrict(tIn(iWin),tOut(iWin))))./(tOut(iWin)-tIn(iWin));
        end
    end
end

function rate = spikeRate(S,tIn,tOut)
n = spikeCount(S,tIn,tOut);
rate = n/(tOut-tIn+eps);

function nSpikes = spikeCount(S,tIn,tOut)
nSpikes=nan(length(tIn),1);
T = S.data;
for iT=1:length(tIn)
    idT = T>=tIn(iT)&T<tOut(iT);
    nSpikes(iT)=nansum(double(idT));
end