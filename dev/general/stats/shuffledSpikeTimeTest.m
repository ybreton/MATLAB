function [h, p, Z] = shuffledSpikeTimeTest(s,t1,t2,start,stop,varargin)
% Tests whether the mean spike rate between times t1 and t2 is
% significantly different from expected when spikes and randomly shuffled.
% 
% 
% 
nBoot=500;
alpha=0.05;
tails=2;
process_varargin(varargin);

if ~isecell(s)
    s = {s};
end
h = nan(size(s));
p = nan(size(s));
Z = nan(size(s));
for iC=1:numel(s)
    x = nan(length(t1),1);
    for iEvent=1:length(t1)
        x(iEvent) = length(data(s{iC}.restrict(t1(iEvent),t2(iEvent))))/(t2(iEvent)-t1(iEvent));
    end
    m = nanmean(x);
    
    M = nan(nBoot,1);
    parfor iBoot=1:nBoot
        shufS = ShuffleISIs(start,stop);
        bootx = nan(length(t1),1);
        for iEvent=1:length(t1)
            bootx(iEvent) = length(data(shufS{iC}.restrict(t1(iEvent),t2(iEvent))))/(w2(iEvent)-w1(iEvent));
        end
        M(iBoot) = nanmean(bootx);
    end
    Mu = nanmean(M);
    Sigma = nanstd(M);
    
    Z(iC) = (m-Mu)/Sigma;
    if tails==-1
        % Tests Z<0
        p(iC) = normcdf(Z(iC),0,1);
    elseif tails==1
        % Tests Z>0
        p(iC) = 1-normcdf(Z(iC),0,1);
    else
        % Tests Z~=0
        p(iC) = (1-normcdf(abs(Z(iC)),0,1))/2;
    end
    h(iC) = p<alpha;
end