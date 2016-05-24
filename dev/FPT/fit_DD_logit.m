function [params] = fit_DD_logit(SSN,Laps,nPellets,Delays,Choices)
% Laps: lap number
% nPellets: pellet ratio
% Delays: last delay chosen
% Choices: delay side chosen
% Identifies the delay-discounting functions from the chosen delays and
% pellet ratios.
% [params] = fit_DD_logit(SSN,Laps,nPellets,Delays,Choices)
% where         SSN is a list of sessions,
%               Laps is a list of lap numbers,
%               nPellets is a list of pellet ratios,
%               Choices is 1 for delay chosen, 0 for delay not chosen,
% and
%               params is a structure with fieldsPR;
%               .PRs: Pellet ratios,
%               .ADs: Associated adjusting delays,
%               .Rsq: (Deviance of H0-Deviance of H1)/(Deviance of H0),
%               .infAD: infinite adjusting delays not included,
%               .Table: table of the input data,
%                   .Table.HEADER = {'SSN' 'Laps' 'nPellets' 'Delay' 'Choice'}
%                   .Table.DATA = [SSN Laps nPellets Delays Choices]
%               .choice: logistic regressions (AD->Choice) for each PR
%               .DDall: delay discounting regression (PR->AD)
%               .discountAll: delay discounting factor (k)
%
%
%

nP = unique(nPellets);
X = unique(Delays);
Sess = unique(SSN);
idEx = false(length(Sess),1);
idInf = false(length(Sess),1);
b = nan(2,length(Sess));
dev1 = nan(1,length(Sess)); % deviance of logistic regression model
dev0 = nan(1,length(Sess)); % deviance of null hypothesis model
Rsq = nan(1,length(Sess)); % likelihood ratio R^2 = (D0-D1)/D0
for s = 1 : length(Sess);
    idS = SSN == Sess(s);
    
    [b(:,s),dev1(s)] = glmfit(log10(Delays(idS)),Choices(idS),'binomial');
    [~,dev0(s)] = glmfit(ones(length(Delays(idS)),1),Choices(idS),'binomial','constant','off');
    Rsq(s) = (dev0(s)-dev1(s))/dev0(s);
%     b(:,s) = fit_2forced_choice(log10(Delays(idS)),Choices(idS));
    if all(Choices(idS)==0) || all(Choices(idS)==1)
        idEx(s) = true;
    end
    if b(2,s)>=0
        idEx(s) = true;
    end
    if sum(Choices(idS))/length(Choices(idS))<=0.05 | sum(Choices(idS))/length(Choices(idS))>=0.95
        idEx(s) = true;
    end
    AD(s) = 10.^(-b(1,s)/b(2,s));
%     AD(s) = (-b(1,s)/b(2,s));
%     AD(s) = 10^b(2,s);
    if AD(s)>max(Delays(idS))
        idInf(s) = true;
    end
    
    m = nan(length(X),1);
    lb = m;
    ub = m;
    for iD = 1 : length(X)
        idD = Delays==iD;
        E = sum(double(Choices(idS&idD)==1));
        S = sum(double(Choices(idS&idD)==0));
        [m(iD),lb(iD),ub(iD)] = binocis(E,S,1,0.05);
    end
    PR(s) = max(nPellets(idS));
    iP = nP==PR(s);
    subplot(2,length(nP),nP(iP))
    hold on
    title(sprintf('%d Pellets',PR(s)))
    if idEx(s)
        color = [0.8 0.8 0.8];
    else
        color = 'k';
        plot(log10(AD(s)),0.5,'rx')
    end
    plot(log10(X),m,'o','markeredgecolor',color)
%     eh=errorbar(X,m,m-lb,ub-m);
%     set(eh,'linestyle','none')
%     set(eh,'color','k')
    plot(log10(X),glmval(b(:,s),log10(X),'logit'),'-','color',color)
%     pred = exp(log10(X)*b(2,s))./(exp(log10(X)*b(2,s))+exp(b(1,s)));
%     plot(log10(X),pred,'-','color',color)
    set(gca,'xlim',[log10(1) log10(30)])
    set(gca,'ylim',[-0.05 1.05])
    hold off
end
bD = glmfit(AD(~idEx),PR(~idEx));
bDall = glmfit(AD(~idInf),PR(~idInf));
k = bD(2)/bD(1);
kall = bDall(2)/bDall(1);
subplot(2,2,3)
hold on
ph=plot(AD(~idInf),PR(~idInf),'rx');
ph(2)=plot(sort(AD(~idInf)),glmval(bD,sort(AD(~idInf)),'identity'),'r-');
legendStr{1} = 'Finite adjusting delay';
legendStr{2} = sprintf('A = %.1f + %.1f\\times D\nk=%.3f',bD,k);

% if any(idEx)
%     ph(3)=plot(AD(idEx),PR(idEx),'bs');
%     ph(4)=plot(sort(AD(~idInf)),glmval(bDall,sort(AD(~idInf)),'identity'),'b-');
%     legendStr{3} = 'Positive slope or chose one side';
%     legendStr{4} = sprintf('A = %.1f + %.1f\\times D\nk=%.3f',bDall,kall);
% end

legend(ph,legendStr)
set(gca,'xlim',[0 60])
set(gca,'ylim',[0 5])
xlabel('Inferred Adjusting Delay')
ylabel('Pellet Ratio')
hold off
subplot(2,4,7)
hold on
hist(Rsq)
xlabel('Likelihood ratio R^2')
ylabel('Frequency')
hold off
subplot(2,4,8)
hold on
nP = unique(PR);
[m,lb,ub] = binocis(sum(double(idEx==0)),sum(double(idEx==1)),1,0.05);
for iP = 1 : length(nP)
    idP = PR==nP(iP);
    F = sum(double(idEx(idP)==1));
    S = sum(double(idEx(idP)==0));
    [m(iP+1),lb(iP+1),ub(iP+1)] = binocis(S,F,1,0.05);
end
set(gca,'ylim',[-0.05 1.05])
set(gca,'xtick',[1:5])
set(gca,'xlim',[0 6])
set(gca,'xticklabel',{'1' '2' '3' '4' 'Overall'})
xlabel('Pellet Ratio')
ylabel('Proportion of "good" sessions')
ph=plot(nP,m(2:end),'bo','markerfacecolor','b');
ph(2)=plot([4.5 5.5],[m(1) m(1)],'b-','linewidth',2);
eh=errorbar(nP,m(2:end),m(2:end)-lb(2:end),ub(2:end)-m(2:end));
set(eh,'linestyle','none')
set(eh,'color','b')
patch([4.5 4.5 5.5 5.5],[lb(1) ub(1) ub(1) lb(1)],[0 0 1],'facealpha',0.1,'edgecolor','none')

hold off



params.PRs = PR;
params.ADs = AD;
params.Rsq = Rsq;
params.badSSN = idEx;
params.infAD = idInf;
params.Table.HEADER = {'SSN' 'Laps' 'nPellets' 'Delay' 'Choice'};
params.Table.DATA = [SSN Laps nPellets Delays Choices];
params.choice = b;
% params.DD = bD;
params.DDall = bDall;
% params.discount = k;
params.discountAll = kall;