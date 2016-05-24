function fh = plot_sunkCost_pWait_vs_LogD_Zone_each_cumskip(RR_SUM_V1P0,varargin)
% fh = plot_sunkCost_pWait_vs_LogD_Zone_each_cumskip(RR_SUM_V1P0)
% Optional arguments:
% - IVcol (default 5, 'DELAY')
% - logTransformIV (default true, for log10['DELAY'])
%
IVcol = 5;
logTransformIV = true;
process_varargin(varargin);

%% Logistic_regression_pWait_vs_Delay_ZoneNumber_at_each_CumSkip
%% FOR NUMBER OF PELLETS == 2.
name = RR_SUM_V1P0.NAME;
fh=gcf;
clf
idNotFeeder = RR_SUM_V1P0.DATA(:,8)==0 & RR_SUM_V1P0.DATA(:,6)==2;
uniqueZ = unique(RR_SUM_V1P0.DATA(idNotFeeder,7));
uniqueS = unique(RR_SUM_V1P0.DATA(idNotFeeder,14));

b = nan(5,length(uniqueS));
theta = nan(length(uniqueZ),length(uniqueS));
thetaLB = nan(length(uniqueZ),length(uniqueS));
thetaUB = nan(length(uniqueZ),length(uniqueS));

for iSkip = 1 : length(uniqueS)
    idSkip = uniqueS(iSkip)==RR_SUM_V1P0.DATA(:,14);
    if length(RR_SUM_V1P0.DATA(idNotFeeder&idSkip,IVcol))>5
        if logTransformIV
            X = [log10(RR_SUM_V1P0.DATA(idNotFeeder&idSkip,IVcol)) RR_SUM_V1P0.DATA(idNotFeeder&idSkip,7)==1 RR_SUM_V1P0.DATA(idNotFeeder&idSkip,7)==2 RR_SUM_V1P0.DATA(idNotFeeder&idSkip,7)==3 RR_SUM_V1P0.DATA(idNotFeeder&idSkip,7)==4];
        else
            X = [RR_SUM_V1P0.DATA(idNotFeeder&idSkip,IVcol) RR_SUM_V1P0.DATA(idNotFeeder&idSkip,7)==1 RR_SUM_V1P0.DATA(idNotFeeder&idSkip,7)==2 RR_SUM_V1P0.DATA(idNotFeeder&idSkip,7)==3 RR_SUM_V1P0.DATA(idNotFeeder&idSkip,7)==4];
        end
        Y = RR_SUM_V1P0.DATA(idNotFeeder&idSkip,11);
        [b(:,iSkip),dev(:,iSkip),stats(iSkip)]=glmfit(X,Y,'binomial','constant','off');
        theta(:,iSkip) = getThreshold(X,Y);
        nBoots = 1000;
        [~,bootsam]=bootstrp(nBoots,@mean,Y);
        thetaList = nan(4,nBoots);
        warning('off')
        parfor boot = 1 : nBoots
            idx = bootsam(:,nBoots);
            bootThetas = getThreshold(X(idx,:),Y(idx));
            thetaList(:,boot) = bootThetas;
        end
        warning('on')
        thetaLB(:,iSkip) = prctile(thetaList,2.5,2);
        thetaUB(:,iSkip) = prctile(thetaList,97.5,2);
    end
end
theta = theta';
thetaLB = thetaLB';
thetaUB = thetaUB';
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
        if logTransformIV
            X = log10(RR_SUM_V1P0.DATA(idNotFeeder&idZone&idSkip,IVcol));
        else
            X = (RR_SUM_V1P0.DATA(idNotFeeder&idZone&idSkip,IVcol));
        end
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
        if logTransformIV
            minX=min(log10(RR_SUM_V1P0.DATA(idNotFeeder,IVcol)));
            maxX=max(log10(RR_SUM_V1P0.DATA(idNotFeeder,IVcol)));
            predX = linspace(minX,maxX,1000)';
        else
            minX=min((RR_SUM_V1P0.DATA(idNotFeeder,IVcol)));
            maxX=max((RR_SUM_V1P0.DATA(idNotFeeder,IVcol)));
            predX = linspace(minX,maxX,1000)';
        end
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
    inftheta = theta>log10(30) | isnan(theta);
    bTheta(:,h) = glmfit(uniqueS,theta(:,h),'normal');
    hold on
    plot(uniqueS,glmval(bTheta(:,h),uniqueS,'identity'),'k-')
    hold off
    set(gcf,'currentaxes',ah3(h))
    set(gca,'ylim',[log10(1) log10(30)])
    set(gca,'xlim',[min(uniqueS)-0.5 max(uniqueS)+0.5])
    set(gca,'xtick',[min(uniqueS):max(uniqueS)])
    if ~all(inftheta(:,h))
        bTheta0(:,h) = glmfit(uniqueS(~inftheta(:,h)),theta(~inftheta(:,h),h),'normal');
        plot(uniqueS,glmval(bTheta0(:,h),uniqueS,'identity'),'k-')
    else
        bTheta0(1:2,h) = nan;
    end
    hold off
end

fh(2)=figure;
clf
title(sprintf('%s',name))
hold on
cmap = lines(length(uniqueZ));
ph = nan(length(uniqueZ),1);
legendStr = cell(length(uniqueZ),1);
for iZ = 1 : length(uniqueZ)
%     eh=errorbar(uniqueS,theta(:,iZ)-theta(1,iZ),theta(:,iZ)-thetaLB(:,iZ)-theta(1,iZ),thetaUB(:,iZ)-theta(:,iZ)-theta(1,iZ));
%     set(eh,'linestyle','none')
%     set(eh,'color',cmap(iZ,:))
    plot(uniqueS,theta(:,iZ)-theta(1,iZ),'-s','markeredgecolor',cmap(iZ,:),'markerfacecolor','w','color',cmap(iZ,:))
    ph(iZ)=plot(uniqueS,theta(:,iZ)-theta(1,iZ),'.','markerfacecolor',cmap(iZ,:),'markeredgecolor',cmap(iZ,:));
    legendStr{iZ} = sprintf('Zone %d',uniqueZ(iZ));
end
xlabel('Cumulative skips')
ylabel(sprintf('\\DeltaThreshold Log_{10}[%s]\n(normalized to 0 skips)',RR_SUM_V1P0.HEADER{IVcol}))
hold off

function thresholds = getThreshold(LogDZ1Z2Z3Z4,pWait)
warning('off')
b = glmfit(LogDZ1Z2Z3Z4,pWait,'binomial');
Zb = b(3:end);
thresholds = (b(1)+Zb(:)'*eye(4))./(-b(2));
warning('on')