function h = yticklabelf(labels,varargin)
% Formatted y tick labels.
% h = yticklabelf(labels)
% where     h       is nTicks x 1 vector of handles to text objects
%
%           labels  is nTicks x 1 cell array of formatted strings (e.g.,
%                       sprintf) to use as tick labels
% inserts labels at existing ytick locations in current axes.
%
% h = yticklabelf(ah,labels)
% where     ah      is a handle to an axis
% inserts labels at existing ytick locations in axes ah.
%
% OPTIONAL ARGUMENTS:
% ******************
% ytick     (default: get(ah,'ytick'))
%           Specify y ticks to use.
% yaxislocation (default: get(ah,'yaxislocation'))
%           Specify whether yaxis is on right or left side.
%

ah = gca;
if mod(length(varargin),2)==1
    ah = labels;
    labels = varargin{1};
    varargin = varargin(2:end);
end

ytick = get(ah,'ytick');
yaxislocation = get(ah,'yaxislocation');
process_varargin(varargin);

assert(strcmpi(yaxislocation,'right')|strcmpi(yaxislocation,'left'),'Valid strings for yaxislocation are ''right'' and ''left''.')
if length(ytick)>length(labels)
    warning('Extra yticks will be unlabeled.')
end
if length(labels)>length(ytick)
    warning([num2str(length(labels)-length(ytick)) ' extra labels will not be added to axes.'])
end

axes(ah)
H = ishold;

if strcmpi(yaxislocation,'left')
    xloc = min(get(ah,'xlim'));
    yticklocation = 'right';
end
if strcmpi(yaxislocation,'right')
    xloc = max(get(ah,'xlim'));
    yticklocation = 'left';
end
ylims = get(ah,'ylim');

hold on
set(ah,'yticklabel',[])
set(ah,'ytick',ytick)
h0=nan(length(labels),1);
nTicks = min(length(labels),length(ytick));
for iTick=1:nTicks
    h0(iTick)=text(xloc,ytick(iTick),labels{iTick},'VerticalAlignment','middle','HorizontalAlignment',yticklocation);
end
set(ah,'ylim',[min([ytick(:);ylims(1)]) max([ytick(:);ylims(2)])])
hold off

if H
    hold on;
end

if nargout>0
    h = h0;
end