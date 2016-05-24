function sd = sdHeavisideThresholds(sd,varargin)
%
%
%
%

threshFun = @RRheaviside;
debug = true;
process_varargin(varargin);

d = sd.ZoneDelay(:);
sg = sd.stayGo(:);
z = sd.ZoneIn(:);
uniqueZones = unique(z);

thresholds = nan(1,length(sd.ZoneIn));
if debug
    clf
    cmap = jet(length(uniqueZones));
end
for iZ=uniqueZones(:)'
    idz = z==iZ;
    idOK = ~isnan(d)&~isnan(sg);
    X = d(idz&idOK);
    y = sg(idz&idOK);
    if isempty(threshFun)
        threshFun = @RRheaviside;
    elseif isa(threshFun,'function_handle')
        theta = nanmean(threshFun(X,y));
    end
    thresholds(idz&idOK) = theta;
    if debug
        m = histcn(X,min(d(:)):max(d(:)),'AccumData',y,'Fun',@nanmean);
        predX = unique(X);
        predY = double(predX<theta);
        predY(predX==theta) = 0.5;
        hold on
        plot(min(d(:)):max(d(:)),m,'o','markeredgecolor',cmap(iZ,:),'markerfacecolor',cmap(iZ,:))
        plot(predX,predY,'-','color',cmap(iZ,:),'linewidth',3)
        hold off
        drawnow;
    end
end

sd.HeavisideThresholds = thresholds;