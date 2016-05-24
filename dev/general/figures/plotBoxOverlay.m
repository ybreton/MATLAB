function oh = plotBoxOverlay(y,varargin)
% Adds an overlay of data points to plot boxes.
% oh = plotBoxOverlay(y)
% 
% where     oh         is a vector of object handles created
% 
%               y           is a nPoints x nGroups matrix of points to overlay on the figure.
% 
% places an overlay of points on the figure, where the data from column j of the matrix is placed at x=j on the graph.
% 
% oh = plotBoxOverlay(y,'x',x)
% 
% where         y            is a nPoints x 1 vector of points to overlay
%               x            is a nPoints x 1 vector of x-axis coordinates for those points,
% or
%               y            is a nPoints x nGroups matrix of points to overlay
%               x            is a nPoints x nGroups matrix of x-axis coordinates for those points,
% 
% places an overlay of points on the figure, where the data for y(i,j) are placed at x(i,j) on the graph.
% 
% Points at each x coordinate are arrayed along the y-axis at their y locations. To ensure that points do not overlap, points are grouped into nBins (nBins default 11) bins, and spread out at x +/- width/2 (width default 0.25).
% 
% optional arguments:
%             x             (default is column)        center of x-axis locations for data points in y. Default is to use column number in y.
% groups below are defined as unique values of x.
% 
%             nBins      (default: 11)                  number of bins to use for ensuring points with close or identical y values do not overlap.
%             binEdges   (default empty)               edges of bins to use
%             width       (default: 0.25)              largest x-axis spread to use for most populous bin.
%             symbol    (default: 'd')                 cell array of marker symbols to use for plotting points. Each cell corresponds to each group.
%             markersize    (default: 5)            vector of sizes of marker to use. Each element corresponds to each x-axis location.
%             color            (default: 'k')            nGroups cell array of marker colors (for strings) or nGroups x 3 matrix of RGB color triplets. Each element (cell array) or row (matrix) corresponds to each group.
%
% REVISED: 2014-10-27   YAB
%       If a column is entirely nan, ignore it. Puts up a warning when such
%       an event occurs: "Group at x=column is entirely nan."
%       If using with a vector of x's, warning message will indicate which
%       x values contain only nan values of y.
%

if size(y,2)>1 && size(y,1)==1
    % row vector.
    y = y(:);
end
nGrps = size(y,2);

x = repmat(1:nGrps,size(y,1),1);
nBins = 11;
width = 0.25;
symbol = cell(nGrps,1);
markersize = nan(nGrps,1);
color = cell(nGrps,1);
for iGrp=1:nGrps
    symbol{iGrp} = 'd';
    markersize(iGrp) = 5;
    color{iGrp} = 'k';
end
binEdges = [];
process_varargin(varargin);
if ischar(symbol)
    symbol = {symbol};
end

H = ishold;

uniqueX = unique(x(:));
if length(uniqueX)>1 && min(size(x,1),size(x,2))==1
    x = x(:);
    y0 = nan(length(y),length(uniqueX));
    x0 = nan(length(y),length(uniqueX));
    for iX=1:length(uniqueX)
        idX = x==uniqueX(iX);
        yTemp = y(idX);
        y0(1:length(yTemp),iX) = yTemp;
        x0(1:length(yTemp),iX) = uniqueX(iX);
    end
    y = y0;
    x = x0;
end
idnan = all(isnan(y),2);
y(idnan,:) = [];
x(idnan,:) = [];
nGrps = size(y,2);

if isnumeric(color)
    if size(color,1)==3 && size(color,2)~=3
        color = color';
    end
else
    color = color(:);
end
if size(color,1)==1 && nGrps>1
    color = repmat(color,nGrps,1);
end
nColors = size(color,1);
if length(symbol)==1 && nGrps>1
    symbol = repmat(symbol,nGrps,1);
end
if length(markersize)==1 && nGrps>1
    markersize = repmat(markersize,nGrps,1);
end

assert(nColors == nGrps,'colors must either have as many RGB values or strings as groups, or a single RGB value or string.')
assert(length(symbol) == nGrps,'symbol must either have as many strings as groups, or a single string.')
assert(length(markersize) == nGrps,'markersize must either have as many values as groups, or a single value.')

