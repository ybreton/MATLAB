function [m,lb,ub] = regressionBCI(b,X,alpha,varargin)
% Confidence interval for a list of intercepts and slopes in b at each
% value of X for the Y predicted at X by the list of regression slopes.
% 
% Default link function is logit.
%

link = 'logit';
process_varargin(varargin);

MinPow = -(floor(log10(alpha)));
nMin = 10.^MinPow;
% nMin corresponds to 0.5*alpha%.
% nBoots corresponds to 100%.

nBoots = nMin/(0.5*alpha);
if size(b,2)>1
    [bootmeanB0,bootsam]=bootstrp(nBoots,@mean,b(1,:));
else
    bootsam = ones(1,nBoots);
end

uniqueX = unique(X);
m = nan(length(uniqueX),1);
lb = m;
ub = m;
for iX = 1 : length(uniqueX)
    y = nan(size(bootsam));
    xi = uniqueX(iX);
    uniqueSam = unique(bootsam(:));
    for sam = 1 : length(uniqueSam)
        id = bootsam == uniqueSam(sam);
        y(id) = glmval(b(:,sam),xi,link);
    end
    Y = mean(y,1);
    m(iX) = mean(Y);
    lb(iX) = prctile(Y,100*(alpha/2));
    ub(iX) = prctile(Y,100*(1-(alpha/2)));
end