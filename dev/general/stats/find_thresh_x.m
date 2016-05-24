function threshTab = find_thresh_x(x,y,varargin)
% Find threshold x value based on (x,y).
% Default threshold is x where y=0.5.
%
%
%

threshY = 0.5;
plotResult = false;
process_varargin(varargin);
% 1/(1+e^-z) = threshY
% 1+e^-z = 1/threshY
% e^-z = (1/threshY)-1
% -z = log((1/threshY)-1)
% z = -log((1/threshY)-1)
% b0 + b1*threshX = -log((1/threshY)-1)
% b1*threshX = -log((1/threshY)-1) - b0
% threshX = (-log((1/threshY)-1) - b0)/b1

if size(x,2)>1
    IV = x(:,1);
    GV = x(:,2:end);
    GVs = size(GV,2);
else
    IV = x(:);
    GV = ones(length(IV),1);
    GVs = 0;
end

y = logical(y);

uniqueGrp = unique(GV,'rows');
for g = 1 : size(uniqueGrp,1)
    id = all(repmat(uniqueGrp(g,:),size(GV,1),1)==GV,2);
    Ygrp = y(id);
    Xgrp = x(id);
    
    b(:,g) = glmfit(Xgrp,Ygrp,'binomial');
end
b(3,:) = (-log((1./threshY)-1)-b(1,:))./b(2,:);

DATA = [];
if size(uniqueGrp,1)>1
    DATA(:,1:size(GV,2)) = uniqueGrp;
    for c = 1 : size(GV,2)
        HEADER{c} = sprintf('X%d',c);
    end
end
HEADER{GVs+1} = sprintf('Intercept');
HEADER{GVs+2} = sprintf('Slope');
HEADER{GVs+3} = sprintf('X @Y=%.3f',threshY);
DATA = [DATA b'];

threshTab.HEADER = HEADER;
threshTab.DATA = DATA;

if plotResult
    cmap = hsv(size(uniqueGrp,1));
    for g = 1 : size(uniqueGrp,1)
        id = all(repmat(uniqueGrp(g,:),size(GV,1),1)==GV,2);
        Ygrp = y(id);
        Xgrp = x(id);
        hold on
        ph(g)=plot_grouped_Y(Xgrp,Ygrp);
        hold off
        hold on
        set(ph(g),'markerfacecolor',cmap(g,:));
        plot(sort(Xgrp),glmval(b(1:2,g),sort(Xgrp),'logit'),'-','linewidth',2,'color',cmap(g,:));
        plot(b(3,g),threshY,'x','linewidth',1.5,'markerfacecolor',cmap(g,:),'markeredgecolor',cmap(g,:),'markersize',10);
        hold off
        str = sprintf('%d,',uniqueGrp(g,:));
        str = str(1:end-1);
        legendStr{g} = str;
    end
    legend(ph,legendStr)
end