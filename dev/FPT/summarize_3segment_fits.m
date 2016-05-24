function summary = summarize_3segment_fits(varargin)
%
%
%
%

fn = FindFiles('segmentFit.mat');

process_varargin(varargin);

for f = 1 : length(fn)
    pathname = fileparts(fn{f});
    id = regexpi(pathname,'\');
    id = max(id);
    SSN = pathname(id+1:end);
    pushdir(pathname);
    sdfn = FindFiles('*-sd.mat','CheckSubdirs',0);
    load(sdfn{1});
    load(fn{f});
    nP(3) = sd.World.nPleft;
    nP(4) = sd.World.nPright;
    nPdelay = max(nP);
    id = can2mat(fitResults.DATA(:,1))==3;
    threeSegFit = fitResults.DATA(id,:);
    segments = threeSegFit{5};
    durs = segments(1,:);
    probs = segments(2,:);
    start(1) = 1;
    finish(1) = start(1)+durs(1)-1;
    for seg = 2 : length(durs)
        start(seg) = finish(seg-1)+1;
        finish(seg) = start(seg)+durs(seg)-1;
    end
    id = probs==0.5;
    alternationStarts = start(id);
    alternationFinishes = finish(id);
    alternationDurations = durs(id);
    FinalStart = alternationStarts(end);
    FinalFinish = alternationFinishes(end);
    
    laps = 1:sd.TotalLaps;
    DelayLaps = laps(sd.ZoneIn==sd.DelayZone);
    
    AllDelayZoneDelay = nan(length(sd.ZoneIn),1);
    if ~isempty(DelayLaps)
        AllDelayZoneDelay(1:DelayLaps(1)) = sd.ZoneDelay(DelayLaps(1));
        for l = 2 : length(DelayLaps)
            AllDelayZoneDelay(DelayLaps(l-1):DelayLaps(l)) = sd.ZoneDelay(DelayLaps(l));
        end
        AllDelayZoneDelay(DelayLaps(end):end) = sd.ZoneDelay(DelayLaps(end));
    end
    
    meanDelay = mean(AllDelayZoneDelay(FinalStart:FinalFinish));
    
    DATA{f,1} = SSN;
    DATA{f,2} = nPdelay;
    DATA{f,3} = meanDelay;
    DATA{f,4} = length(durs);
    DATA{f,5} = alternationDurations(end);
    DATA{f,6} = alternationDurations(end)/sd.TotalLaps;
    popdir;
end
HEADER = {'SSN' 'nPdelay' 'meanDelay' 'nSegments' 'Duration of Final Alternation Segment' 'Proportion of session'};

summary.HEADER = HEADER;
summary.DATA = DATA;

clf
subplot(1,2,1)
cla
hold on
plot(can2mat(DATA(:,2)),can2mat(DATA(:,3)),'ko')
xlabel('Pellet ratio')
ylabel('mean delay during final alternation')
set(gca,'xlim',[min(can2mat(DATA(:,2)))-1 max(can2mat(DATA(:,2)))+1])
hold off
subplot(1,2,2)
cla
hold on
ph(1)=plot(log10(can2mat(DATA(:,2))),log10(can2mat(DATA(:,3))),'ko');

X = [ones(length(fn),1) log10(can2mat(DATA(:,2)))];
Y = log10(can2mat(DATA(:,3)));
idEx = isnan(Y)|any(isnan(X),2)|isinf(Y)|any(isinf(X),2);
Y(idEx) = [];
X(idEx,:) = [];
[X,idSort] = sortrows(X,[2 1]);
Y = Y(idSort);

b = X\Y;
Ypred = X*b;

SSpred = (Ypred(:)'-mean(Ypred))*(Ypred(:)-mean(Ypred));
SStotal = (Y(:)'-mean(Y))*(Y(:)-mean(Y));
rsq = SSpred/SStotal;

ph(2)=plot(X(:,2),Ypred,'r-');

legendStr{1} = 'Data';
legendStr{2} = sprintf('%.2f + %.2f \\times Log_{10}[Pellet ratio]\nR^2=%.3f',b(1),b(2),rsq);

legend(ph,legendStr)

xlabel(sprintf('Log_{10}[Pellet ratio]'))
ylabel(sprintf('Log_{10}[mean delay during final alternation]'))

hold off
summary.logRegression = b;
summary.logRegressionRsq = rsq;