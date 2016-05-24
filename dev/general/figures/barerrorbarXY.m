function [xBar,yBar] = barerrorbarXY(ch)
% Returns center x location of each bar in bar series specified in ch,
%        maximum y location of each bar in bar series specified in ch.
%
% [xBar,yBar] = barerrorbarXY(ch)
% where     xBar        is  nBars x nSeries matrix of x locations,
%           yBar        is  nBars x nSeries matrix of y bar heights.
%
%           ch          is  nSeries x 1 vector of handles to patch objects
%                           in bar graph.
%
%
nSeries = length(ch);
nBars = nan(nSeries,1);
for iBar = 1 : nSeries
    nBars(iBar) = size(get(ch(iBar),'xdata'),2);
end
xBar = nan(max(nBars),nSeries);
yBar = nan(max(nBars),nSeries);
for iBar = 1 : nSeries
    xBar(1:nBars(iBar),iBar) = nanmean(get(ch(iBar),'xdata'))';
    yBar(1:nBars(iBar),iBar) = max(get(ch(iBar),'ydata'))';
end