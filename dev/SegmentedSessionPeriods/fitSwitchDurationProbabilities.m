function [fit,LnL] = fitSwitchDurationProbabilities(lap,x,K,varargin)
%
%
%
%
%

algorithm = 'interior-point';
display = 'off';
maxLap = max(lap);
minDuration = 3;
RandChanceProb = 0.5;
debug = false;
process_varargin(varargin);

OPTIONS = optimset('algorithm',algorithm,'display',display,'tolfun',10^-6);
x = double(x(:));
lap = lap(:);

if K>1
    % fit segments.
    DurationList = listSegmentDurations(K,maxLap,'minDuration',minDuration);
else
    DurationList = maxLap;
end
P_List = nan(size(DurationList));
LnL_List = nan(size(DurationList,1),1);
for attempt = 1 : size(DurationList,1)
    Duration = DurationList(attempt,:);
    [start,finish] = StartFinishLap(Duration);
    Probabilities = nan(1,K);
    for k = 1 : K
        id = lap>=start(k)-1&lap<=finish(k);
        x0 = x(id);
        x1 = x0(1:numel(x0)-1);
        x2 = x0(2:end);
        p = sum(double(x2~=x1))/numel(x0);
        Probabilities(k) = p;
    end
    nLnL = nLogLikelihood(lap,x,start,finish,Probabilities,debug);
    LnL_List(attempt,1) = -nLnL;
    P_List(attempt,:) = Probabilities;
end

[LnL,idBest] = max(LnL_List);
ProbChoice1 = P_List(idBest,:);
Durations = DurationList(idBest,:);
fit = [double(Durations);ProbChoice1];
fit = double(fit);

function nLnL = nLogLikelihood(lap,x,start,finish,Probabilities,debug)
K = length(Probabilities);
L = nan(length(x),1);
for k = 1 : K
    id = lap>=start(k)&lap<=finish(k);
    % id is all laps of current segment.
    % the likelihood of the first choice in current segment depends on last
    % choice of last segment.
    if start(k)>1
        L1 = likelihood(x(start(k)-1:start(k)),Probabilities(k));
    else
        L1 = 1;
    end
    L2 = likelihood(x(id),Probabilities(k));
    
    L(id) = [L1(:);L2(:)];
end
nLnL = -sum(log(L));
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
x2 = x(2:end);
x1 = x(1:numel(x)-1);
% switch.
idSwitch = x2~=x1;
% persist.
idPersist = x2==x1;
L(idSwitch) = p;
L(idPersist) = 1-p;
