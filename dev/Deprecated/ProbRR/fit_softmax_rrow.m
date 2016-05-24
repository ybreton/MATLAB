function params = fit_softmax_rrow(zone,number,delay,probability,choice,varargin)

nZones = length(unique(zone));
logbeta0 = 1;
% Vskip0 = (median(number.*(1./(1+delay)).*probability));
Vskip0 = 0;
logF0 = 0;
logK0 = 0;
debug = false;
alpha = 0.05;
plotResult = true;
process_varargin(varargin);
nBoots = 10.^(-floor(log10(alpha/2))+1);

params0(1) = logbeta0;
cols{1} = 'Beta';
vskipCol = [];
for z = 1 : nZones
    params0(length(cols)+1) = Vskip0;
    vskipCol = [vskipCol; length(cols)+1];
    cols{length(cols)+1} = sprintf('Vskip%d',z);
end
kCol = length(cols)+1;
cols{length(cols)+1} = 'K';
params0(length(cols)+1) = logK0;
flavCol = [];
for z = 2 : nZones
    params0(length(cols)+1) = logF0;
    flavCol = [flavCol; length(cols)+1];
    cols{length(cols)+1} = sprintf('F%d',z);
end

lb = [];
ub = [];
% lb(1) = 0;
% lb(2) = 0;
% lb(3) = -inf;
% lb(4:2+length(unique(zone))) = -inf(1,length(logF0));
% ub(1) = inf;
% ub(2) = inf;
% ub(3) = inf;
% ub(4:2+length(unique(zone))) = inf(1,length(logF0));

options = optimset('algorithm','interior-point','display','off','tolX',10^-6,'tolFun',10^-6);

x(:,1) = zone;
x(:,2) = number;
x(:,3) = delay;
x(:,4) = probability;
y = double(choice);