oh = nan(1,nGrps);
for iGrp=1:nGrps
    if any(~isnan(y(:,iGrp)))
        if isempty(binEdges)
            [f,binc] = hist(y(:,iGrp),nBins);
            binw = mean(diff(binc));
            binLo = binc-binw/2;
            binHi = binc+binw/2;
        else
			binEdges = sort(binEdges(:));
			binCenters = binEdges(1:end-1)+diff(binEdges);
            [f,binc] = hist(y(:,iGrp),binCenters);
			% lo = binEdges(1) - (binEdges(2)-binEdges(1))/2;
			% hi = binEdges(end) + (binEdges(end)-binEdges(end-1))/2;
			% flo = nansum(y(:,iGrp)<binEdges(1));
			% fhi = nansum(y(:,iGrp)>binEdges(end));
			% f = [flo f fhi];
			% binc = [lo binc hi];
			
            binw = diff(binc);
            binw = [binw(1) binw];
            binLo = binc-binw/2;
            binHi = binc+binw/2;
        end

        idEmptyBin = f==0;
        f = f(~idEmptyBin);
        binc = binc(~idEmptyBin);
        binLo = binLo(~idEmptyBin);
        binHi = binHi(~idEmptyBin);

        spread = (f-1)/max((f-1))*width/2;
        spread(isnan(spread)) = 0;
        x0 = [];
        y0 = [];

        % First bin
        idBin = y(:,iGrp)<=binHi(1);
        yBin = y(idBin,iGrp);
        xBinC = x(idBin,iGrp);
        xBin = xBinC+linspace(-spread(1),spread(1),length(yBin))';

        if binHi(1)<nanmedian(y(:,iGrp))
            % below the median, plot upward-pointing.
            yBin = sort(yBin(:),'descend');
            % yBin(1) is high; assign it to the extremes.
            xBin0 = [xBin';
                     xBin(end:-1:1)'];
            xBin0 = xBin0(:);
            x0 = [x0; xBin0(1:length(yBin))];
            y0 = [y0; yBin];
        end

        if binLo(1)>nanmedian(y(:,iGrp))
            % above the median, plot downward-pointing.
            yBin = sort(yBin(:),'ascend');
            % yBin(1) is low; assign it to the extremes.
            xBin0 = [xBin';
                     xBin(end:-1:1)'];
            xBin0 = xBin0(:);
            x0 = [x0; xBin0(1:length(yBin))];
            y0 = [y0; yBin];
        end

        if binLo(1)<=nanmedian(y(:,iGrp)) && binHi(1)>=nanmedian(y(:,iGrp));
            % at median, plot alternating.
            yBin0 = [yBin';
                     yBin(end:-1:1)'];
            yBin0 = yBin0(:);
            y0 = [y0; yBin0(1:length(yBin))];
            x0 = [x0; xBin(:)];
        end

        % Middle bins
        for iBin=2:length(binc)-1
            idBin = y(:,iGrp)>binLo(iBin)&y(:,iGrp)<=binHi(iBin);
            yBin = y(idBin,iGrp);
            xBinC = x(idBin,iGrp);
            xBin = xBinC+linspace(-spread(iBin),spread(iBin),length(yBin))';

            if binHi(iBin)<nanmedian(y(:,iGrp))
                % below the median, plot upward-pointing.
                yBin = sort(yBin(:),'descend');
                % yBin(1) is high; assign it to the extremes.
                xBin0 = [xBin';
                         xBin(end:-1:1)'];
                xBin0 = xBin0(:);
                x0 = [x0; xBin0(1:length(yBin))];
                y0 = [y0; yBin];
            end

            if binLo(iBin)>nanmedian(y(:,iGrp))
                % above the median, plot downward-pointing.
                yBin = sort(yBin(:),'ascend');
                % yBin(1) is low; assign it to the extremes.
                xBin0 = [xBin';
                         xBin(end:-1:1)'];
                xBin0 = xBin0(:);
                x0 = [x0; xBin0(1:length(yBin))];
                y0 = [y0; yBin];
            end

            if binLo(iBin)<=nanmedian(y(:,iGrp)) && binHi(iBin)>=nanmedian(y(:,iGrp));
                % at median, plot alternating.
                yBin0 = [yBin';
                         yBin(end:-1:1)'];
                yBin0 = yBin0(:);
                y0 = [y0; yBin0(1:length(yBin))];
                x0 = [x0; xBin(:)];
            end
        end

        % Last bin.
        idBin = y(:,iGrp)>=binLo(end);
        yBin = y(idBin,iGrp);
        xBinC = x(idBin,iGrp);
        xBin = xBinC+linspace(-spread(end),spread(end),length(yBin))';

        if binHi(end)<nanmedian(y(:,iGrp))
            % below the median, plot upward-pointing.
            yBin = sort(yBin(:),'descend');
            % yBin(1) is high; assign it to the extremes.
            xBin0 = [xBin';
                     xBin(end:-1:1)'];
            xBin0 = xBin0(:);
            x0 = [x0; xBin0(1:length(yBin))];
            y0 = [y0; yBin];
        end

        if binLo(end)>nanmedian(y(:,iGrp))
            % above the median, plot downward-pointing.
            yBin = sort(yBin(:),'ascend');
            % yBin(1) is low; assign it to the extremes.
            xBin0 = [xBin';
                     xBin(end:-1:1)'];
            xBin0 = xBin0(:);
            x0 = [x0; xBin0(1:length(yBin))];
            y0 = [y0; yBin];
        end

        if binLo(end)<=nanmedian(y(:,iGrp)) && binHi(end)>=nanmedian(y(:,iGrp));
            % at median, plot alternating.
            yBin0 = [yBin';
                     yBin(end:-1:1)'];
            yBin0 = yBin0(:);
            y0 = [y0; yBin0(1:length(yBin))];
            x0 = [x0; xBin(:)];
        end

        hold on
        if iscell(color)
            oh(iGrp) = plot(x0,y0,symbol{iGrp},'color',color{iGrp},'markerfacecolor',color{iGrp},'markersize',markersize(iGrp));
        else
            oh(iGrp) = plot(x0,y0,symbol{iGrp},'color',color(iGrp,:),'markerfacecolor',color(iGrp,:),'markersize',markersize(iGrp));
        end
        hold off
    else
        warning('Group at x=%d is entirely nan.',nanmedian(x(:,iGrp)))
    end
end

if H; hold on; else hold off; end