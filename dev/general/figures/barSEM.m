function [bh,eh] = barSEM(m,s,varargin)
% Plots a bar graph with error bars.
% [bh,eh] = barSEM(m,s)
% where     bh      is a handle to bar objects
%           eh      is a handle to error objects
%           
%           m       is an X x nBar matrix of means,
%           s       is an X x nBar matrix of standard errors, or
%                      an X x nBar x 2 matrix with lower (:,:,1) and upper (:,:,2) bounds.
%
% OPTIONAL ARGUMENTS:
% ******************
% xticklabel    (default 1:X)       labels for x ticks.
% barwidth      (default 0.8)       width of bars.
% x             (default 1:X)       X values for bars.
% facecolor     (default lines)     nBar x 3 RGB triple for bar face color.
% edgecolor     (default black)     nBar x 3 RGB triple for bar edge color.
% facealpha     (default 1)         nBar x 1 alpha value of bar faces.
% edgealpha     (default 1)         nBar x 1 alpha value of bar edges.
% color         (default black)     nBar x 3 RGB triple for errorbar color.
% linewidth     (default 1)         nBar x 1 width of errorbar lines.
% ah            (default gca)       axis handle to place plot.
% fh            (default gcf)       figure handle to place plot.
%
% Notes:
% m and s must have the same number of rows and columns.
% If s is omitted, produces the same output as bar(m,0.8).
% If m is nBar x 1, will produce appropriate single-series bar graph.
% If facecolor, edgecolor, or color are 1 x 3, all bars will be colored
% identically with that color.
% If facealpha, edgealpha, or linewidth are 1 x 1, all bars will have
% specified transparency or line width.
%

if nargin<2
    s = zeros(size(m));
end

assert((size(m,1)==size(s,1))&&size(m,2)==size(s,2),'Means and standard errors must have same number of rows and columns');

if size(m,1)>1
    x = 1:size(m,1);
else
    m = m';
    s = s';
    x = 1:size(m,1);
end
if size(s,3)>1
    L = m-squeeze(s(:,:,1));
    U = squeeze(s(:,:,2))-m;
else
    L = s;
    U = s;
end
cmap = lines(size(m,2));
xticklabel = mat2can(x);
barwidth = 0.8;
facecolor = cmap;
edgecolor = zeros(size(m,2),3);
facealpha = ones(1,size(m,2));
edgealpha = ones(1,size(m,2));
color = zeros(size(m,2),3);
linewidth = ones(1,size(m,2));
fh = gcf;
ah = gca;
process_varargin(varargin);
figure(fh);
axes(ah);

nBar = size(m,2);
if length(facealpha)<nBar
    nrep = ceil(nBar/length(facealpha));
    facealpha = repmat(facealpha(:)',1,nrep);
    facealpha = facealpha(1:nBar);
end
if length(edgealpha)<nBar
    nrep = ceil(nBar/length(edgealpha));
    edgealpha = repmat(edgealpha(:)',1,nrep);
    edgealpha = edgealpha(1:nBar);
end
if length(linewidth)<nBar
    nrep = ceil(nBar/length(linewidth));
    linewidth = repmat(linewidth(:)',1,nrep);
    linewidth = linewidth(1:nBar);
end
if size(facecolor,1)<nBar
    nrep = ceil(nBar/size(facecolor,1));
    facecolor = repmat(facecolor,nrep,1);
    facecolor = facecolor(1:nBar);
end
if size(edgecolor,1)<nBar
    nrep = ceil(nBar/size(edgecolor,1));
    edgecolor = repmat(edgecolor,nrep,1);
    edgecolor = edgecolor(1:nBar);
end
if size(color,1)<nBar
    nrep = ceil(nBar/size(color,1));
    color = repmat(color,nrep,1);
    color = color(1:nBar);
end

h=bar(x,m,barwidth);
bh = nan(1,nBar);
eh = nan(1,nBar);
hold on
for g = 1 : nBar
    bh(g) = get(h(g),'children');
    set(bh(g),'facecolor',facecolor(g,:))
    set(bh(g),'edgecolor',edgecolor(g,:))
    set(bh(g),'facealpha',facealpha(g))
    set(bh(g),'edgealpha',edgealpha(g))
    xpos = nanmean(get(bh(g),'xdata'));
    eh(g) = errorbar(xpos,m(:,g),L(:,g),U(:,g));
    set(eh(g),'linestyle','none')
    set(eh(g),'color',color(g,:))
    set(eh(g),'linewidth',linewidth(g))
end
hold off
set(ah,'xtick',x)
set(ah,'xticklabel',xticklabel)