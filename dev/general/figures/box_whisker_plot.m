function [ph,stats] = box_whisker_plot(varargin)
% makes a box-whisker plot.
% box_whisker_plot('x',x,'data',data) makes a box-whisker plot of the data
% in data for each x in x. If no x is specified, a box-whisker plot is made
% of all the data provided.
% box_whisker_plot('mid',median,'m',mean,'iqr',[lo hi],'range',[lo hi]) makes a
% box-whisker plot with the specified median, inter-quartile range and full
% range.
% Optionally, 
%   bar_width   the full-width of the bar can be set in terms of a proportion
%               of the minimum difference in x. When no x is provided, this
%               is set to 0.25. Default is 0.5.
%   facecolor   the face color of each bar can be set (in order of
%               increasing x). Default is white.
%   edgecolor   the edge color of each bar can be set (in order of
%               increasing x). Default is black.
%   plot_data_points 
%               overlays the individual data points on the box-whisker
%               plots. Default is false.
%
% ph = box_whisker_plot(...) returns handles to all children in current
% axes.
% [ph,stats] = box_whisker_plot(...) also returns a stats structure array
% with fields
%   x           a list of grouping values,
%   median      median of the data at each grouping value,
%   iqr         inter-quartile range of the data at each grouping value,
%   range       full range of the data at each grouping value,
%   mean        mean of the data at each grouping value,
%   std         standard deviation of the data at each grouping value,
%   n           number of data points at each grouping value,
%   invalidN    number of invalid (infinite or nan) data points at each
%               grouping value,
%   data        a m x 1 structure array with fields X and Y with the data
%               at each grouping value.
%

x = [];
data = [];
m = nan;
mid = nan;
iqr = [nan nan];
r = [nan nan];

bar_width = 0.5;
facecolor = [1 1 1];
edgecolor = [0 0 0];
plot_data_points = false;

process_varargin(varargin);

if isempty(x) && ~isempty(data)
    x = ones(length(data));
end
if isempty(x) && isempty(data)
    x = 1;
end

uniqueX = unique(x);
if length(uniqueX)>1
    w = min(diff(uniqueX));
else
    w = 0.5;
end
if size(facecolor,1)==1
    % single face colour specified.
    facecolor = repmat(facecolor,length(uniqueX),1);
end
if size(edgecolor,1)==1
    % single face colour specified.
    edgecolor = repmat(edgecolor,length(uniqueX),1);
end

if nargout>1
    stats.x(:,1) = nan(length(uniqueX),1);
    stats.median(:,1) = nan(length(uniqueX),1);
    stats.iqr = nan(length(uniqueX),2);
    stats.range = nan(length(uniqueX),2);
    stats.mean(:,1) = nan(length(uniqueX),1);
    stats.std(:,1) = nan(length(uniqueX),1);
    stats.n(:,1) = nan(length(uniqueX),1);
    stats.invalidN(:,1) = nan(length(uniqueX),1);
    dat = struct('X',nan,'Y',nan);
    stats.data(length(uniqueX)) = dat;
end

for iv = 1 : length(uniqueX)
    id = x==uniqueX(iv);
    
    if ~isempty(data)
        Y = data(id);
        id = isnan(Y)|isinf(Y);
        
        mid = nanmedian(Y);
        lo = prctile(Y(~id),25);
        hi = prctile(Y(~id),75);
        r = [nanmin(Y) nanmax(Y)];
        m = nanmean(Y);
    else
        lo = min(iqr);
        hi = max(iqr);
    end
    
    if nargout>1 && ~isempty(data)
        stats.x(iv,1) = uniqueX(iv);
        stats.median(iv,1) = mid;
        stats.iqr(iv,:) = [lo hi];
        stats.range(iv,:) = r;
        stats.mean(iv,1) = m;
        stats.std(iv,1) = nanstd(Y);
        stats.n(iv,1) = length(Y(~id));
        stats.invalidN(iv,1) = length(Y(id));
        stats.data(iv).X = ones(length(Y),1)*uniqueX(iv);
        stats.data(iv).Y = Y;
    elseif nargout>1 && isempty(data)
        stats.x(iv,1) = nan;
        stats.median(iv,1) = mid;
        stats.iqr(iv,:) = sort(iqr);
        stats.range(iv,:) = r;
        stats.mean(iv,1) = m;
        stats.std(iv,1) = nan;
        stats.n(iv,1) = nan;
        stats.invalidN(iv,1) = nan;
        stats.data(iv).X = nan;
        stats.data(iv).Y = nan;
    end
    
    hold on
    eh=errorbar(uniqueX(iv),mid,mid-min(r),max(r)-mid);
    set(eh,'linestyle','none')
    set(eh,'color',edgecolor(iv,:))
    
    patchX = [uniqueX(iv)-w*(bar_width/2) uniqueX(iv)-w*(bar_width/2) uniqueX(iv)+w*(bar_width/2) uniqueX(iv)+w*(bar_width/2)];
    % box 1: from m to hi.
    patchYhi = [mid hi hi mid];
    % box 2: from m to lo.
    patchYlo = [mid lo lo mid];
    
    patch(patchX,patchYhi,[1 1 1],'facecolor',facecolor(iv,:),'edgecolor',edgecolor(iv,:))
    patch(patchX,patchYlo,[1 1 1],'facecolor',facecolor(iv,:),'edgecolor',edgecolor(iv,:))
    plot(uniqueX(iv),m,'s','markerfacecolor','none','markeredgecolor',edgecolor(iv,:))
    
    if ~isempty(data) && plot_data_points
        bin = unique(Y);
        for b = 1 : length(bin)
            id = Y==bin(b);
            n = length(Y(id));
            xTemp = linspace(min(patchX),max(patchX),n+2);
            xTemp = xTemp(2:end-1);
            y = Y(id);
            y = sort(y);
            plot(xTemp,y,'o','markerfacecolor',edgecolor(iv,:),'markeredgecolor',edgecolor(iv,:),'markersize',6)
        end
    end
    
    hold off
end
set(gca,'xtick',uniqueX)
if nargout>0
    ph = get(gca,'children');
end
