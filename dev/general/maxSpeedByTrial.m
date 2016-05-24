function sd = maxSpeedByTrial(sd,varargin)
% Returns maximum velocity from zone entry to next zone entry.
%
%
%

px2cm = @RRpx2cm;
tin = [nan sd.EnteringZoneTime(2:end-1) nan];
tout = [nan sd.EnteringZoneTime(3:end) nan];
process_varargin(varargin);

sd = SmoothPath(sd);

if isa(px2cm,'function_handle')
    x = tsd(sd.x.range,px2cm(sd,sd.x.data));
    y = tsd(sd.y.range,px2cm(sd,sd.y.data));
else
    if numel(px2cm)==1
        x = tsd(sd.x.range,sd.x.data*px2cm);
        y = tsd(sd.y.range,sd.y.data*px2cm);
    else
        warning('px2cm must be either a function handle or a scalar specifying the pixel-to-centimeter conversion factor. Using a conversion factor of 1.');
        x = sd.x;
        y = sd.y;
    end
end
disp('Computing derivatives...')
dx = dxdt(x);
dy = dxdt(y);

disp('Computing absolute speed...')
V = tsd(dx.range,sqrt(dx.data.^2+dy.data.^2));
V1= min(data(V.restrict(tin,tout)));
V2= max(data(V.restrict(tin,tout)));
clf

subplot(1,2,1);
hold on
plot(x.data,y.data,'.','color',[0.8 0.8 0.8]);
x0 = x.restrict(tin,tout-V.dt);
y0 = y.restrict(tin,tout-V.dt);
t0 = range(V.restrict(tin,tout-V.dt));
scatterplotc(x0.data(t0),y0.data(t0),V.data(t0),'solid_face',true,'plotchar','.','crange',[V1 V2]);
drawnow
caxis([V1 V2])
colorbar;
axis image
set(gca,'xcolor','w')
set(gca,'ycolor','w')
set(gca,'xtick',[])
set(gca,'ytick',[])
hold off

Vmax = nan(length(tin),1);
disp(['Obtaining top speed on ' num2str(length(tin)) ' trials.'])
for iTrl=1:length(tin);
    v0 = data(V.restrict(tin(iTrl),tout(iTrl)-V.dt));
    
    if ~isempty(v0)
        Vmax(iTrl) = max(v0);
    end
end


sd.Vmax = Vmax;
subplot(1,2,2);
hold on
[h,bin]=hist(Vmax,ceil(sqrt(sum(~isnan(Vmax)))));
bar(bin,h/sum(h),1);
xlabel(sprintf('V_{max} (cm/sec)'));
xlim([15 60])
plot([nanmedian(Vmax) nanmedian(Vmax)],ylim,'r-','linewidth',2)
plot([nanmean(Vmax) nanmean(Vmax)],ylim,'g:','linewidth',2)
hold off
title(sprintf('%s\n(r) M=%.1f\n(g) \\mu=%.1f',sd.ExpKeys.SSN,nanmedian(Vmax),nanmean(Vmax)));
drawnow
