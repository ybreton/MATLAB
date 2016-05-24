function [fitTable,fh] = fit_RR_choice_logit(RR_SUM_V1P0,varargin)
%
%
%
%

SeparateLogit = 7;
PredX = 4;
LogitPreds = [5 6];
LogitChoice = 11;
LogTransform = false(length(PredX)+length(LogitPreds));
process_varargin(varargin);
LogitPreds = [PredX(:)' LogitPreds(:)'];

LogTransform = LogTransform(:)';
if length(LogTransform)<length(LogitPreds)
    LogTransform(end+1:length(LogitPreds)) = false;
end

uniquePts = unique(RR_SUM_V1P0.DATA(:,[SeparateLogit(:)' LogitPreds(:)']),'rows');

cols = 1:size(uniquePts,2);
if any(LogTransform)
    cols = cols([false(1,length(SeparateLogit)) LogTransform]);
    uniquePts(:,cols) = log10(uniquePts(:,cols));
end

logitNames = RR_SUM_V1P0.HEADER(SeparateLogit);
linePredNames = RR_SUM_V1P0.HEADER(LogitPreds);
k = 0;
for iL = length(SeparateLogit)+length(PredX):length(SeparateLogit)+length(PredX)+length(LogitPreds)
    k = k+1;
    if LogTransform(iL)
        linePredNames{k} = sprintf('Log10[%s]',linePredNames{k});
    end
end

Entries = nan(size(uniquePts,1),1);
Skips = Entries;
for iPt = 1 : size(uniquePts,1)
    comparison = repmat(uniquePts(iPt,:),size(RR_SUM_V1P0.DATA,1),1);
    idx = all(RR_SUM_V1P0.DATA(:,[SeparateLogit LogitPreds])==comparison,2);
    
    Entries(iPt) = sum(double(RR_SUM_V1P0.DATA(idx,LogitChoice)==1));
    Skips(iPt) = sum(double(RR_SUM_V1P0.DATA(idx,LogitChoice)==0));
end
Tries = Entries+Skips;

SeparateLogitRows = unique(RR_SUM_V1P0.DATA(:,SeparateLogit),'rows');
SeparateLogitCols = size(SeparateLogit,2);
LogitPredCols = length(LogitPreds);

fit.NAME = RR_SUM_V1P0.NAME;
fit.SSN = RR_SUM_V1P0.SSN;

fit.SeparateLogits = RR_SUM_V1P0.HEADER([SeparateLogit]);

LogitPredNames = RR_SUM_V1P0.HEADER([LogitPreds]);

fit.HEADER.Row = cell(LogitPredCols+1,1);
fit.HEADER.Row{1} = 'Intercept';
fit.HEADER.Row(2:end) = LogitPredNames(:);

fit.DATA = nan(LogitPredCols+1,SeparateLogitRows);

for L = 1 : size(SeparateLogitRows,1)
    comparison = repmat(SeparateLogitRows(L,:),size(uniquePts,1),1);
    idx = all(uniquePts(:,1:SeparateLogitCols)==comparison,2);
    
    X = uniquePts(idx,SeparateLogitCols+1:end);
    Y = Entries(idx);
    T = Tries(idx);
    
    fit.DATA(:,L) = glmfit(X,[Y T],'binomial');
    fit.HEADER.Col{L} = SeparateLogitRows(L,:);
    
end

if nargout > 0
    fitTable = fit;
end
if nargout > 1 || nargout == 0
    clf
    fh=gcf;
    n = size(fit.DATA,2);
    for Logit = 1 : size(fit.DATA,2)
        SeparateLogitRows = fit.HEADER.Col{Logit};
        comparison = repmat(SeparateLogitRows,size(uniquePts,1),1);
        idx = all(uniquePts(:,1:SeparateLogitCols)==comparison,2);
        X = uniquePts(idx,SeparateLogitCols+1:end);
        E = Entries(idx);
        S = Skips(idx);
        Xlines = unique(X(:,2:end),'rows');
        subplot(1,n,Logit)
        titlestr = '';
        for LogitVar = 1 : length(logitNames)
            titlestr = [titlestr sprintf('%s=%.1f\n',logitNames{LogitVar},SeparateLogitRows)];
        end
        hold on
        title(titlestr);
        cmap = jet(size(Xlines,1)+2);
        cmap = cmap(2:end-1,:);
        ph1 = nan(size(Xlines,1));
        ph2 = ph1;
        for iLine = 1 : size(Xlines,1)
            comparison = repmat(Xlines,size(X,1),1);
            idxLine = all(X(:,2:end)==comparison,2);
            xPlot = X(idxLine,1);
            ePlot = E(idxLine,1);
            sPlot = S(idxLine,1);
            m = nan(length(xPlot),1);
            cilo = m;
            cihi = m;
            for iX = 1 : length(xPlot)
                [m(iX),cilo(iX),cihi(iX)] = binocis(ePlot(iX),sPlot(iX),1,0.05);
            end
            eh=errorbar(xPlot,m,m-cilo,cihi-m);
            set(eh,'linestyle','none')
            set(eh,'color',cmap(iLine,:))
            ph1(iLine)=plot(xPlot,m,'o','markerfacecolor','w','markeredgecolor',cmap(iLine,:),'markersize',12);
            plot(xPlot,m,'.','markerfacecolor',cmap(iLine,:),'markeredgecolor',cmap(iLine,:))
            str = '';
            for lineVar = 2 : length(linePredNames)
                str = [str sprintf('%s=%.2f\n',linePredNames{lineVar},Xlines(iLine,lineVar-1))];
            end
            legendStr1{iLine} = str;
            
            xPred = [xPlot repmat(Xlines(iLine,:),size(xPlot,1),1)];
            yPred = glmval(fit.DATA(:,Logit),xPred,'logit');
            ph2(iLine)=plot(xPlot,yPred,'-','color',cmap(iLine,:));
            theta = -([1 Xlines(iLine,:)]*fit.DATA([1 3:end],Logit))./fit.DATA(2,Logit);
            legendStr2{iLine} = sprintf('\\theta=%.3f',theta);
        end
        
        ph = [ph1(:);ph2(:)];
        legendStr = [legendStr1(:);legendStr2(:)];
        lh=legend(ph,legendStr);
        set(lh,'fontsize',8)
        xlabel(linePredNames{1})
        ylabel('Proportion Chosen')
        xlo = min(uniquePts(:,SeparateLogitCols+1));
        xhi = max(uniquePts(:,SeparateLogitCols+1));
        xdiff = min(abs(diff(unique(uniquePts(:,SeparateLogitCols+1)))));
        set(gca,'xlim',[xlo-xdiff/2 xhi+xdiff/2])
        set(gca,'ylim',[-0.05 1.05])
        hold off
    end
end