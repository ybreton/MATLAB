function h = xticklabelf(labels,varargin)
% Formatted y tick labels.
% h = xticklabelf(labels)
% where     h       is nTicks x 1 vector of handles to text objects
%
%           labels  is nTicks x 1 cell array of formatted strings (e.g.,
%                       sprintf) to use as tick labels
% inserts labels at existing xtick locations in current axes.
%
% h = xticklabelf(ah,labels)
% where     ah      is a handle to an axis
% inserts labels at existing xtick locations in axes ah.
%
% OPTIONAL ARGUMENTS:
% ******************
% ytick     (default: get(ah,'xtick'))
%           Specify x ticks to use.
% yaxislocation (default: get(ah,'xaxislocation'))
%           Specify whether xaxis is on bottom or top.
%

ah = gca;
if mod(length(varargin),2)==1
    ah = labels;
    labels = varargin{1};
    varargin = varargin(2:end);
end

xtick = get(ah,'xtick');
xaxislocation = get(ah,'xaxislocation');
process_varargin(varargin);

assert(strcmpi(xaxislocation,'bottom')|strcmpi(xaxislocation,'top'),'Valid strings for xaxislocation are ''bottom'' and ''top''.')
if length(xtick)>length(labels)
    warning('Extra yticks will be unlabeled.')
end
if length(labels)>length(xtick)
    warning([num2str(length(labels)-length(xtick)) ' extra labels will not be added to axes.'])
end

axes(ah)
H = ishold;

if strcmpi(xaxislocation,'bottom')
    yloc = min(get(ah,'ylim'));
    xticklocation = 'top';
end
if strcmpi(xaxislocation,'top')
    yloc = max(get(ah,'ylim'));
    xticklocation = 'bottom';
end
xlims = get(ah,'xlim');

hold on
set(ah,'xticklabel',[])
set(ah,'xtick',xtick)
h0=nan(length(labels),1);
nTicks = min(length(labels),length(xtick));
for iTick=1:nTicks
    h0(iTick)=text(xtick(iTick),yloc,labels{iTick},'VerticalAlignment',xticklocation,'HorizontalAlignment','center');
end
set(ah,'xlim',[min([xtick(:);xlims(1)]) max([xtick(:);xlims(2)])])
hold off

if H
    hold on;
end

if nargout>0
    h = h0;
end