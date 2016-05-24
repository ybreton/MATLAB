function fit = fit_RR_sigmoids_overall(RR_SUM_V1P0,varargin)

iv = 5;
dv = 11;
nBoots = 1000;
alpha = 0.05;
process_varargin(varargin);

uniqueZ = unique(RR_SUM_V1P0.DATA(RR_SUM_V1P0.DATA(:,8)==0,7));
for z = 1 : length(uniqueZ)
    idZone = uniqueZ(z) == RR_SUM_V1P0.DATA(:,7);
    
    X = RR_SUM_V1P0.DATA(idZone,iv);
    Y = RR_SUM_V1P0.DATA(idZone,dv);
    
    % Primary fit.
    bPrimary = glmfit(X,Y,'binomial','link','logit');
    uniqueX = unique(X);
    resampled_y = cell(length(uniqueX),1);
    resampled_x = cell(length(uniqueX),1);
    for ix = 1 : length(uniqueX)
        idx = uniqueX(ix) == X;
        y = Y(idx);
        [bootstat,bootsam]=bootstrp(nBoots,@mean,y);
        resampled_y{ix} = y(bootsam);
        resampled_x{ix} = X(idx);
    end
    bList = cell(1,nBoots);
    parfor boot = 1 : nBoots
        x = [];
        y = [];
        for ix = 1 : length(resampled_y)
            resampling_at_x = resampled_y{ix};
            value_at_x = resampled_x{ix};
            y = [y; resampling_at_x(:,boot)];
            x = [x; value_at_x];
        end
        bBoot = glmfit(x,y,'binomial','link','logit');
        bList{boot} = bBoot;
        thetaList(boot) = bBoot(1)./(-bBoot(2));
    end
    thetaCI(1) = prctile(thetaList,alpha*100);
    thetaCI(2) = prctile(thetaList,(1-alpha)*100);
    theta = median(thetaList);
    fit(z).bList = bList;
    fit(z).medianTheta = theta;
    fit(z).thetaCI = thetaCI;
    fit(z).primaryFit = bPrimary;
    fit(z).primaryFitTheta = bPrimary(1)./(-bPrimary(2));
end