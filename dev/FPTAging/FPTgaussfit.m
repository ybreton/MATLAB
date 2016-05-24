
DATA = can2mat(VTETable.DATA);
uniqueRats = unique((DATA(:,1)));
newCol = nan(size(DATA,1),1);

Mu = nan(3,2);
MuCINot = nan(3,2);
MuCIVTE = nan(3,2);
Tau = nan(3,2);
TauCIVTE = nan(3,2);
TauCINot = nan(3,2);
alpha = 0.05/3;
nBoots = 10^(-(floor(log10(alpha/2)))+1);
for iAge=1:3
    idAge = DATA(:,2)==iAge;
    AgeIdPhi = DATA(idAge,10);
    idnan = isnan(AgeIdPhi)|isinf(AgeIdPhi);
    AgeIdPhi(idnan) = [];
    clf
    title(RatGroups{iAge});
    hold on
    [f,bin] = hist(AgeIdPhi,linspace(0,3,41));
    binw = mean(diff(bin));
    bh=bar(bin,f./sum(f),1);
    set(get(bh,'children'),'facecolor',[0.8 0.8 0.8])
    mixfit = gmdistribution.fit(AgeIdPhi,2);
    Mu(iAge,:) = mixfit.mu;
    [Mu(iAge,:),idSort] = sort(Mu(iAge,:));
    sigmas = squeeze(mixfit.Sigma(:));
    sigmas = sigmas(idSort);
%     Tau(iAge,:) = fit_gauss_taus(AgeIdPhi,Mu(iAge,:),sqrt(sigmas),[]);
    Tau(iAge,:) = mixfit.PComponents(idSort);
    plot(bin(:),cdf(mixfit,bin(:)+binw/2)-cdf(mixfit,bin(:)-binw/2),'r-')
    hold off
    drawnow
    
    [~,bootsam] = bootstrp(nBoots,@mean,AgeIdPhi);
    
    AgeMuLo = nan(1,nBoots);
    AgeMuHi = nan(1,nBoots);
    AgeTaus = nan(1,nBoots);
    parfor boot = 1 : size(bootsam,2)
        id = bootsam(:,boot);
        logIdPhi = AgeIdPhi(id);
        bootfit = gmdistribution.fit(logIdPhi,2);
        mus = bootfit.mu;
%         taus = mixfit.PComponents;
        posteriors = mixfit.posterior(logIdPhi);
        taus = nansum(posteriors)/size(posteriors,1);
%         taus = fit_gauss_taus(logIdPhi,Mu(iAge,:),sqrt(sigmas),[]);
        [mus,idSortBoot] = sort(mus);
        taus = taus(idSort);
        AgeMuLo(boot) = mus(1);
        AgeMuHi(boot) = mus(2);
        AgeTaus(boot) = taus(2);
    end
    MuCINot(iAge,1) = prctile(AgeMuLo,alpha/2*100);
    MuCINot(iAge,2) = prctile(AgeMuLo,(1-alpha/2)*100);
    MuCIVTE(iAge,1) = prctile(AgeMuHi,alpha/2*100);
    MuCIVTE(iAge,2) = prctile(AgeMuHi,(1-alpha/2)*100);
    
    TauCINot(iAge,1) = prctile(1-AgeTaus,alpha/2*100);
    TauCINot(iAge,2) = prctile(1-AgeTaus,(1-alpha/2)*100);
    TauCIVTE(iAge,1) = prctile(AgeTaus,alpha/2*100);
    TauCIVTE(iAge,2) = prctile(AgeTaus,(1-alpha/2)*100);
