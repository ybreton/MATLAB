function RRPlotPaths(x,y,tIn,tOut,varargin)
%
%
%
%

Xsz = size(x);
Ysz = size(y);
TINsz = size(tIn);
TOUTsz = size(tOut);
assert(all(Xsz==Ysz),'x and y dimensions must match.');
assert(all(TINsz(1:2)==TOUTsz(1:2)),'temporal dimensions must match.');
assert(all(Ysz(1:2)==TINsz(1:2)),'Rows and columns in x,y must match rows and columns in tIn,tOut.');

if ~iscell(x)&&~iscell(y)
    x = {x};
    y = {y};
end

for r = 1 : size(x,1);
    for c = 1 : size(x,2)
        InZone = tIn(r,c,:);
        OutZone = tOut(r,c,:);
        
        nl = min(length(InZone),length(OutZone));
        InZone = InZone(1:nl);
        OutZone = OutZone(1:nl);
        
        idnan = isnan(InZone)|isnan(OutZone);
        InZone = InZone(~idnan);
        OutZone = OutZone(~idnan);
        
        xSSN = x{r,c};
        ySSN = y{r,c};
        dt = nanmean([xSSN.dt ySSN.dt]);
        
        cmap = jet(length(InZone));
        clf
        hold on
        for trial = 1 : length(InZone)
            x0 = xSSN.restrict(InZone(trial)-dt,OutZone(trial)+dt);
            y0 = ySSN.restrict(InZone(trial)-dt,OutZone(trial)+dt);
            plot3(x0.data,y0.data,x0.range,'-','linewidth',1,'color',cmap(trial,:));
            drawnow
        end
        view(2);
        hold off
        if ((r-1)*c+r)<numel(x)
            disp('Enter to view next session in x,y list.')
            pause;
        end
    end
end