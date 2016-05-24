function [fit,nLnL] = fitSegmentDMM(x,K,varargin)
%
%
%
%

RandomChanceProb = 0.5;
maxLap = numel(x);
minDuration = 4;
debug = false;
threshold = eps;
process_varargin(varargin);

if K>1
    % fit segments.
    DurationList = listSegmentDurations(K,maxLap,'minDuration',minDuration);
else
    DurationList = maxLap;
end
P_List = nan(2,K,size(DurationList,1));
LnL_List = nan(size(DurationList,1),1);
X = x(:);
lap = (1:numel(X))';
for attempt = 1 : size(DurationList,1)
    Duration = DurationList(attempt,:);
    [start,finish] = StartFinishLap(Duration);
    Probabilities = nan(2,2,K);
    for k = 1 : K
            id = lap>=start(k)&lap<=finish(k);
            x0 = X(id);
            x2 = x0(2:end);
            x1 = x0(1:numel(x0)-1);

            id00 = x1==0 & x2==0;
            id01 = x1==0 & x2==1;
            id10 = x1==1 & x2==0;
            id11 = x1==1 & x2==1;

            n = zeros(2,2);
            n(1,1) = sum(double(id00));
            n(1,2) = sum(double(id01));
            n(2,1) = sum(double(id10));
            n(2,2) = sum(double(id11));

            p = n./repmat(sum(n,2),1,2);
            p(isnan(p)) = RandomChanceProb;
            if mod(k,2)==1
                % odd
                p(~logical(eye(2))) = 1-threshold;
                p(logical(eye(2))) = threshold;
            else
                % even
                p(~logical(eye(2))&p>1-threshold) = 1 - threshold;
                p(logical(eye(2))&p<threshold) = threshold;
            end
            
            Probabilities(:,:,k) = p;
    end
    nLnL = nLogLikelihood(lap,x,start,finish,Probabilities,debug);
    LnL_List(attempt,1) = -nLnL;
    SwitchProbabilities(1,:) = squeeze(Probabilities(1,2,:));
    SwitchProbabilities(2,:) = squeeze(Probabilities(2,1,:));
    P_List(:,:,attempt) = SwitchProbabilities;
end
[LnL_best,idBest] = max(LnL_List);
P_best = squeeze(P_List(:,:,idBest));
P_best = reshape(P_best,2,numel(P_best)/2);
D_best = DurationList(idBest,:);
fit = [double(D_best);P_best];


function nLnL = nLogLikelihood(lap,x,start,finish,Probabilities,debug)
for k = 1 : size(Probabilities,3)
    id = lap>=start(k)&lap<=finish(k);
    if start(k)>1
        L0 = likelihood(x(start(k)-1:start(k)),Probabilities(:,:,k));
    else
        L0 = 1;
    end
    
    L1 = likelihood(x(id),Probabilities(:,:,k));
    L(id) = [L0(:);L1(:)];
end
LnL = log(L);
LnLs = sum(LnL);
nLnL = -LnLs;
if debug
    cla
    hold on
    plot(lap,x,'k.','markersize',20)
    for k = 1 : size(Probabilities,3)
        plot(start(k):finish(k),Probabilities(1,1,k),'g-','linewidth',2)
        plot(start(k):finish(k),Probabilities(1,2,k),'r-','linewidth',2)
        plot(start(k):finish(k),Probabilities(2,2,k),'g:','linewidth',2)
        plot(start(k):finish(k),Probabilities(2,1,k),'r:','linewidth',2)
    end
    hold off
    drawnow
end

function L = likelihood(x,Probabilities)
x1 = x(1:numel(x)-1);
x2 = x(2:end);

id00 = x1==0 & x2==0;
id01 = x1==0 & x2==1;
id10 = x1==1 & x2==0;
id11 = x1==1 & x2==1;

L(id00) = Probabilities(1,1);
L(id01) = Probabilities(1,2);
L(id10) = Probabilities(2,1);
L(id11) = Probabilities(2,2);