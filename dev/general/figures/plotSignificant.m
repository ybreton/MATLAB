function th = plotSignificant(c,varargin)
% Uses data in c (produced by multcompare) to plot asterisks where groups
% are significantly different.
% th = plotSignificant(c)
% where         th          is 2 x nSig matrix of handles to text objects.
%
%               c           is a matrix produced by multcompare with rows
%                           Group1  Group2  LowerCI     Estimate    UpperCI
% OPTIONAL ARGUMENTS:
% ******************
% tails         (default: 2)
%                           is the number and sign of tails to test.
%                           Acceptable values are 2 (not directional), -1
%                           (estimate must be <0) and 1 (estimate must be
%                           >0).
% x1            (default: row 1 of c)
%                           x position of first group in comparison for
%                           plotting.
% x2            (default: row 2 of c)
%                           x position of second group in comparison for
%                           plotting.
% cmap          (default: @jet)
%                           function handle to color-mapping function, or
%                           n x 3 matrix of RGB values.
% symbol        (default: '*')
%                           character string to indicate significant
%                           difference.
% top           (default: top of axes)
%                           top of plot to begin inserting significance
%                           findings.
% fontsize      (default: 18)
%                           size of symbol to indicate significant
%                           difference, in points.
% fontweight    (default: 'bold')
%                           weight of symbol for indicating significance.
%

tails = 2;
x1 = c(:,1);
x2 = c(:,2);
cmap = @jet;
symbol = '*';
top = max(get(gca,'ylim'));
fontsize = 18;
fontweight = 'bold';
process_varargin(varargin);

assert(tails==2||tails==-1||tails==1,'Acceptable values of tails are -1, 1, and 2.');
assert(ischar(symbol),'Symbol for marking significance must be a character string.');
assert(isa(cmap,'function_handle')||isnumeric(cmap),'Colormap cmap must be a function handle to a color-mapping function (e.g., hsv) or a matrix of RGB values.');
if isnumeric(cmap)
    assert(size(cmap,2)==3,'Numeric colormap in cmap must be n x 3.')
end

k=0;
lo = c(:,3);
m = c(:,4);
hi = c(:,5);

idTail = true(size(c,1),1);
if tails==-1
    idTail = m<0;
end
if tails==1
    idTail = m>0;
end

sig = sign(lo)==sign(hi) & idTail;

c = c(sig,:);
x1 = x1(sig);
x2 = x2(sig);

if ~isa(cmap,'function_handle')
    cmap = repmat(cmap,[size(c,1) 1]);
    cmap = cmap(1:size(c,1),:);
else
    cmap = cmap(size(c,1)+2);
    cmap = cmap(2:end-1,:);
end

th = nan(2,size(x1,1));
hold on
for iC=1:size(x1,1)
    str='';
    for iK=1:iC-1
        str = [str sprintf('\n')];
    end
    str = [str symbol];
    
    c1 = x1(iC);
    c2 = x2(iC);
    
    th(1,iC)=text(c1,top,str,'verticalalignment','top','horizontalalignment','center','fontsize',fontsize,'fontweight',fontweight);
    th(2,iC)=text(c2,top,str,'verticalalignment','top','horizontalalignment','center','fontsize',fontsize,'fontweight',fontweight);
    set(th(:,iC),'color',cmap(iC,:))
end
hold off