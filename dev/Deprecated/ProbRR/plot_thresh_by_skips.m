function [fh] = plot_thresh_by_skips(varargin)
%
%
%
%

ZF = 10;
include = 'RR-*.mat';
exclude = {};
process_varargin(varargin)

if ischar(include)
    include = {include};
end
if ischar(exclude)
    exclude = {exclude};
end
fn = cell(0,1);
for filter = 1 : length(include)
    fn0 = FindFiles(include{filter});
    fn(end+1:end+length(fn0)) = fn0;
end
fn0 = fn;
fn = cell(0,1);
if ~isempty(exclude)
    for f0 = 1 : length(fn0)
        filename = fn0{f0};
        excl = false(length(exclude));
        for filter = 1 : length(exclude)
            excl(filter) = isempty(regexpi(filename,exclude{filter}));
        end
        if all(~excl)
            fn{end+1} = filename;
        end
    end
else
    fn = fn0;
end

for f = 1 : length(fn)
    sessdat(f) = load(fn{f});
end
DATA = [];
for f = 1 : length(sessdat)
    ZoneIn = sessdat(f).ZoneIn;
    ZoneProbability = sessdat(f).ZoneProbability;
    skips = 0;
    CumSkips = zeros(length(ZoneProbability),1);
    SkipDat = zeros(length(ZoneProbability),1);
    for z = 2 : length(ZoneIn)
        if ZoneIn(z-1)<ZF & ZoneIn(z)<ZF
            % Skipped zone z-1.
            skips = skips + 1;
            SkipDat(z) = 1;
        end
        if ZoneIn(z-1)<ZF & ZoneIn(z)>ZF
            % Entered on zone z-1.
            skips = 0;
        end
        if ZoneIn(z)>ZF
            SkipDat(z-1) = 0;
            SkipDat(z) = 0;
        end
        CumSkips(z) = skips;
    end
    sessdat(f).CumSkips = CumSkips;
    sessdat(f).SkipDat = SkipDat;
    DATA = [DATA;
        ZoneIn(:) ZoneProbability(:) CumSkips(:) SkipDat(:)];
end

skipNums = unique(CumSkips);

fh = gcf;
clf
np = length(unique(DATA(:,3)));
nc = length(unique(DATA((DATA(:,1)<ZF),1)));
cmap = lines(nc+2);
cmap = cmap(2:end-1,:);
nr = length(unique(DATA(:,2)));
PZS = nan(nr,nc,np);
PZSlb = PZS;
PZSub = PZS;
b = nan(2,nc,np);
for iSkip = 1 : length(skipNums)
    idx = DATA(:,3) == iSkip;
    CumDat = DATA(idx,:);
    
    zoneList = unique(CumDat((CumDat(:,1)<ZF),1));
    
    X = nan(nr,nc);
    Y = X;
    L = X;
    U = X;
    for z = 1 : length(zoneList)
        idx = CumDat(:,1) == zoneList(z);
        zoneDat = CumDat(idx,:);
        
        probList = unique(zoneDat(:,2));
        for p = 1 : length(probList)
            idx = zoneDat(:,2)==probList(p);
            pDat = zoneDat(idx,:);
            
            Success = sum(double(pDat(:,4)==0));
            Failure = sum(double(pDat(:,4)==1));
            
            [m,lb,ub] = binocis(Success,Failure,1,0.05);
            PZS(p,z,iSkip) = m;
            PZSlb(p,z,iSkip) = lb;
            PZSub(p,z,iSkip) = ub;
            X(p,z) = probList(p);
            Y(p,z) = m;
            L(p,z) = lb;
            U(p,z) = ub;
        end
        b(:,zoneList(z),iSkip) = glmfit(zoneDat(:,2),zoneDat(:,4)==0,'binomial');
    end
    subplot(2,length(skipNums),iSkip)
    th=title(sprintf('%d Skips',skipNums(iSkip)));
    set(th,'fontweight','demi')
    hold on
    for z = 1 : size(b,2)
        th(1,z,iSkip) = -b(1,z,iSkip)./b(2,z,iSkip);
        eh=errorbar(X(:,z),Y(:,z),Y(:,z)-L(:,z),U(:,z)-Y(:,z));
        set(eh,'linestyle','none')
        set(eh,'color',cmap(z,:));
        plot(X(:,z),Y(:,z),'o','markeredgecolor',cmap(z,:),'markerfacecolor',cmap(z,:))
        plot(X(:,z),glmval(b(:,z,iSkip),X(:,z),'logit'),'-','color',cmap(z,:))
        plot(th(1,z,iSkip),0.5,'x','markerfacecolor',cmap(z,:));
    end
    set(gca,'xlim',[-0.1 1.1])
    set(gca,'ylim',[-0.05 1.05])
    xlabel('Probability')
    ylabel('P[Entry]')
    hold off
    subplot(2,length(skipNums),length(skipNums)+iSkip)
    hold on
    threshSkip = th(1,:,iSkip);
    threshSkip = threshSkip(~isnan(threshSkip));
    plot(zoneList,threshSkip,'ks')
    if any(isinf(threshSkip))
        idNeg = threshSkip==-inf;
        idPos = threshSkip==inf;
        plot(zoneList(idNeg),zeros(length(threshSkip(idNeg)),1),'rx')
        plot(zoneList(idPos),ones(length(threshSkip(idPos)),1),'rx')
    end
    xlabel('zone')
    ylabel('Threshold')
    set(gca,'xlim',[min(unique(DATA((DATA(:,1)<ZF),1)))-0.5 max(unique(DATA((DATA(:,1)<ZF),1)))+0.5])
    set(gca,'xtick',zoneList)
    set(gca,'ylim',[-0.3 1])
    hold off
end
% 
% out.PZS = PZS;
% out.LB = PZSlb;
% out.UB = PZSub;