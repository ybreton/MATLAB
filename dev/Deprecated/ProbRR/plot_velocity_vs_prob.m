function [vel,fh] = plot_velocity_vs_prob(varargin)
%
%
%
%

fn = FindFiles('*.nvt');
RR = FindFiles('RR-*.mat');
window = 2;
process_varargin(varargin);

if iscell(RR)
    RR = RR{1};
end
if iscell(fn)
    fn = fn{1};
end

load(RR);

[pathname,filename,ext] = fileparts(fn);
zipped = false;
if strcmp(ext,'.zip')
    unzip(fn)
    zipped = true;
    fn = FindFiles('*.nvt','CheckSubdirs',false);
end
if iscell(fn)
    fn = fn{1};
end

[x,y]=LoadVT_lumrg(fn);
x.T = sort(x.T);
y.T = sort(y.T);

dx = dxdt(x);
dy = dxdt(y);
v = tsd(dx.range,sqrt(dx.data.^2+dy.data.^2));

enter = [];
exit = [];
p = [];
for z = 1 : length(ZoneIn)
    if ZoneIn(z)<10
        enter = [enter EnteringZoneTime(z)/1e6];
        p = [p ZoneProbability(z)];
        if isempty(window)
            if z<length(ZoneIn)
                exit = [exit EnteringZoneTime(z+1)/1e6];
            else
                exit = [exit max(v.range)];
            end
        end
    end
end
if ~isempty(window)
    exit = min(enter+window,max(v.range));
end

probs = unique(ZoneProbability);

subplot(1,2,1)
xlabel('Probability')
if ~isempty(window)
    ylabel(sprintf('Average Velocity from entry to %.1fs later\n(pixels/sec)',window))
else
    ylabel(sprintf('Average Velocity from zone entry to exit\n(pixels/sec)',window))
end
set(gca,'xlim',[-0.05 1.05])
subplot(1,2,2)
xlabel('Probability')
if ~isempty(window)
    ylabel(sprintf('Maximum Velocity\n(In %.1fs window from entering zone)',window))
else
    ylabel(sprintf('Maximum Velocity\n(From zone entry to exit)',window))
end
set(gca,'xlim',[-0.05 1.05])

for pid = 1 : length(probs)
    idx = p == probs(pid);
    enteringTimes = enter(idx);
    exitingTimes = exit(idx);
    dat = [];
    mu = [];
    maximum = [];
    for l = 1 : length(enteringTimes)
        d0 = v.restrict(enteringTimes(l),exitingTimes(l));
        d = d0.data;
        dat = [dat;d(:)];
        mu = [mu;mean(dat)];
        maximum = [maximum;max(dat)];
    end
    vel(pid).p = probs(pid);
    vel(pid).dat = dat;
    vel(pid).m = mu;
    vel(pid).max = maximum;
    
    subplot(1,2,1)
    hold on
    plot(probs(pid),mean(vel(pid).m),'ko')
    eh=errorbar(probs(pid),mean(vel(pid).m),std(vel(pid).m)./sqrt(numel(vel(pid).m)));
    set(eh,'color','k','linestyle','none')
    hold off
    subplot(1,2,2)
    hold on
    plot(probs(pid),mean(vel(pid).max),'ko')
    eh=errorbar(probs(pid),mean(vel(pid).max),std(vel(pid).max)./sqrt(numel(vel(pid).max)));
    set(eh,'color','k','linestyle','none')
    hold off
end
subplot(1,2,1)
hold on
X = [];
Y = [];
for pid = 1 : length(vel)
    X = [X; mean(vel(pid).p)];
    Y = [Y; mean(vel(pid).m)];
end
plot(X,Y,'k-')
hold off
subplot(1,2,2)
hold on
X = [];
Y = [];
for pid = 1 : length(vel)
    X = [X; mean(vel(pid).p)];
    Y = [Y; mean(vel(pid).max)];
end
plot(X,Y,'k-')
hold off
fh = gcf;


if zipped
    delete(fn)
end