end
%%
figure;
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
hold on
bh=bar([1:3],Tau(:,2),0.8);
set(get(bh,'children'),'facecolor',[0.8 0.8 0.8])
eh=errorbar([1:3],Tau(:,2),Tau(:,2)-TauCIVTE(:,1),TauCIVTE(:,2)-Tau(:,2));
set(eh,'linestyle','none')
set(eh,'color','k')
xlabel('Age group')
set(gca,'xtick',1:3)
set(gca,'xticklabel',{'5 months' '9 months' '>27 months'})
ylabel(sprintf('Mixing coefficient of high component\n(Overall fit \\pm 95%% bootstrap CI)'))
set(gca,'ylim',[0.1 0.25])
set(gca,'ytick',[0.1:0.05:0.25])
hold off
saveas(gcf,[prefix 'pVTE_vs_Age.fig'],'fig')
saveas(gcf,[prefix 'pVTE_vs_Age.eps'],'epsc')
%%
idnan = isnan(DATA(:,10))|isinf(DATA(:,10));
DATA(idnan,:) = [];
%%
figure;
hold on
title('5 months')
singlefit = gmdistribution.fit(DATA(DATA(:,2)==1,10),1);
mixfit = gmdistribution.fit(DATA(DATA(:,2)==1,10),2);
[f,bin] = hist(DATA(DATA(:,2)==1,10),linspace(1,3,50));
binw = mean(diff(bin));
bh=bar(bin,f/sum(f),1);
set(get(bh,'children'),'facecolor',[0.8 0.8 0.8])
ph=plot(bin,cdf(mixfit,bin(:)+binw/2)-cdf(mixfit,bin(:)-binw/2),'r-');
[mu,id] = sort(mixfit.mu);
p = mixfit.PComponents(id);
dAIC = singlefit.AIC-mixfit.AIC;
RL = exp(-0.5*dAIC);
legendStr = {'Data' sprintf('Gaussian mixture:\n\\mu_1 = %.2f, p_1 = %.2f%%\n\\mu_2 = %.2f, p_2 = %.2f%%\n(RL 1:2 = %.3f)',mu(1),p(1)*100,mu(2),p(2)*100,RL)};
xlabel(sprintf('Log_{10}[Id\\phi]'))
ylabel(sprintf('Proportion of laps'))
hold off
legend([get(bh,'children') ph],legendStr)
saveas(gcf,'MixtureFit_LogIdPhi_5mo.fig','fig')
%%
figure;
hold on
title('9 months')
singlefit = gmdistribution.fit(DATA(DATA(:,2)==2,10),1);
mixfit = gmdistribution.fit(DATA(DATA(:,2)==2,10),2);
[f,bin] = hist(DATA(DATA(:,2)==2,10),linspace(1,3,50));
binw = mean(diff(bin));
bh=bar(bin,f/sum(f),1);
set(get(bh,'children'),'facecolor',[0.8 0.8 0.8])
ph=plot(bin,cdf(mixfit,bin(:)+binw/2)-cdf(mixfit,bin(:)-binw/2),'r-');
[mu,id] = sort(mixfit.mu);
p = mixfit.PComponents(id);
dAIC = singlefit.AIC-mixfit.AIC;
RL = exp(-0.5*dAIC);
legendStr = {sprintf('Log_{10}[Id\\phi]') sprintf('Gaussian mixture:\n\\mu_1 = %.2f, p_1 = %.2f%%\n\\mu_2 = %.2f, p_2 = %.2f%%\n(RL 1:2 = %.3f)',mu(1),p(1)*100,mu(2),p(2)*100,RL)};
legend([get(bh,'children') ph],legendStr)
xlabel(sprintf('Log_{10}[Id\\phi]'))
ylabel(sprintf('Proportion of laps'))
hold off
saveas(gcf,'MixtureFit_LogIdPhi_9mo.fig','fig')
%%
figure;
hold on
title('>27 months')
singlefit = gmdistribution.fit(DATA(DATA(:,2)==3,10),1);
mixfit = gmdistribution.fit(DATA(DATA(:,2)==3,10),2);
[f,bin] = hist(DATA(DATA(:,2)==3,10),linspace(1,3,50));
binw = mean(diff(bin));
bh=bar(bin,f/sum(f),1);
set(get(bh,'children'),'facecolor',[0.7 0.7 0.7])
ph=plot(bin,cdf(mixfit,bin(:)+binw/2)-cdf(mixfit,bin(:)-binw/2),'r-');
[mu,id] = sort(mixfit.mu);
p = mixfit.PComponents(id);
dAIC = singlefit.AIC-mixfit.AIC;
RL = exp(-0.5*dAIC);
legendStr = {sprintf('Log_{10}[Id\\phi]') sprintf('Gaussian mixture:\n\\mu_1 = %.2f, p_1 = %.2f%%\n\\mu_2 = %.2f, p_2 = %.2f%%\n(RL 1:2 = %.1f)',mu(1),p(1)*100,mu(2),p(2)*100,RL)};
legend([get(bh,'children') ph],legendStr)
xlabel(sprintf('Log_{10}[Id\\phi]'))
ylabel(sprintf('Proportion of laps'))
hold off
saveas(gcf,'MixtureFit_LogIdPhi_27mo.fig','fig')