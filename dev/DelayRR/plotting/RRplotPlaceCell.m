function RRplotPlaceCell(sd,tt,varargin)
%
%
%
%
interpolate = true;
process_varargin(varargin);

if ischar(tt)
    tt = {tt};
end
if isnumeric(tt)
    disp('Numeric tt list.')
    tt0 = tt;
    tt = cell(numel(tt0),1);
    for iTT = 1 : numel(tt0)
        if tt0(iTT)<10
            disp(['Renaming ' num2str(tt0(iTT)) ' to 0' num2str(tt0(iTT)) '.'])
            tt{iTT} = ['0' num2str(tt0(iTT))];
        else
            tt{iTT} = num2str(tt0(iTT));
        end
    end
end
tt = tt(:);

idInc=false(length(sd.fn),length(tt));
for iF=1:length(sd.fn)
    fn = sd.fn{iF};
    
    for iTT = 1 : length(tt)
        idInc(iF,iTT) = ~isempty(regexpi(fn,['TT' tt{iTT}]));
    end
end
idInc = any(idInc,2);

fn = sd.fn(idInc');
Stt = sd.S(idInc);
SSN = sd.ExpKeys.SSN;
X = sd.x;
Y = sd.y;
T = X.range;
idnan = isnan(X.data)|isnan(Y.data);
T0 = T(~idnan);

cmap = jet(length(Stt)+2);
cmap = cmap(2:end-1,:);

clf
plot3(X.data,Y.data,T,'-','color',[0.8 0.8 0.8],'linewidth',0.25)
drawnow
hold on
view(90,90);
ph = nan(length(Stt),1);
disp([num2str(length(Stt)) ' cells.'])
for iC = 1 : length(Stt)
    disp([num2str(iC) ': ' fn{iC}]);
    S = Stt{iC};
    Stimes = S.range;
    x = nan(length(Stimes),1);
    y = nan(length(Stimes),1);
    t = nan(length(Stimes),1);
    for iT = 1 : length(Stimes)
        dev = abs(Stimes(iT)-T0);
        
        [~,id] = min(dev);
        
        t0 = mean(T0(id));
        x0 = X.restrict(t0,t0);
        y0 = Y.restrict(t0,t0);
        x(iT) = x0.data;
        y(iT) = y0.data;
        t(iT) = t0;
    end
    ph(iC)=plot3(x,y,t,'.','markerfacecolor',cmap(iC,:),'markeredgecolor',cmap(iC,:),'markersize',10);
    drawnow
end
title(sprintf('%s\nPlace spiking',SSN));
lh=legend(ph,fn);
set(lh,'location','eastoutside');
set(gca,'xlim',[0 720])
set(gca,'ylim',[0 480])
set(gca,'zlim',[sd.ExpKeys.TimeOnTrack-sd.x.dt sd.ExpKeys.TimeOffTrack+sd.x.dt])
set(gca,'xcolor','w')
set(gca,'ycolor','w')
set(gca,'xtick',[])
set(gca,'ytick',[])
hold off