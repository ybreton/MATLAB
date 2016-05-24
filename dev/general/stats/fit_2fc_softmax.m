function [params,ci] = fit_2fc_softmax(x,y,varargin)
%
%
%
%

beta0 = 0;
Vskip0 = median(x);
debug = false;
alpha = 0.05;
plotResult = false;
process_varargin(varargin);
nBoots = 10.^(-floor(log10(alpha/2))+1);

params0(1) = beta0;
params0(2) = Vskip0;
options = optimset('algorithm','interior-point','display','off');

lb = [0 min(x)];
ub = [inf max(x)];
params = fmincon(@(params) errFunc(params,x,y,debug),params0,[],[],[],[],lb,ub,[],options);

if nargout > 1
    uniqueX = unique(x);
    bootY = [];
    bootX = [];
    for ix = 1 : length(uniqueX)
        idx = uniqueX(ix)==x;
        ytemp = y(idx);
        [~,bootsam] = bootstrp(nBoots,'mean',ytemp);
        bootY = [bootY; ytemp(bootsam)];
        bootX = [bootX; repmat(uniqueX(ix),size(ytemp,1),nBoots)];
    end
    betaCI = nan(nBoots,1);
    VskipCI = nan(nBoots,1);
    bootStrpY = nan(length(uniqueX),nBoots);
    
    t0 = clock;
    onePercent = floor(nBoots*0.01);
    tenPercent = floor(nBoots*0.1);
    fprintf('\n');
    for boot = 1 : nBoots
        pboot = fmincon(@(params) errFunc(params,bootX(:,boot),bootY(:,boot),false),params,[],[],[],[],lb,ub,[],options);
        betaCI(boot) = pboot(1);
        VskipCI(boot) = pboot(2);
        if mod(boot,onePercent)==0
            fprintf('.')
        end
        if mod(boot,tenPercent)==0
            fprintf('\n')
            t1 = clock;
            e = etime(t1,t0);
            tper = e/boot;
            remain = tper*(nBoots-boot);
            fprintf('%d%% Complete. %.1fs elapsed. %.1fs remain.',boot/onePercent,e,remain)
            fprintf('\n')
        end
        bootStrpY(:,boot) = behavFunc(pboot,uniqueX);
    end
    ci(1,1) = prctile(betaCI,alpha/2*100);
    ci(1,2) = prctile(betaCI,(1-alpha/2)*100);
    ci(2,1) = prctile(VskipCI,alpha/2*100);
    ci(2,2) = prctile(VskipCI,(1-alpha/2)*100);
    Yci(:,1) = prctile(bootStrpY,alpha/2*100,2);
    Yci(:,2) = prctile(bootStrpY,(1-alpha/2)*100,2);
end

if plotResult
    clf
    ph(1)=plot_grouped_Y(x,y);
    legendStr{1}='Data';
    hold on
    ph(2)=plot(sort(x),behavFunc(params,sort(x)),'r-');
    legendStr{2}='Softmax fit';
    if nargout>1
        ph(3)=plot(uniqueX,Yci(:,1),'r:');
        legendStr{3}='95% Bootstrap CI';
        plot(uniqueX,Yci(:,2),'r:')
    end
    legend(ph,legendStr);
    hold off
end


function SSerr = errFunc(params,x,y,debug)
yhat = behavFunc(params,x);
dev = yhat(:)-y(:);
SSerr = dev(:)'*dev(:);

if debug
    cla
    [ph,eh]=plot_grouped_Y(x,y,'dist','binomial');
    hold on
    plot(sort(x),behavFunc(params,sort(x)),'r-')
    hold off
    drawnow
end

function yhat = behavFunc(params,x)
beta = params(1);
Vskip = params(2);

e = exp(1);

yhat = e.^(beta*x(:))./(e.^(beta*x(:))+e.^(beta*Vskip));