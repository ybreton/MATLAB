function [RR_SUM] = Wrap_SunkCost_RR(varargin)
%
%
%
%

filter = 'RR-*.mat';
process_varargin(varargin);
fn = FindFiles(filter);
fn = sort(fn);
FixedDelay = true;
DelayValue = 1;
FixedProbability = false;
ProbabilityValue = 1;
crit = 3;
process_varargin(varargin);

if ~isempty(fn)
    filenameStart = fn{1};
    pathStart = fileparts(filenameStart);
    id = regexpi(pathStart,'\');
    SSN0 = pathStart(max(id)+1:end);
    
    filenameFinish = fn{end};
    pathFinish = fileparts(filenameFinish);
    id = regexpi(pathFinish,'\');
    SSN1 = pathFinish(max(id)+1:end);
    session_list = cell(length(fn),1);
    for f = 1 : length(fn)
        filename = fn{f};
        pathname = fileparts(filename);
        id = regexpi(pathname,'\');
        SSN = pathname(max(id)+1:end);
        dateStr = SSN(6:end);
        session_list{f} = dateStr;
    end
end
prefix = [SSN0 ' to ' SSN1];

RR_SUM_V1P0 = summarize_restaurant_row;

cols = 1:length(RR_SUM_V1P0.HEADER.Col);
idxDelay = strcmpi('DELAY',RR_SUM_V1P0.HEADER.Col);
delayCol = cols(idxDelay);
idxProb = strcmpi('PROBABILITY',RR_SUM_V1P0.HEADER.Col);
probCol = cols(idxProb);
idxEntry = strcmpi('FEEDER ENTRY',RR_SUM_V1P0.HEADER.Col);
entryCol = cols(idxEntry);
idxSkip = strcmpi('CUM SKIPS',RR_SUM_V1P0.HEADER.Col);
skipCol = cols(idxSkip);
if FixedDelay
    RR_SUM_V1P0.DATA(:,delayCol) = DelayValue;
end
if FixedProbability
    RR_SUM_V1P0.DATA(:,probCol) = ProbabilityValue;
end

% Identify IV
uniqueProbs = unique(RR_SUM_V1P0.DATA(:,probCol));
uniqueDelay = unique(RR_SUM_V1P0.DATA(:,delayCol));
Pswp = length(uniqueProbs)>1&length(uniqueDelay)==1;
Dswp = length(uniqueDelay)>1&length(uniqueProbs)==1;
if Pswp
    uniqueX = uniqueProbs;
    X = RR_SUM_V1P0.DATA(:,probCol);
    xl=sprintf('Probability of Reinforcement');
end
if Dswp
    uniqueX = uniqueDelay;
    X = RR_SUM_V1P0.DATA(:,delayCol);
    xl=sprintf('Delay to Reinforcement');
end
uniqueY = unique(RR_SUM_V1P0.DATA(:,skipCol));
Y = RR_SUM_V1P0.DATA(:,skipCol);
Z = RR_SUM_V1P0.DATA(:,entryCol);

xw = min(diff(uniqueX));
yw = min(diff(uniqueY));

H = nan(length(uniqueY),length(uniqueX));
for r = 1 : length(uniqueY)
    idr = uniqueY(r) == Y;
    for c = 1 : length(uniqueX)
        idc = uniqueX(c) == X;
        n = Z(idr&idc);
        tot = length(n);
        
        if tot > crit
            H(r,c) = (tot-sum(n))/tot;
        end
    end
end

fh = gcf;
clf
hold on
caxis([0 1])
[meshX,meshY] = meshgrid(uniqueX,uniqueY);
ph=pcolor(meshX,meshY,H);
shading flat
% plot(th,uniqueY,'wx','markersize',12)
% for p = 1 : size(ci,1)
%     plot([ci(p,1) ci(p,2)],[uniqueY(p) uniqueY(p)],'w-','linewidth',1.5)
% end
xlabel(xl)
ylabel(sprintf('Cumulative number of skips'))
set(gca,'xlim',[min(floor(uniqueX))-xw/2 max(ceil(uniqueX))+xw/2])
set(gca,'ylim',[min(floor(uniqueY))-yw/2 ceil(max(uniqueY))+yw/2])
cbh=colorbar;
set(get(cbh,'ylabel'),'string',sprintf('Proportion Skipped\n(n>%d)',crit))
set(get(cbh,'ylabel'),'rotation',-90)
axis xy
hold off
saveas(fh,[prefix ' SunkCost.fig'],'fig')
saveas(fh,[prefix ' SunkCost.eps'],'epsc')

if nargout>0
    RR_SUM = RR_SUM_V1P0;
end