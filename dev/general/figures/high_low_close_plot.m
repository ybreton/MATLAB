function handles = high_low_close_plot(x,hi,lo,cl,varargin)
% Produces a high-low-close plot.
% 
% DEFAULTS:
%
% highColor = 'none';
% lowColor = 'none';
% closeColor = 'k';
% addLegend = true;
% HighStr = 'High';
% LowStr = 'Low';
% ClStr = 'Close';
% IntervalStr = 'High to Low';
% alpha = 0.1;
%

color = [];
highColor = [0.8 0.8 0.8];
highLineStyle = 'none';
lowColor = [0.8 0.8 0.8];
lowLineStyle = 'none';
closeColor = 'k';
closeLineStyle = '-';
addLegend = true;
HighStr = 'High';
LowStr = 'Low';
ClStr = 'Close';
alpha = 0.1;
process_varargin(varargin);
if ~isempty(color)
    highColor = min(1,color+0.2);
    lowColor = min(1,color+0.2);
    closeColor = color;
end

[x,id] = sort(x);
hi = hi(id);
lo = lo(id);
cl = cl(id);

% for high and low, find the smallest nonzero difference in x
xdiff = diff(x);
xdiff = xdiff(xdiff>eps);
xwidth = min(xdiff/2);

patchX = [x(:)'-xwidth;
          x(:)';
          x(:)'+xwidth];
patchX = patchX(:);
patchX(1) = x(1);
patchX(end) = x(end);
patchYhi = interp1(x,hi,patchX);
patchYhi(1) = cl(1);
patchYhi(end) = cl(end);
patchYlo = interp1(x,lo,patchX);
patchYlo(1) = cl(1);
patchYlo(end) = cl(end);

hold on
lh = plot(x,cl,closeLineStyle,'color',closeColor);
hs(1) = lh;
legendStr{1} = sprintf('%s',ClStr);
ph=patch('xdata',patchX,'ydata',patchYlo,'facecolor',highColor,'edgecolor','none','facealpha',alpha);
hs(2) = ph(1);
legendStr{2} = sprintf('%s',LowStr);
ph(2)=patch('xdata',patchX,'ydata',patchYhi,'facecolor',highColor,'edgecolor','none','facealpha',alpha);
hs(3) = ph(2);
legendStr{3} = sprintf('%s',HighStr);
if ~strcmpi('none',highLineStyle)
    lh(length(lh)+1)=plot(x,hi,highLineStyle,'color',highColor);
    hs(length(hs)+1)=lh(end);
    legendStr{length(legendStr)+1} = sprintf('%s',HighStr);
end
if ~strcmpi('none',lowLineStyle)
    lh(length(lh)+1)=plot(x,hi,lowLineStyle,'color',lowColor);
    hs(length(hs)+1)=lh(end);
    legendStr{length(legendStr)+1} = sprintf('%s',LowStr);
end
[legendStr,idSort] = sort(legendStr);
hs = hs(idSort);

lastEntry = '';
for iL = 1 : length(legendStr)
    curEntry = legendStr{iL};
    if strcmp(curEntry,lastEntry)
        legendStr{iL} = ' ';
    end
    lastEntry = curEntry;
end

if addLegend
    lh=legend(hs,legendStr);
end
hold off

if nargout>0
    handles.axis = ah;
    handles.lines = h;
    handles.patches = ph;
    handles.legend = lh;
end