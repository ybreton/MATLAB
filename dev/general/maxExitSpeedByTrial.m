function sd = maxExitSpeedByTrial(sd,varargin)
% Returns maximum velocity from zone exit to next zone entry.
% sd = maxExitSpeedByTrial(sd)
% where     sd      is a standard session data structure
% 
% OPTIONAL ARGUMENTS:
% ******************
% px2cm     (default: @RRpx2cm)
%           either a scalar specifying the number of pixels per cm, or a
%           function handle that converts the two.
% offset    (default: 5)
%           the number of seconds after feeder fire to begin evaluating
%           absolute speed.
%

px2cm = @RRpx2cm;
offset = 5;
process_varargin(varargin);

sd = SmoothPath(sd);

nTrls = max(sum(~isnan(sd.EnteringZoneTime)),sum(~isnan(sd.ExitZoneTime)));
t1 = nan(nTrls,1);
t2 = nan(nTrls,1);
t1(sd.stayGo==1) = sd.FeederTimes+offset+sd.x.dt;
t2(sd.stayGo==1) = sd.NextZoneTime(sd.stayGo==1)-sd.x.dt;

t1(1)=nan;
t2(1)=nan;
t1(end)=nan;
t2(end)=nan;

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
V1= min(data(V.restrict(t1,t2)));
V2= max(data(V.restrict(t1,t2)));
clf

subplot(1,2,1);
hold on
plot(x.data,y.data,'.','color',[0.8 0.8 0.8]);
x0 = x.restrict(t1(~isnan(t1)),t2(~isnan(t2))-V.dt);
y0 = y.restrict(t1(~isnan(t1)),t2(~isnan(t2))-V.dt);
t0 = range(V.restrict(t1(~isnan(t1)),t2(~isnan(t2))-V.dt));
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

Vmax = nan(length(t1),1);
disp(['Obtaining top exit speed on ' num2str(length(t1)) ' trials.'])
for iTrl=find(~isnan(t1))';
    v0 = data(V.restrict(t1(iTrl),t2(iTrl)-V.dt));

    if ~isempty(v0)
        Vmax(iTrl) = max(v0);
    end
end

if any(Vmax>60)
    disp('>60cm/sec speed (>2.16km/h).')
end

sd.VoutMax = Vmax;
subplot(1,2,2);
hold on
[h,bin]=hist(Vmax,ceil(sqrt(sum(~isnan(Vmax)))));
bar(bin,h/sum(h),1);
plot([nanmean(Vmax) nanmean(Vmax)],[0 max(h/sum(h))],'r-','linewidth',3)
plot([nanmedian(Vmax) nanmedian(Vmax)],[0 max(h/sum(h))],'b:','linewidth',3)
p=[normcdf(bin(1),nanmean(Vmax),nanstd(Vmax)) normcdf(bin(2:end),nanmean(Vmax),nanstd(Vmax))-normcdf(bin(1:end-1),nanmean(Vmax),nanstd(Vmax))];
plot(bin,p,'k-','linewidth',3)
xlabel(sprintf('V_{max}'));
title(sprintf('%s\n\\mu=%.1f\nM=%.1f',sd.ExpKeys.SSN,nanmean(Vmax),nanmedian(Vmax)))
xlim([min(bin)-median(diff(bin))/2 max(bin)+median(diff(bin))/2])
hold off
drawnow