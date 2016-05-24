function [summary,fh1,fh2] = restaurant_row_dreadd(fd1,fd2,varargin)
%
%
%
%

iv = 5;
dv = 11;
process_varargin(varargin);

fh1 = figure;
for f = 1 : length(fd1)
    pushdir(fd1{f});
    
    fn = FindFiles('RR_SUM_V1P0.mat','CheckSubdirs',0);
    load(fn{1});
    ta = ta_from_RRSUM(RR_SUM_V1P0);
    RR_SUM_V1P0.HEADER.Col{17} = 'TIME ALLOCATION';
    RR_SUM_V1P0.DATA(:,17) = ta;
    uniqueZ = unique(RR_SUM_V1P0.DATA(:,7));
    m = nan(length(uniqueZ),1);
    sem = nan(length(uniqueZ),1);
    summary.DrugA{f,1} = fd1{f};
    uniqueSess = unique(RR_SUM_V1P0.DATA(:,1));
    thetaSum = nan(length(uniqueZ),length(uniqueSess));
    for iz = 1 : length(uniqueZ)
        p = (f-1)*(length(uniqueZ)+1)+iz;
        subplot(length(fd1),length(uniqueZ)+1,p)
        hold on
        title(sprintf('%s, Zone %d',fd1{f},uniqueZ(iz)))
        xlabel(sprintf('%s',RR_SUM_V1P0.HEADER.Col{iv}))
        ylabel(sprintf('P[Entry]'))
        set(gca,'xlim',[1 30])
        set(gca,'ylim',[0 1])
        idZone = uniqueZ(iz)==RR_SUM_V1P0.DATA(:,7);
        uniqueSess = unique(RR_SUM_V1P0.DATA(idZone,1));
        logtheta = nan(length(uniqueSess),1);
        theta = logtheta;
        if dv~=17
            bSess = nan(2,length(uniqueSess));
        else
            bSess = nan(3,length(uniqueSess));
        end
        cmap = hsv(length(uniqueSess));
        for iSess = 1 : length(uniqueSess)
            idSess = uniqueSess(iSess)==RR_SUM_V1P0.DATA(:,1);
            idInc = idZone & idSess;
            
            X = log10(RR_SUM_V1P0.DATA(idInc,iv));
            Y = RR_SUM_V1P0.DATA(idInc,dv);
            
            if dv ~= 17
                bSess(:,iSess) = glmfit(X,Y,'binomial','link','logit');
                % 1/(1+e^-z) = 0.5
                % e^-z = 1
                % -z = 0
                % -(b(1)+b(2)*theta) = 0
                % b(1) = -b(2)*theta
                % b(1)/(-b(2)) = theta
                logtheta(iSess) = bSess(1,iSess)/(-bSess(2,iSess));
                theta(iSess) = 10.^logtheta(iSess);
                plot(theta(iSess),0.5,'x','markerfacecolor',cmap(iSess,:),'markeredgecolor',cmap(iSess,:))
            else
                bSess(:,iSess) = sigmoidfit(X,Y,3);
                logtheta(iSess) = bSess(1,iSess);
                theta(iSess) = 10.^logtheta(iSess);
                plot(theta(iSess),0.5,'x','markerfacecolor',cmap(iSess,:),'markeredgecolor',cmap(iSess,:))
            end
            
        end
        thetaSum(iz,1:length(theta)) = theta(:)';
        
        if dv ~= 17
            [ph,eh]=plot_grouped_Y(RR_SUM_V1P0.DATA(idZone,iv),RR_SUM_V1P0.DATA(idZone,dv),'dist','binomial');
        else
            [ph,eh]=plot_grouped_Y(RR_SUM_V1P0.DATA(idZone,iv),RR_SUM_V1P0.DATA(idZone,dv),'dist','normal');
        end
        set(ph,'markerfacecolor','k')
        set(ph,'markeredgecolor','k')
        set(eh,'color','k')
        m(iz) = nanmean(log10(theta));
        sem(iz) = nanstderr(log10(theta));
        hold off
    end
    summary.DrugA{f,2} = thetaSum;
    
    p = f*(length(uniqueZ)+1);
    subplot(length(fd1),length(uniqueZ)+1,p)
    hold on
    title(sprintf('%s',fd1{f}))
    eh = errorbar(uniqueZ,m,sem);
    ph = plot(uniqueZ,m);
    ylabel(sprintf('Log_{10}[Threshold]'))
    xlabel('Zone')
    set(gca,'xlim',[min(uniqueZ)-1 max(uniqueZ)+1])
    set(gca,'xtick',uniqueZ)
    set(gca,'ylim',[0 2])
    hold off
    
    barX{f,1} = fd1{f};
    barH{f,1} = m(:)';
    barE{f,1} = sem(:)';
    
    clear RR_SUM_V1P0
    popdir;
end

fh2 = figure;

