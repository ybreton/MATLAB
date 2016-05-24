function [x,y] = DD_PlotVT2(x,y, varargin)
% 2011-09-30 AEP Plot VT1 Data
% 2012-01-18 AndyP  modified for new codeset
% 2012-07-25 AndyP  added RestrictIt option, renamed from DDPlotVT2
RestrictIt = false;
dStart=0; %#ok<*NASGU>
dEnd=0;
if nargin==0
	[x,y] = GetVT2('LoadVT',1);
end

process_varargin(varargin);

if RestrictIt
x=x.restrict(x.starttime+dStart,x.starttime+dEnd);  %#ok<*UNRCH>
y=y.restrict(y.starttime+dStart,x.starttime+dEnd);
end

figure(1);
clf;

subplot(4,4,[2,4]); hold on;
plot(x.data,x.range, 'k.', 'MarkerSize', 12);
title('X (pixels)', 'FontSize', 12);
ylabel('time (s)', 'FontSize', 12);
set(gca, 'XDir', 'reverse');
h = zoom; setAxesZoomMotion(h,gca,'vertical');
axis([min(x.data) max(x.data) min(x.range) max(x.range)]);
grid on;

subplot(4,4,[5;9;13]);  hold on;
plot(y.range,y.data,'k.', 'MarkerSize', 12); hold on;
xlabel('time(s)', 'FontSize', 12);
ylabel('Y (pixels)', 'FontSize', 12);
h = zoom; setAxesZoomMotion(h,gca,'horizontal');
axis([min(y.range) max(y.range) min(y.data) max(y.data)]);
grid on;

subplot(4,4,[6:8,10:12,14:16]); hold on;
plot(x.data,y.data, 'k.', 'MarkerSize', 8);
xD = fliplr(x.data);
x = tsd(x.range, xD);
set(gca, 'XDir', 'reverse');
xlabel('X (pixels)', 'FontSize', 12);
ylabel('Y (pixels)', 'FontSize', 12);
axis([min(x.data) max(x.data) min(y.data) max(y.data)]);
grid on;





end






