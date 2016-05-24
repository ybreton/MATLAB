function [bh,eh,ch] = barerrorbar(x,y,l,u,varargin)
% plots bar graph with error bars.
% [bh,eh,ch] = barerrorbar(x,y,s)
% where         bh        is a handle to bar object.
%               eh        is a 1 x c vector of handles to errorbar objects.
%               ch        is a 1 x c vector of handles to the patch series.
%
%               x         is n x 1 vector of x values for bars, or empty
%                             for default 1:n.
%               y         is n x c matrix of y values for bars, where n is
%                             the number of x values and c is the number of
%                             bar series at each x value.
%               s         is n x c matrix of standard error values for
%                             bars.
%
% [bh,eh] = barerrorbar(x,y,l,u)
% where         l         is n x c matrix of lower excursions from y of
%                             error bar.
%               u         is n x c matrix of upper excursions from y of
%                             error bar.
%
% OPTIONAL ARGUMENTS:
% ******************
% width     (default 0.8)   
%                           normalized width of bars. 1 indicates no gap.
% style     (default 'grouped') 
%                           bar style, as allowed by bar() function.
% LineStyle (default 'none')
%                           errorbar line style.
% LineWidth (default 1)
%                           width of line objects.
%

width = 0.8;
style = 'grouped';
LineStyle = 'none';
LineWidth = 1;
process_varargin(varargin);
if nargin<4
    u = l;
end

if size(y,1)==1&&size(y,2)>1
    disp('y is 1 x n... fixing.')
    y = y(:);
    if size(l,1)==1&&size(l,2)>1
        disp('lower excursion is 1 x n... fixing.')
        l = l(:);
    end
    if size(u,1)==1&&size(u,2)>1
        disp('upper excursion is 1 x n... fixing.')
        u = u(:);
    end
end

if isempty(x)
    x = (1:size(y,1))';
end
dx = diff(x);
if length(x)==1
    dx = 1;
end

bh=bar(x,y,width,style);
set(bh,'LineWidth',LineWidth)

childs=get(bh,'children');
eh=nan(1,size(y,2));
ch=nan(1,size(y,2));
if ~iscell(childs)
    childs = {childs};
end
for c = 1 : length(childs)
    xData = get(childs{c},'xdata');
    xLoc = nanmean(xData,1);
    hold on
    eh(c) = errorbar(xLoc,y(:,c),l(:,c),u(:,c));
    hold off
    ch(c) = childs{c};
end
set(gca,'xtick',x)
set(gca,'xlim',[x(1)-dx(1)/2 x(end)+dx(end)/2])
set(eh,'linestyle',LineStyle)
set(eh,'linewidth',LineWidth)
set(eh,'color','k')