for f = 1 : length(fd2)
    pushdir(fd2{f});
    
    fn = FindFiles('RR_SUM_V1P0.mat','CheckSubdirs',0);
    load(fn{1});
    ta = ta_from_RRSUM(RR_SUM_V1P0);
    RR_SUM_V1P0.HEADER.Col{17} = 'TIME ALLOCATION';
    RR_SUM_V1P0.DATA(:,17) = ta;
    uniqueZ = unique(RR_SUM_V1P0.DATA(:,7));
    m = nan(length(uniqueZ),1);
    sem = nan(length(uniqueZ),1);
    uniqueSess = unique(RR_SUM_V1P0.DATA(:,1));
    thetaSum = nan(length(uniqueZ),length(uniqueSess));
    summary.DrugA{f,1} = fd1{f};
    for iz = 1 : length(uniqueZ)
        p = (f-1)*(length(uniqueZ)+1)+iz;
        subplot(length(fd1),length(uniqueZ)+1,p)
        hold on
        title(sprintf('%s, Zone %d',fd2{f},uniqueZ(iz)))
        xlabel(sprintf('%s',RR_SUM_V1P0.HEADER.Col{iv}))
        ylabel(sprintf('P[Entry]'))
        set(gca,'xlim',[1 30])
        set(gca,'ylim',[0 1])
        idZone = uniqueZ(iz)==RR_SUM_V1P0.DATA(:,7);
        uniqueSess = unique(RR_SUM_V1P0.DATA(idZone,1));
        logtheta = nan(length(uniqueSess),1);
        theta = logtheta;
        if dv~=17
            bSess = nan(2,length(uniqueSess));
        else
            bSess = nan(3,length(uniqueSess));
        end
        cmap = hsv(length(uniqueSess));
        for iSess = 1 : length(uniqueSess)
            idSess = uniqueSess(iSess)==RR_SUM_V1P0.DATA(:,1);
            idInc = idZone & idSess;
            
            X = log10(RR_SUM_V1P0.DATA(idInc,iv));
            Y = RR_SUM_V1P0.DATA(idInc,dv);
            
            if dv ~= 17
                bSess(:,iSess) = glmfit(X,Y,'binomial','link','logit');
                % 1/(1+e^-z) = 0.5
                % e^-z = 1
                % -z = 0
                % -(b(1)+b(2)*theta) = 0
                % b(1) = -b(2)*theta
                % b(1)/(-b(2)) = theta
                logtheta(iSess) = bSess(1,iSess)/(-bSess(2,iSess));
                theta(iSess) = 10.^logtheta(iSess);
                plot(theta(iSess),0.5,'x','markerfacecolor',cmap(iSess,:),'markeredgecolor',cmap(iSess,:))
            else
                bSess(:,iSess) = sigmoidfit(X,Y,3);
                logtheta(iSess) = bSess(1,iSess);
                theta(iSess) = 10.^logtheta(iSess);
                plot(theta(iSess),0.5,'x','markerfacecolor',cmap(iSess,:),'markeredgecolor',cmap(iSess,:))
            end
        end
        thetaSum(iz,1:length(theta)) = theta(:)';
        if dv ~= 17
            [ph,eh]=plot_grouped_Y(RR_SUM_V1P0.DATA(idZone,iv),RR_SUM_V1P0.DATA(idZone,dv),'dist','binomial');
        else
            [ph,eh]=plot_grouped_Y(RR_SUM_V1P0.DATA(idZone,iv),RR_SUM_V1P0.DATA(idZone,dv),'dist','normal');
        end
        set(ph,'markerfacecolor','k')
        set(ph,'markeredgecolor','k')
        set(eh,'color','k')
        m(iz) = nanmean(log10(theta));
        sem(iz) = nanstderr(log10(theta));
        hold off
    end
    summary.DrugB{f,2} = thetaSum;
    
    p = f*(length(uniqueZ)+1);
    subplot(length(fd2),length(uniqueZ)+1,p)
    hold on
    title(sprintf('%s',fd2{f}))
    eh = errorbar(uniqueZ,m,sem);
    ph = plot(uniqueZ,m);
    ylabel(sprintf('Log_{10}[Threshold]'))
    xlabel('Zone')
    set(gca,'xlim',[min(uniqueZ)-1 max(uniqueZ)+1])
    set(gca,'xtick',uniqueZ)
    set(gca,'ylim',[0 2])
    hold off
    
    barX{f,2} = fd2{f};
    barH{f,2} = m(:)';
    barE{f,2} = sem(:)';
    
    clear RR_SUM_V1P0
    popdir;
end

fh3 = figure;
for f = 1 : max(size(summary.DrugA,1),size(summary.DrugB,1))
    doseA{f} = summary.DrugA{f,1};
    thetaA = summary.DrugA{f,2};
    logtheta = log10(thetaA);
    m1(:,f) = nanmean(logtheta,2);
    sem1(:,f) = nanstderr(logtheta')';

    doseB{f} = summary.DrugB{f,1};
    thetaB = summary.DrugB{f,2};
    logtheta = log10(thetaB);
    m2(:,f) = nanmean(logtheta,2);
    sem2(:,f) = nanstderr(logtheta')';
end
for p = 1 : size(m1,1)
    subplot(1,size(m1,1),p)
    hold on
    title(sprintf('Zone %d',p))
    
    A = m1(p,:);
    B = m2(p,:);
    Aerr = sem1(p,:);
    Berr = sem2(p,:);
    
    for ix = 1 : length(A)
        Xpatch = [ix-0.33 ix-0.33 ix ix];
        Ypatch = [0 A(ix) A(ix) 0];
        patch(Xpatch,Ypatch,[0 0 0],'facecolor','r','edgecolor','k','facealpha',0.3)
        eh=errorbar(ix-0.33/2,A(ix),Aerr(ix));
        set(eh,'color','k')
    end
    for ix = 1 : length(B)
        Xpatch = [ix+0.33 ix+0.33 ix ix];
        Ypatch = [0 B(ix) B(ix) 0];
        patch(Xpatch,Ypatch,[0 0 0],'facecolor','b','edgecolor','k','facealpha',0.3)
        eh=errorbar(ix+0.33/2,B(ix),Berr(ix));
        set(eh,'color','k')
        xticklabel{ix} = sprintf('%s\n%s',doseA{ix},doseB{ix});
    end
    xtick = 1:length(B);
    set(gca,'xtick',xtick)
    set(gca,'xticklabel',xticklabel)
    
    hold off
    
end