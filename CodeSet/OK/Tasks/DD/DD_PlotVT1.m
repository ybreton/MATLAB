function [x,y] = DD_PlotVT1(x,y,varargin)
% 2011-09-30 AEP Plot VT1 Data
% 2012-01-18 AndyP  modified for new codeset
% 2012-07-25 AndyP  added plot options Autoscale, PlotVT2, PlotZones, and
% RestrictIt.  Renamed from DDPlotVT1
% INPUTS
% x tsd video tracker x-coordinates
% y tsd video tracker y-coordinates
% OUTPUTS
% x tsd video tracker x-coordinates (same as input, or from GetVT1)
% y tsd video tracker y=coordinates (same as input, or from GetVT1)
% VARARGIN OPTIONS
% SoM_x, SoM_y  1x1 double, (S)tart (o)f (M)aze, <x,y> coordinates of circle center [pixels]
% CP_x, CP_y    1x1 double, (C)hoice (P)oint, <x,y> coordinates of circle center [pixels]
% LF_x, LF_y    1x1 double, (L)eft (F)eeder, <x,y> coordinates of circle center [pixels]
% RF_x, RF_y    1x1 double, (R)eft (R)eeder, <x,y> coordinates of circle center [pixels]
% InZoneDistance 1x4 double,  radius of zones [SoM CP LF RF] units of [pixels]
% Default <x,y> coordinates and radii are for DD triangle maze in running
% room 1
% Autoscale 1x1 logical, scales graphs for convenient viewing of DD
% triangle maze
% PlotVT2 1x1 logical, plots a filled in patch approximating the VT2 coordinates in
% VT1 space, appropriate for running room 1 tasks.
% PlotZones 1x1 logical, plots circles of radius InZoneDistance and center
% <x,y>
% RestrictIt 1x1 logical, restricts tracking data between
% (x.starttime+dStart) and (x.starttime+dEnd);
% dStart, dEnd 1x1 double, timestamps to restrict tracking data

SoM_x = 280;
SoM_y = 209;
CP_x = 141;
CP_y = 209;
LF_x = 141;
LF_y = 337;
RF_x = 141;
RF_y = 81;
InZoneDistance = [60 77 77 77];
Autoscale = false;
PlotVT2 = false;
PlotZones = false;
RestrictIt = false;
dStart=0; %#ok<*NASGU>
dEnd=0;
if nargin==0 || isempty(x) || isempty(y)
	[x,y] = GetVT1('LoadVT',1);
end

process_varargin(varargin);

if RestrictIt
x=x.restrict(x.starttime+dStart,x.starttime+dEnd); 
y=y.restrict(y.starttime+dStart,x.starttime+dEnd);
end

figure(1);
clf;

subplot(4,4,[2,4]); hold on;
plot(x.data,x.range, 'k.', 'MarkerSize', 12);
title('X (pixels)', 'FontSize', 12);
ylabel('time (s)', 'FontSize', 12);
h = zoom; setAxesZoomMotion(h,gca,'vertical');
grid on;
if PlotZones; rectangle('Position', [(SoM_x-InZoneDistance(1)), min(x.range), ((SoM_x+InZoneDistance(1))-(SoM_x-InZoneDistance(1))), max(x.range)]); end %#ok<*UNRCH>
if Autoscale==1; axis([100 350 min(x.range) max(x.range)]); end

subplot(4,4,[5;9;13]);  hold on;
plot(y.range,y.data,'k.', 'MarkerSize', 12); hold on;
xlabel('time(s)', 'FontSize', 12);
ylabel('Y (pixels)', 'FontSize', 12);
set(gca, 'YDir', 'reverse');
if PlotZones; rectangle('Position', [min(y.range),(SoM_y-InZoneDistance(1)), max(y.range), ((SoM_y+InZoneDistance(1))-(SoM_y-InZoneDistance(1)))]); end
if Autoscale==1; axis([min(x.range) max(x.range) 0 400]); end
h = zoom; setAxesZoomMotion(h,gca,'horizontal');
grid on;

subplot(4,4,[6:8,10:12,14:16]); hold on;
plot(x.data,y.data, 'k.', 'MarkerSize', 8);
if PlotZones
	circle([SoM_x,SoM_y],InZoneDistance(1),500,'b'); %by Zhihua He (20 Dec 2002). http://www.mathworks.com/matlabcentral/fileexchange/2876. (dl'ed 5/15/2011)
	circle([CP_x,CP_y], InZoneDistance(2),500,'b');
	circle([RF_x,RF_y], InZoneDistance(4),500,'b');
	circle([LF_x,LF_y], InZoneDistance(3),500,'b');
end
if PlotVT2
	patch([111, 201, 201, 109], [256, 263, 145, 154], [0,0,0,0], 'FaceColor', 'b');
end
set(gca, 'YDir', 'reverse');
xlabel('X (pixels)', 'FontSize', 12);
ylabel('Y (pixels)', 'FontSize', 12);
grid on;
if Autoscale == 1; axis([100 350 0 400]); end

end






