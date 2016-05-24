function Z = firingZscore(s,t1,t2,start,stop,varargin)
% Calculates a cell's mean firing between t1 and t2 time stamps, Z-scored
% to a distribution of firing means obtained between start and stop times
% excluding times between t1 and t2.
%
%
%
nboots = 500;
process_varargin(varargin);
if ~iscell(s)
    s = {s};
end

Z = nan(size(s));
for iC=1:length(s)
    s0 = s{iC};
    FR = nan(length(t1),1);
    for iTrl=1:length(t1)
        window = t2(iTrl)-t1(iTrl);
        FR(iTrl) = length(data(s0.restrict(t1(iTrl),t2(iTrl))))/window;
    end

    disp('Distribution of shuffle means...')
    boots = nan(nboots,1);
    parfor iboot=1:nboots;
        [tShuffleStart,tShuffleStop] = ShuffleTimeWindows(t1,t2,start,stop);
        shuff = nan(length(t1),1);
        for iTrl=1:length(tShuffleStart)
            shuff(iTrl) = length(data(s0.restrict(tShuffleStart(iTrl),tShuffleStop(iTrl))))/(tShuffleStop(iTrl)-tShuffleStart(iTrl));
        end
        boots(iboot) = nanmean(shuff);
    end
    m = nanmean(boots);
    sd = nanstd(boots);
    Z(iC) = (nanmean(FR)-m)/(eps+sd);
end