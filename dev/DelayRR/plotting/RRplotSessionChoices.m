function fh = RRplotSessionChoices(sd,pellets,varargin)
% Plots binary stay/go data (jittered by 1%) for a range of sessions and
% number of pellets.
% fh = RRplotSessionChoices(sess,pellets)
% where     fh          is a list of figure handles produced
%
%           sd          is a nSubsess x 1 sd structure array,
%           pellets     is the number of food pellets delivered per zone.
%
% OPTIONAL ARGUMENTS:
% ******************
% flavours     (default {'Cherry' 'Banana' 'Plain White' 'Chocolate'})
%                               cell array of flavour names for each zone.
% jitterFactor (default 1/100)  standard deviation of random jitter to add
%                                   to binary stay/go data.
% fh           (default next 4) vector of handles to figures produced.
%
flavours = {'Cherry' 'Banana' 'Plain White' 'Chocolate'};
jitterFactor = 1/100;
curFigs = get(0,'children');
if isempty(curFigs)
    fh = 1:4;
else
    fh = max(curFigs)+1:4;
end
process_varargin(varargin);

cmap = RRColorMap;
cmap(3,:) = [0 0 0]; % black for plain white pellets.

SSN = cell(numel(sd),1);
for s = 1 : length(sd)
    SSN{s} = sd(s).ExpKeys.SSN;
end
SSN = unique(SSN);
SSN = {SSN{1} SSN{end}};

x = RRGetDelays(sd); 
z = RRGetZones(sd); 
y = RRGetStaygo(sd);
n = RRGetPellets(sd);
x = x(:);
y = y(:);
z = z(:);
n = n(:);
thresholds = RRThresholds(sd);

idnan = isnan(x)|isnan(z)|isnan(y)|isnan(n);
x = x(~idnan);
predX = unique(x);
y = y(~idnan);
z = z(~idnan);
n = n(~idnan);

for iZ = 1 : 4; 
    idZ = z==iZ; 
    idN = n==pellets;
    th = thresholds(iZ,pellets);
    predY = double(predX<th);
    predY(unique(x)==th) = 0.5;
    figure(fh(iZ)); 
    set(gca,'fontsize',18)
    set(gca,'fontname','Arial')
    hold on; 
    plot(x(idZ&idN),y(idZ&idN)+randn(length(x(idZ&idN)),1)*jitterFactor,'.','markeredgecolor',cmap(iZ,:)); 
    plot(predX,predY,'-','color',cmap(iZ,:)); 
    set(gca,'ylim',[-0.05 1.05]); 
    set(gca,'ytick',[0 1]); 
    set(gca,'xlim',[0 30])
    set(gca,'xtick',[0:5:30])
    set(gca,'box','off')
    xlabel(sprintf('Delay (secs)'))
    set(gca,'yticklabel',{'Skip' 'Stay'})
    if strcmp(SSN{1},SSN{2})
        title(sprintf('%s\n%s',flavours{iZ},SSN{1}))
    else
        title(sprintf('%s\n%s -- %s',flavours{iZ},SSN{1},SSN{2}))
    end
    drawnow;
end;