paramsFit = fminsearch(@(params) errFunc(params,x,y,vskipCol,flavCol,kCol,debug),params0,options);
params.DATA = 10.^(paramsFit(:)');
params.DATA(vskipCol) = paramsFit(vskipCol);
params.HEADER.Col = cols;
params.HEADER.Row{1,1} = 'Estimate';

if plotResult
    clf
    ah=subplot(1,2,2);
    set(ah,'position',[0.25 0.1 0.675 0.815])
    hold on
    cla
    uniqueZ = unique(zone);
    cmap = hsv(length(uniqueZ));
    legendStr = cell(1,length(uniqueZ));
    value = valFunc(paramsFit,vskipCol,flavCol,kCol,x);
    for z = 1 : length(uniqueZ)
        idz = zone == uniqueZ(z);
        [ph(z),eh]=plot_grouped_Y((value(idz)),y(idz),'dist','binomial');
        set(ph(z),'markerfacecolor',cmap(z,:))
        set(ph(z),'markeredgecolor',cmap(z,:))
        set(eh,'color',cmap(z,:))
        if z>1
            legendStr{z} = sprintf('Zone %d\nN_{%d}/N_1=%.3f\nV_{skip}=%.6f',uniqueZ(z),uniqueZ(z),10.^paramsFit(flavCol(z-1)),paramsFit(vskipCol(z)));
        else
            legendStr{z} = sprintf('Zone %d\nV_{skip}=%.6f',uniqueZ(z),paramsFit(vskipCol(z)));
        end
        hold on
        ph(length(uniqueZ)+z)=plot((sort(value)),behavFunc(paramsFit,sort(value),paramsFit(vskipCol(z))),'-','linewidth',2,'color',cmap(z,:));
        legendStr{length(uniqueZ)+z} = sprintf('Softmax fit\n\\beta=%.3f',10.^paramsFit(1));
    end
    
    lh=legend(ph,legendStr);
    set(lh,'location','southeast')
    xh=xlabel('($N\times\frac{N_i}{N_1}\times\frac{1}{1+k\times D})\times P_r$)');
    set(xh,'interpreter','latex')
    title(sprintf('Choice as a function of\nprobability- and delay-discounted value\n(Log_{10}[k_{delay}]=%.6f)',paramsFit(3)))
    set(gca,'ylim',[-0.05 1.05])
    set(gca,'ytick',[])
    set(gca,'yticklabel',[])
    set(gca,'ycolor','w')
    hold off
    set(gca,'xscale','log')
    xlim = get(gca,'xlim');
    ah=axes;
    hold on
    set(ah,'position',[0.1 0.1 0.1 0.815])
    ylabel(sprintf('Probability of choice\n(\\pm95%% Binomial Confidence Interval)'))
    id0 = value==0;
    set(gca,'xlim',[0-xlim(1) xlim(1)])
    set(gca,'ylim',[-0.05 1.05])
    set(gca,'xtick',0)
    set(gca,'xticklabel',0)
    if any(id0)
        for z = 1 : length(uniqueZ)
            idz = zone == uniqueZ(z);
            if any(idz&id0)
                [ph0,eh0]=plot_grouped_Y((value(idz&id0)),y(idz&id0),'dist','binomial');
                set(ph0,'markerfacecolor',cmap(z,:))
                set(ph0,'markeredgecolor',cmap(z,:))
                set(eh0,'color',cmap(z,:))
                hold on
                plot(linspace(0-xlim(1),xlim(1),100),behavFunc(paramsFit,linspace(0-xlim(1),xlim(1),100),paramsFit(vskipCol(z))),'-','linewidth',2,'color',cmap(z,:));
                hold off
            end
        end
        hold off
    end
    drawnow
end

uniqueX = unique(x,'rows');
y0 = [];
x0 = [];
for ix = 1 : size(uniqueX,1)
    idx = all(repmat(uniqueX(ix,:),size(x,1),1) == x,2);
    ytemp = y(idx);
    if length(ytemp)>1
        [~,bootsam] = bootstrp(nBoots,@mean,ytemp);
    elseif length(ytemp)==1
        bootsam = 1;
    end
    y0 = [y0; ytemp(bootsam)];
    x0 = [x0; repmat(uniqueX(ix,:),size(ytemp,1),1)];
end
nF = length(unique(zone))-1;
fprintf('%.4f\t\t',[10.^paramsFit(1) paramsFit(vskipCol) 10.^paramsFit(kCol) 10.^paramsFit(flavCol)])

onePercent = ceil(nBoots*0.01);
tenPercent = ceil(nBoots*0.1);
fprintf('\n')
t0 = clock;

betaList = nan(nBoots,1);
VList = nan(nBoots,nZones);
kList = nan(nBoots,1);
fList = nan(nBoots,1);

for boot = 1 : nBoots
    yboot = y0(:,boot);
    pboot = fminsearch(@(params) errFunc(params,x0,yboot,vskipCol,flavCol,kCol,false),paramsFit,options);
    betaList(boot) = 10.^pboot(1);
    VList(boot,1:nZones) = pboot(vskipCol);
    kList(boot) = 10.^pboot(kCol);
    fList(boot,1:nF) = 10.^pboot(flavCol);
    if mod(boot,onePercent)==0
        fprintf('.')
    end
    if mod(boot,tenPercent)==0
        t1 = clock;
        e = etime(t1,t0);
        r = (e/boot)*(nBoots-boot);
        fprintf('\n')
        fprintf('%.1fs elapsed, %.1fs remain.',e,r)
        fprintf('\n')
    end
end

fprintf('\n');
betaCI(1) = prctile(betaList,alpha/2*100);
betaCI(2,1) = prctile(betaList,(1-alpha/2)*100);
VskiCI(1,1:nZones) = prctile(VList,alpha/2*100,2);
VskiCI(2,1:nZones) = prctile(VList,(1-alpha/2)*100,2);
kCI(1) = prctile(kList,alpha/2*100);
kCI(2,1) = prctile(kList,(1-alpha/2)*100);
fCI(1,1:nF) = prctile(fList,alpha/2*100,1);
fCI(2,1:nF) = prctile(fList,(1-alpha/2)*100,1);
params.DATA(2:3,:) = [betaCI VskiCI kCI fCI];
params.HEADER.Row{2,1} = sprintf('LB %.2f%% CI', (1-alpha)*100);
params.HEADER.Row{3,1} = sprintf('UB %.2f%% CI', (1-alpha)*100);

function SSerr = errFunc(params,x,y,vskipCol,flavCol,kCol,debug)
[Vstay,Vgo] = valFunc(params,vskipCol,flavCol,kCol,x);
yhat = behavFunc(params,Vstay,Vgo);
dev = yhat(:)-y(:);
SSerr = dev(:)'*dev(:);

if debug
    cla
    zone = x(:,1);
    uniqueZ = unique(zone);
    cmap = hsv(length(uniqueZ));
    legendStr = cell(1,length(uniqueZ));
    for z = 1 : length(uniqueZ)
        idz = zone == uniqueZ(z);
        [ph(z),eh]=plot_grouped_Y((Vstay(idz)),y(idz),'dist','binomial');
        set(ph(z),'markerfacecolor',cmap(z,:))
        set(ph(z),'markeredgecolor',cmap(z,:))
        set(eh,'color',cmap(z,:))
        legendStr{z} = sprintf('%d',uniqueZ(z));
        
        hold on
        plot(sort(Vstay),behavFunc(params,sort(Vstay),params(vskipCol(z))),'-','color',cmap(z,:))
        hold off
    end
    legend(ph,legendStr)
    hold on
    hold off
    drawnow
end

function [valueA,valueB] = valFunc(params,vskipCol,flavCol,kCol,x)
zone = x(:,1);
number = x(:,2);
delay = x(:,3);
probability = x(:,4);

logF = params(flavCol);
logK = params(kCol);
Vskip = params(vskipCol);

uniqueZ = unique(zone);
idz = uniqueZ(1) == zone;
nf(idz) = number(idz);
for z = 2 : length(uniqueZ)
    idz = uniqueZ(z) == zone;
    nf(idz) = number(idz)*(10.^logF(z-1));
end
d = 1./(1+(10.^logK).*delay);
Pr = probability;
valueA = nf(:).*d(:).*Pr(:);
valueB = nan(size(valueA));
for z = 1 : length(uniqueZ)
    idz = uniqueZ(z) == zone;
    valueB(idz) = Vskip(z);
end

function choice = behavFunc(params,valueA,valueB)
logbeta = params(1);
beta = 10.^logbeta;
e = exp(1);

choice = e.^(beta*valueA)./(e.^(beta*valueA)+e.^(beta*valueB));