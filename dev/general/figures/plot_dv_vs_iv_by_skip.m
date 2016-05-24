function fh = plot_dv_vs_iv_by_skip(RR_SUM_V1P0,varargin)
% Plot DV vs IV, with lines defined by LV, in subplots defined by Skips.
% Plots below DV vs IV will show the threshold vs. LV at each Skip value.
%
% plot_dv_vs_iv_by_skip(RR_SUM_V1P0,varargin)
% where         RR_SUM_V1P0 is a table returned by summarize_restaurant_row
%
% OPTIONAL ARGUMENTS
% 
% LV = 'ZONE NUMBER'               Line variable
% IV = 'PROBABILITY'               Independent variable
% DV = 'FEEDER ENTRY'              Dependent variable
% Skips = 'CUM SKIPS'              Panel Variable
% Ex = 'FEEDER ZONE'               Exclusion Variable
% LogTransformIV = false           Log-transform IV
%
%
%

LV = 'ZONE NUMBER'; %Line Variable
IV = 'PROBABILITY'; %Independent Variable
DV = 'FEEDER ENTRY'; %Dependent Measurement
Skips = 'CUM SKIPS'; %Panel Variable
Ex = 'FEEDER ZONE'; %Exclusion Variable
LogTransformIV = false; %Log-transform IV
process_varargin(varargin);


fh = gcf;
clf;

IVcol = h2c(RR_SUM_V1P0,IV);
DVcol = h2c(RR_SUM_V1P0,DV);
LVcol = h2c(RR_SUM_V1P0,LV);
Scol = h2c(RR_SUM_V1P0,Skips);
Excol = h2c(RR_SUM_V1P0,Ex);

idEx = RR_SUM_V1P0.DATA(:,Excol)==1;
idInc = ~idEx;

if all(any([RR_SUM_V1P0.DATA(idInc,DVcol)==0 RR_SUM_V1P0.DATA(idInc,DVcol)==1]))
    % Logical variable.
    Y = logical(RR_SUM_V1P0.DATA(idInc,DVcol));
    dist = 'binom';
    fitFun = 'glmfit';
else
    Y = RR_SUM_V1P0.DATA(idInc,DVcol);
    dist = 'normal';
    fitFun = 'sigmoid_fit_lss';
end

X = RR_SUM_V1P0.DATA(idInc,IVcol);
if LogTransformIV
    X = log10(X);
end

Z = RR_SUM_V1P0.DATA(idInc,LVcol);
uniqueZ = unique(Z);

P = RR_SUM_V1P0.DATA(idInc,Scol);

%

% PLOT
% {panels 1 ... max(P)}
%   {line 1 ... max(Z)}
%       {X,Y for line j, panel i}

nSkips = unique(P);
maxSkips = max(nSkips);
cmap = jet(length(unique(Z)));
xrange = [min(X) max(X)];
yrange = [min(Y) max(Y)];

ThresholdTable = nan(size(unique(Z)),size(nSkips));

for iSkip = 1 : length(nSkips)
    idPanel = P == nSkips(iSkip);
    panelL = Z(idPanel);
    panelX = X(idPanel);
    panelY = Y(idPanel);
    
    LineList = unique(panelL);
    
    subplot(2,length(nSkips),iSkip)
    title(sprintf('%s=%d',Skips,nSkips(iSkip)))
    hold on
    for jLine = 1 : length(LineList)
        idLine = panelL == LineList(jLine);
        LineX = panelX(idLine);
        LineY = panelY(idLine);
        XList = unique(LineX);
        mY = nan(length(XList),1);
        LB = mY;
        UB = mY;
        for kX = 1 : length(XList)
            idX = XList(kX)==LineX;
            
            if strcmp(dist,'normal')
                mY(kX) = nanmean(LineY(idX));
                df = length(LineY(~isnan(LineY)&idX))-1;
                LB(kX) = mY(kX)+nanstderr(LineY(idX))*tinv(0.025,df);
                UB(kX) = mY(kX)+nanstderr(LineY(idX))*tinv(0.975,df);
            end
            if strcmp(dist,'binom')
                Success = sum(double(LineY(idX))==1);
                Failure = sum(double(LineY(idX))==0);
                [mY(kX),LB(kX),UB(kX)] = binocis(Success,Failure,1,0.05);
            end
        end
        PredX = linspace(min(XList),max(XList),1000);
        if strcmp(dist,'normal')'
            if length(LineX)>1
                [b,r] = sigmoid_fit_lss(LineX,LineY,true);
                PredY = scaled_logit(PredX(:),b,r,true);
                ThreshY = mean(r);
            else
                b = nan(2,1);
                r = nan(1,2);
                PredY = nan(length(PredX),1);
                ThreshY = nan;
            end
        end
        if strcmp(dist,'binom')
            if length(LineX)>1
                b = glmfit(LineX,LineY,'binomial');
                PredY = glmval(b,PredX,'logit');
                ThreshY = 0.5;
            else
                b = nan(2,1);
                PredY = nan(length(PredX),1);
                ThreshY = nan;
            end
        end
        if all(LineY==1)
            ThreshX = -inf;
        elseif all(LineY==0)
            ThreshX = inf;
        else
            ThreshX = -b(1)/b(2);
        end
        
        plot(PredX,PredY,'-','color',cmap(jLine,:),'linewidth',2)
        
        eh=errorbar(XList,mY,mY-LB,UB-mY);
        set(eh,'linestyle','none')
        set(eh,'color',cmap(jLine,:));
        plot(XList,mY,'o','markeredgecolor',cmap(jLine,:),'markerfacecolor','w','markersize',10)
        plot(XList,mY,'.','markeredgecolor',cmap(jLine,:),'markerfacecolor',cmap(jLine,:),'markersize',2);
        plot(ThreshX,ThreshY,'x','markersize',14,'markeredgecolor',cmap(jLine,:),'markerfacecolor',cmap(jLine,:));
        
        ThresholdTable(jLine,iSkip) = ThreshX;
    end
    if LogTransformIV
        xlabel(sprintf('Log_{10}[%s]',IV));
    else
        xlabel(sprintf('%s',IV))
    end
    ylabel(sprintf('%s',DV))
    set(gca,'xlim',xrange)
    set(gca,'ylim',yrange)
    hold off
    
    ah2(iSkip)=subplot(2,length(nSkips),length(nSkips)+iSkip);
    hold on
    plot([1:length(uniqueZ)],ThresholdTable(:,iSkip),'sk')
    if any(isinf(ThresholdTable(:,iSkip)))
        idinf = isinf(ThresholdTable(:,iSkip));
        infzone = uniqueZ(idinf);
        infthresh = ThresholdTable(idinf,iSkip);
        for iZ = 1 : length(infzone)
            if infthresh(iZ)>0
                plot(iZ,0,'sr')
                text(iZ,0,sprintf('0'),'verticalalignment','bottom','horizontalalignment','center')
            else
                plot(iZ,2,'sr')
                text(iZ,2,sprintf('1'),'verticalalignment','bottom','horizontalalignment','center')
            end
        end
    end
    xlabel(sprintf('%s',LV))
    ylabel('Threshold')
    hold off
end
for iSkip=1:length(ah2)
    set(fh,'CurrentAxes',ah2(iSkip))
    set(gca,'ylim',[0 2])
    set(gca,'xlim',[min(unique(Z))-0.5 max(unique(Z))+0.5])
    set(gca,'xtick',[unique(Z)])
end