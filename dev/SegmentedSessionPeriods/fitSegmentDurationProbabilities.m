function [fit,LnL] = fitSegmentDurationProbabilities(lap,x,K,varargin)
%
%
%
%
%

% algorithm = 'interior-point';
% display = 'off';
maxLap = max(lap);
minDuration = 3;
RandChanceProb = 0.5;
threshold = 0.1;
debug = false;
display_progress = true;
display_figure =  false;
process_varargin(varargin);

% OPTIONS = optimset('algorithm',algorithm,'display',display,'tolfun',10^-6);
x = double(x(:));
lap = lap(:);
[lap,id] = sort(lap);
x = x(id);

if K>1
    % fit segments.
%     DurationList = listSegmentDurations(K,maxLap,'minDuration',minDuration);
    
    % Each of K-1 segments will have duration minDuration to
    % maxLap-(K-1)*minDuration.
    % The final (Kth) segment will have duration maxLap-sum(D).
    acceptableDurations = minDuration:maxLap-(K-1)*minDuration;
    row = ones(1,K-1);
    LnL_List = [];
    P_List = [];
    Durations = [];
    if display_progress
        fprintf('\n')
    end
    t0 = clock;
    one_percent = floor(((length(acceptableDurations))^(K-1))/100);
    ten_percent = ceil(((length(acceptableDurations))^(K-1))/10);
    for attempt = 1 : (length(acceptableDurations))^(K-1)
        list = nan(1,K-1);
        for c=1:K-1
            list(c) = acceptableDurations(row(c));
        end
        if all(list>=minDuration)
            identical = true;
            for c=2:K-1
                identical = identical && row(c)==row(c-1);
            end
            if ~identical
                list = perms(list);
            end
            if size(list,1)>1
                list = unique(list,'rows');
            end
            list(:,K) = maxLap - sum(list,2);
            if all(list>=minDuration)
                tempProbabilities = nan(size(list,1),K);
                LnL = nan(size(list,1),1);
                if size(list,1)>1
                    for r0=1:size(list,1)
                        tempDuration = list(r0,:);
                        [start,finish] = StartFinishLap(tempDuration);
                        Probabilities0 = MLE_segment(lap,x,start,finish,RandChanceProb,threshold);
                        if any((Probabilities0(2:2:end)<0.5+threshold&Probabilities0(2:2:end)>0.5-threshold))
                            LnL(r0,1) = -inf;
                        else
                            tempProbabilities(r0,:) = Probabilities0;
                            LnL(r0,1) = -nLogLikelihood(lap,x,start,finish,tempProbabilities(r0,:),debug);
                        end
                    end
                else
                    [start,finish] = StartFinishLap(list);
                    Probabilities0 = MLE_segment(lap,x,start,finish,RandChanceProb,threshold);
                    if any((Probabilities0(2:2:end)<0.5+threshold&Probabilities0(2:2:end)>0.5-threshold))
                        LnL = -inf;
                    else
                        tempProbabilities = Probabilities0;
                        LnL = -nLogLikelihood(lap,x,start,finish,tempProbabilities,debug);
                    end
                end
                Titrations = tempProbabilities(:,2:2:end);
                idEx = any(Titrations==0.5,2);
                tempProbabilities(idEx,:) = [];
                LnL(idEx) = [];
                list(idEx,:) = [];

                if ~isempty(LnL)
                    [LnLtest,bestTemp] = max(LnL);
                    Durationtest = list(bestTemp,:);
                    Probabilitiestest = tempProbabilities(bestTemp,:);
                    if ~isempty(LnL_List)
                        Durations2 = [Durations;Durationtest];
                        P_List2 = [P_List;Probabilitiestest];

                        [LnL_List,idBest] = max([LnL_List LnLtest]);
                        Durations = Durations2(idBest,:);
                        P_List = P_List2(idBest,:);
                    else
                        Durations = Durationtest;
                        P_List = Probabilitiestest;
                        LnL_List = LnLtest;
                    end
                end
                if display_progress
                    percent_done = (attempt/(length(acceptableDurations)^(K-1)))*100;
                    if attempt == 10
                        t1 = clock;
                        elapsed = etime(t1,t0);
                        remaining = ((length(acceptableDurations)^(K-1))-10)*elapsed;
                        fprintf('\nFitting %d segments to %d laps.\n',K,maxLap)
                        fprintf('Expected time: %.1f\n',remaining)
                    end
                    if mod(attempt,one_percent)==0
                        fprintf('.')
                    end
                    if mod(attempt,ten_percent)==0
                        fprintf('\n')
                        t1 = clock;
                        elapsed = etime(t1,t0);
                        tPerAttempt = elapsed/attempt;
                        remaining = ((length(acceptableDurations)^(K-1))-attempt)*tPerAttempt;
                        fprintf('%.1f%% complete. %.1f elapsed. %.1f remain.\n',percent_done,elapsed,remaining)
                    end
                end
                if display_figure && ~isempty([Durations;P_List])
                    plot_choice_segment_overlay([Durations;P_List],x)
                    drawnow
                end
            end
            row(K-1) = row(K-1)+1;
            for c = K-1:-1:2
                if row(c)>length(acceptableDurations)
                    row(c-1)=row(c-1)+1;
                    row(c)=1;
                end
            end
        else
            row(K-1) = row(K-1)+1;
            for c = K-1:-1:2
                if row(c)>length(acceptableDurations)
                    row(c-1)=row(c-1)+1;
                    row(c)=1;
                end
            end
        end
    end
else
    Probabilities = RandChanceProb;
    Durations = maxLap;
    start = 1;
    finish = maxLap;
    nLnL = nLogLikelihood(lap,x,start,finish,Probabilities,debug);
    LnL_List = -nLnL;
    P_List = Probabilities;
end

ProbChoice1 = P_List(1,:);
Durations = Durations(1,:);
fit = [double(Durations);ProbChoice1];
fit = double(fit);
LnL = LnL_List(1,:);

function nLnL = nLogLikelihood(lap,x,start,finish,Probabilities,debug)
K = length(Probabilities);
p = nan(size(lap));
for k = 1 : K
    p(start(k):finish(k)) = Probabilities(k);
end
LnL = logLikelihood(x,p);
nLnL = -sum(LnL);
if debug
    clf
    hold on
    plot(lap,x,'k.')
    for k = 1 : K
        plot(start(k):finish(k),Probabilities(k),'r-')
    end
    hold off
    drawnow
end

function L = likelihood(x,p)
% when x=1, p^x is p.
% when x=0, p^x is 1.
% when x=1, (1-p)^(1-x) is 1.
% when x=0, (1-p)^(1-x) is 1-p.
L = (p.^x).*((1-p).^(1-x));

function LnL = logLikelihood(x,p)
% if L = (p.^x).*((1-p).^(1-x))
% LnL = Log((p.^x).*((1-p).^(1-x)))
% LnL = Log(p.^x) + Log((1-p).^(1-x)))
% LnL = x.*Log(p) + (1-x).*Log(1-p)
LnL = x.*log(p) + (1-x).*log(1-p);

function Probabilities = MLE_segment(lap,x,start,finish,RandChanceProb,threshold)
K = length(start);
Probabilities(1:K) = RandChanceProb;
for k = 2 : 2 : K
    duration = finish(k) - start(k) + 1;
    Xk = x(start(k):finish(k));
    p = sum(Xk)./duration;
    
    Probabilities(k) = p;
end