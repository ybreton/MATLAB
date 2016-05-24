function H = RRcellFiring(sd,tt,varargin)
%
%
%
%

xBins = 48;
yBins = 32;
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

SSN = sd.ExpKeys.SSN;

idInc=false(length(sd.fn),length(tt));
for iF=1:length(sd.fn)
    fn = sd.fn{iF};
    
    for iTT = 1 : length(tt)
        idInc(iF,iTT) = ~isempty(regexpi(fn,['TT' tt{iTT}]));
    end
end
nClus = sum(double(idInc));

xScale = linspace(0,720,xBins);
yScale = linspace(0,480,yBins);

X = sd.x;
Y = sd.y;
T = X.range;
x0 = X.data;
y0 = Y.data;
dt = mean([X.dt Y.dt]);
idnan = isnan(x0)|isnan(y0);
T0 = T(~idnan);
X0 = x0(~idnan);
Y0 = y0(~idnan);

H = nan(yBins,xBins,length(tt),max(nClus));
clf;
set(gcf,'Name',SSN)
for iTT = 1 : size(idInc,2)
    disp(['TT' tt{iTT}]);
    fn = sd.fn(idInc(:,iTT));
    Stt = sd.S(idInc(:,iTT));
    SSN = sd.ExpKeys.SSN;
    nSpikes = nan(length(Stt),1);
    for iS = 1 : length(Stt)
        S = Stt{iS};
        nSpikes(iS) = length(S.range);
    end
    
    for iS = 1 : length(Stt)
        disp(['Clu ' num2str(iS) '...'])
        S = Stt{iS};
        Stimes = S.range;
        Mx = nan(length(Stimes),1);
        My = nan(length(Stimes),1);
        for iT = 1 : length(Stimes)
            dev = abs(Stimes(iT)-T0);
            [~,id] = min(dev);
            id = round(mean(id));
            Mx(iT) = X0(id);
            My(iT) = Y0(id);
        end
        
        h = histcn([Mx My],xScale,yScale);
        hNorm = h./sum(h(:));
        H(:,:,iTT,iS) = h';
        
        p = (iTT-1)*length(Stt)+iS;
        subplot(length(tt),length(Stt),p)
        imagesc(xScale,yScale,hNorm');
        axis equal
        set(gca,'xlim',[0 720])
        set(gca,'ylim',[0 480])
        set(gca,'box','off')
        set(gca,'xcolor','w')
        set(gca,'ycolor','w')
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        title([SSN '-TT' tt{iTT} '-' num2str(iS)])
        drawnow
    end
end