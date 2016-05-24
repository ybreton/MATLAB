function fh = plot_cumskips_vs_trial_number(RR_SUM_V1P0,varargin)
%
%
%
%

tPerBlock = 11;
process_varargin(varargin)

uniqueSSN = unique(RR_SUM_V1P0.HEADER.Row);
L = nan(size(RR_SUM_V1P0.DATA,1),1);
for s = 1 : length(uniqueSSN)
    idS = strcmp(uniqueSSN{s},RR_SUM_V1P0.HEADER.Row);
    Sess = RR_SUM_V1P0.DATA(idS,:);
    lastSubSess = nan;
    lSoFar = 0;
    Block = 0;
    L0 = nan(size(Sess,1),1);
    B0 = nan(size(Sess,1),1);
    for r = 1 : size(Sess,1)
        curRow = Sess(r,:);
        curSubSess = curRow(1);
        if curSubSess ~= lastSubSess 
            lastSubSess = curSubSess;
            Block = Block + 1;
            lSoFar = 1;
        elseif lSoFar>=tPerBlock
            Block = Block+1;
            lSoFar = 1;
        elseif mod(r,4)==1
            lSoFar = lSoFar + 1;
        end
        B0(r) = Block;
        L0(r) = lSoFar;
    end
    B(idS) = B0;
    L(idS) = L0;
end

S = RR_SUM_V1P0.DATA(:,14);
D = RR_SUM_V1P0.DATA(:,5);
P = RR_SUM_V1P0.DATA(:,4);
N = RR_SUM_V1P0.DATA(:,6);

uniqueD = unique(D);
delaysTotal = length(uniqueD);
uniqueP = unique(P);
probsTotal = length(uniqueP);
uniqueN = unique(N);
numsTotal = length(uniqueN);

uniqueB = unique(B);
m = nan(length(uniqueB),1);
sem = nan(length(uniqueB),1);
for block = 1 : length(uniqueB)
    start = min(L(B==uniqueB(block)));
    finish = max(L(B==unique(block)));
    id = L>=start & L<=finish;
    m(block) = nanmean(S(id));
    sem(block) = nanstderr(S(id));
end

fh=gcf;
clf
hold on
eh=errorbar(uniqueB,m,sem);
set(eh,'linestyle','none')
set(eh,'color','k')
plot(B,m,'ks','markerfacecolor','w')
set(gca,'xtick',[min(uniqueB):1:max(uniqueB)])
set(gca,'xlim',[min(uniqueB)-0.5 max(uniqueB)+0.5])
set(gca,'ylim',[0 max(S)])
xlabel(sprintf('Block number\n(Each Probability and Delay Presented Once at all Feeders)'))
ylabel(sprintf('Mean Skips since last entry\n(0 means entered last feeder)'))
hold off