function fh = plot_sunkCost_pWait_vs_LogD_Zone_each_cumskip(RR_SUM_V1P0)

%% Logistic_regression_pWait_vs_Delay_ZoneNumber_at_each_CumSkip

fh=gcf;
clf
idNotFeeder = RR_SUM_V1P0.DATA(:,8)==0;
uniqueZ = unique(RR_SUM_V1P0.DATA(idNotFeeder,7));
uniqueS = unique(RR_SUM_V1P0.DATA(idNotFeeder,14));

b = nan(5,length(uniqueS));
theta = nan(length(uniqueS),length(uniqueZ));
for iSkip = 1 : length(uniqueS)
    idSkip = uniqueS(iSkip)==RR_SUM_V1P0.DATA(:,14);
    if length(RR_SUM_V1P0.DATA(idNotFeeder&idSkip,5))>2
        [b(:,iSkip),dev(:,iSkip),stats(iSkip)]=glmfit([log10(RR_SUM_V1P0.DATA(idNotFeeder&idSkip,5)) RR_SUM_V1P0.DATA(idNotFeeder&idSkip,7)==1 RR_SUM_V1P0.DATA(idNotFeeder&idSkip,7)==2 RR_SUM_V1P0.DATA(idNotFeeder&idSkip,7)==3 RR_SUM_V1P0.DATA(idNotFeeder&idSkip,7)==4],RR_SUM_V1P0.DATA(idNotFeeder&idSkip,11),'binomial','constant','off');
    end
    for iZ = 1 : length(uniqueZ)
        zones = false(1,length(uniqueZ));
        zones(iZ) = true;
        zones = double(zones);
        theta(iSkip,iZ) = (zones*b(2:end,iSkip))/(-b(1));
    end
end

cmap = jet(length(uniqueS));
for iZone = 1 : length(uniqueZ)
    idZone = RR_SUM_V1P0.DATA(:,7)==uniqueZ(iZone);
    
    subplot(2,length(uniqueZ),iZone)
    title(sprintf('ZONE %d',uniqueZ(iZone)))
    hold on
    ph = nan(length(uniqueS),1);
    legendStr = cell(length(uniqueS),1);
    for iSkip = 1 : length(uniqueS)
        idSkip = RR_SUM_V1P0.DATA(:,14)==uniqueS(iSkip);
        X = log10(RR_SUM_V1P0.DATA(idNotFeeder&idZone&idSkip,5));
        [X,idSort] = sort(X);
        Y = RR_SUM_V1P0.DATA(idNotFeeder&idZone&idSkip,11);
        Y = Y(idSort);
        uniqueX = unique(X);
        mX = nan(length(uniqueX),1);
        LB = mX;
        UB = mX;
        for iX = 1 : length(uniqueX);
            idX = X==uniqueX(iX);
            E = sum(double(Y(idX)==1));
            S = sum(double(Y(idX)==0));
            [mX(iX),LB(iX),UB(iX)] = binocis(E,S,1,0.05);
        end
%         eh = errorbar(uniqueX,mX,mX-LB,UB-mX);
%         set(eh,'linestyle','none')
%         set(eh,'color',cmap(iSkip,:))
        predX = linspace(log10(1),log10(30),1000)';
        predY = glmval(b(:,iSkip),[predX ones(1000,1)*uniqueZ(iZone)==1 ones(1000,1)*uniqueZ(iZone)==2 ones(1000,1)*uniqueZ(iZone)==3 ones(1000,1)*uniqueZ(iZone)==4],'logit','constant','off');
        if ~isempty(uniqueX)
            plot(predX,predY,'-','color',cmap(iSkip,:));
            ph(iSkip,1)=plot(uniqueX,mX,'o','markerfacecolor','w','markeredgecolor',cmap(iSkip,:));
            legendStr{iSkip,1} = sprintf('%d skips',uniqueS(iSkip));
%             legendStr{iSkip,2} = sprintf('\\theta=%.3f',theta);
        end
    end
    idnan = any(isnan(ph),2);
    ph(idnan,:) = [];
    legendStr(idnan,:) = [];
    lh=legend(ph(:),legendStr(:));
    set(lh,'location','southwest')
    xlabel('Log_{10}[Delay]')
    ylabel('P[Wait]')
    hold off
    
    ah2(iZone)=subplot(4,length(uniqueZ),2*length(uniqueZ)+iZone);
    title('All thresholds')
    hold on
    plot(uniqueS,theta(:,iZone),'ks')
    ylabel(sprintf('Threshold Log_{10}[Delay]'))
    hold off
    ah3(iZone)=subplot(4,length(uniqueZ),3*length(uniqueZ)+iZone);
    title('Threshold 1 to 30')
    hold on
    plot(uniqueS(theta(:,iZone)>log10(1)&theta(:,iZone)<log10(30)),theta(theta(:,iZone)>log10(1)&theta(:,iZone)<log10(30),iZone),'ks')
    xlabel('Cumulative Skips')
    ylabel(sprintf('Threshold Log_{10}[Delay]'))
    hold off
end
for h = 1 : length(ah2)
    set(gcf,'currentaxes',ah2(h))
    set(gca,'ylim',[min(theta(:)) max(theta(:))])
    set(gca,'xlim',[min(uniqueS)-0.5 max(uniqueS)+0.5]);
    set(gca,'xtick',[min(uniqueS):max(uniqueS)]);
    inftheta = theta>log10(30);
    bTheta(:,h) = glmfit(uniqueS,theta(:,h),'normal');
    hold on
    plot(uniqueS,glmval(bTheta(:,h),uniqueS,'identity'),'k-')
    hold off
    set(gcf,'currentaxes',ah3(h))
    set(gca,'ylim',[log10(1) log10(30)])
    set(gca,'xlim',[min(uniqueS)-0.5 max(uniqueS)+0.5])
    set(gca,'xtick',[min(uniqueS):max(uniqueS)])
    [bTheta0(:,h),dev,statsTheta0(h)] = glmfit(uniqueS(~inftheta(:,h)),theta(~inftheta(:,h),h),'normal');
    hold on
    plot(uniqueS,glmval(bTheta0(:,h),uniqueS,'identity'),'k-')
    statStr = sprintf('t=%.1f,p=%.2f',statsTheta0(h).t(2),statsTheta0(h).p(2));
    text(0,log10(30),statStr,'verticalalignment','top')
    hold off
end

fh(2)=figure;
clf
hold on
cmap = lines(length(uniqueZ));
ph = nan(length(uniqueZ),1);
legendStr = cell(length(uniqueZ),1);
for iZ = 1 : length(uniqueZ)
    plot(uniqueS,theta(iZ,:)-theta(iZ,1),'-s','markeredgecolor',cmap(iZ,:))
    ph(iZ)=plot(uniqueS,theta(iZ,:)-theta(iZ,1),'.','markerfacecolor',cmap(iZ,:),'markeredgecolor',cmap(iZ,:));
    legendStr{iZ} = sprintf('Zone %d',uniqueZ(iZ));
end
xlabel('Cumulative skips')
ylabel(sprintf('Threshold Log_{10}[Delay]'))
hold off