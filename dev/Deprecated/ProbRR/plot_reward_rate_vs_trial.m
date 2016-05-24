function fh = plot_reward_rate_vs_trial(RR_SUM_V1P0)
%
%
%
%

inTime = RR_SUM_V1P0.DATA(:,9); 
rDelivered = logical(RR_SUM_V1P0.DATA(:,12))&logical(RR_SUM_V1P0.DATA(:,8));

L = RR_SUM_V1P0.DATA(rDelivered,2);
rTime = RR_SUM_V1P0.DATA(rDelivered,15);
SSN = RR_SUM_V1P0.DATA(rDelivered,1);
% time to reward is the difference from rTime(i) to rTime(i-1).
uniqueSSN = unique(SSN);
lap = [];
ttr = [];
for s = 1 : length(uniqueSSN)
    idx = SSN == uniqueSSN(s);
    idxBig = uniqueSSN(s) == RR_SUM_V1P0.DATA(:,1);
    
    tIn = inTime(idxBig);
    tRew = rTime(idx);
    
    lap0 = L(idx);
    ttr0 = diff([tIn(1);tRew(:)]);
    
    lap = [lap(:);lap0(:)];
    ttr = [ttr(:);ttr0(:)];
end

uniqueD = unique(RR_SUM_V1P0.DATA(:,5));
delaysTotal = length(uniqueD);
uniqueP = unique(RR_SUM_V1P0.DATA(:,4));
probsTotal = length(uniqueP);
uniqueN = unique(RR_SUM_V1P0.DATA(:,6));
numsTotal = length(uniqueN);

uniqueL = unique(lap);
start = 1:11:length(uniqueL);
finish = start+10;
for block = 1 : length(start)
    B(block) = block;
    id = lap>=start(block) & lap<=finish(block);
    idxBig = RR_SUM_V1P0.DATA(:,2)>=start(block) & RR_SUM_V1P0.DATA(:,2)<=finish(block);
    
    blockD = RR_SUM_V1P0.DATA(idxBig,5);
    blockP = RR_SUM_V1P0.DATA(idxBig,4);
    blockN = RR_SUM_V1P0.DATA(idxBig,6);
    uniqueBD = unique(blockD);
    uniqueBP = unique(blockP);
    uniqueBN = unique(blockN);
    delaysInBlock = length(uniqueBD);
    probsInBlock = length(uniqueBP);
    numsInBlock = length(uniqueBN);
    if delaysInBlock==delaysTotal && probsInBlock==probsTotal && numsInBlock==numsTotal
        m(block) = nanmean(ttr(id));
        sem(block) = nanstderr(ttr(id));
    end
end

fh=gcf;
clf
hold on
eh=errorbar(B,m,sem);
set(eh,'linestyle','none')
set(eh,'color','k')
plot(B,m,'ks','markerfacecolor','w')
set(gca,'xtick',[min(B):1:max(B)])
set(gca,'xlim',[min(B)-0.5 max(B)+0.5])
xlabel(sprintf('Block number\n(Each Probability Presented Once at all Feeders)'))
ylabel(sprintf('Average Inter-Reward Interval (s)'))
hold off