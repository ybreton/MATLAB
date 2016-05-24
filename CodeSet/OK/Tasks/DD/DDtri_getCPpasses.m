function [ sd ] = DDtri_getCPpasses( sd, varargin )
% 2012-04-26 AndyP
% 2012-07-25 AndyP renamed function from DDgetCPpasses.m
% 2013-01-21 AndyP moved keep below process_varargin, modified points to keep process
% 2013-03-19 AndyP added checks

% get choice point entering and exiting times
% sd = DDtri_getCPpasses(sd);
% sd = DDtri_getCPpasses(sd, 'splitTime', 3); % tighten lap time constraint
% sd = DDtri_getCPpasses(sd, 'Xrange',[190 200],'Yrange',[150 250]); %
% tighten position constraint
%
% INPUTS
% sd - structure, standard session data structure
% OUTPUTS
% sd - structure, standard session data structure, with EnteringCPTime and
% ExitingCPTime fields appended
% VARARGIN OPTIONS
% splitTime - 1x1 double [sec], minimum time between points for consecutive laps 
% Xrange - 1x2 double [pixels], minimum,maximum <x> position constraint
% Yrange - 1x2 double [pixels], minimum,maximum <y> position constraint
% doPlot - 1x1 logical, optional plot output to check function

splitTime = 5; %  [s] minimum lap time cutoff
Xrange = [210 230]; % [pixels] the minimum and maximum pixel number in X dimension
Yrange = [170 260]; % [pixels] the minimum and maximum pixel number in Y dimension
doPlot = false;  % optional plot output

process_varargin(varargin);

% checks
fnames = fieldnames(sd);
assert(any(strcmp(fnames,'x')),'sd must contain field x');
assert(any(strcmp(fnames,'y')),'sd must contain field y');
assert(any(strcmp(fnames,'EnteringZoneTime')),'sd must contain field EnteringZoneTime');
assert(any(strcmp(fnames,'ExitZoneTime')),'sd must contain field ExitZoneTime');
assert(any(strcmp(fnames,'TotalLaps')),'sd must contain field TotalLaps');

% get video tracker one data
X=sd.x.data;
Y=sd.y.data;
time=sd.x.range;

% time constraints L0(iL-1)<EnteringCPTime(iL)<L1(iL)
L0 = [sd.x.starttime, sd.ExitZoneTime];  %  [s]  L0 - minimum time
L1 = [sd.EnteringZoneTime, sd.x.endtime]; % [s]  L1 - maximum time 

% position constraint
keep = Xrange(1) < X & X < Xrange(2) & Yrange(1) < Y & Y < Yrange(2);
if ~isempty(keep);
	[Lstart,~] = FindAnyLap(time(keep), X(keep),'splitTime',splitTime); % get points crossing the rectangle defined by keep, at times greater than splitTime
	Lstart=[sd.x.starttime,Lstart];
end

%%% get choice point entering and exiting times
EnteringCPTime0 = nan(1,sd.TotalLaps);
ExitingCPTime0 = nan(1,sd.TotalLaps);
if ~isempty(keep);
	for iL = 1:sd.TotalLaps;
		LstartToUse = find(Lstart > L0(iL) & Lstart < L1(iL)); % apply timestamp constraints
		if isempty(LstartToUse)
		else
			LendToUse = find(sd.EnteringZoneTime>Lstart(LstartToUse(end)),1,'first'); 
			% The DD triangle maze had overlapping choice-point zones and feeder zones.  
			% To assure that tracking data is obtained before the rat entered the feeder zone and heard the tone-cue countdown,
			% ExitingCPTime is the same as the EnteringZoneTime.  
			% 2013-03-19 AndyP
			EnteringCPTime0(1,iL) =Lstart(LstartToUse(end));
			ExitingCPTime0(1,iL) = sd.EnteringZoneTime(LendToUse);
			assert(ExitingCPTime0(iL)-EnteringCPTime0(iL)>0,'negative times');
		end
	end
else error('no tracking data in range, check that Xrange and Yrange parameters are centered over entry into the choice point zone');
end

% pack output
sd.EnteringCPTime = EnteringCPTime0;
sd.ExitingCPTime = ExitingCPTime0;

% optional plot output
if doPlot
	figure; hold on; %#ok<UNRCH>
	plot(X.data,Y.data,'.','markersize',1,'color',[0.5 0.5 0.5]);
	plot(X.data(sd.EnteringCPTime),Y.data(sd.EnteringCPTime),'r.','markersize',20);
	plot(X.data(sd.ExitingCPTime),Y.data(sd.ExitingCPTime),'g.','markersize',20);
	patch([Xrange(1) Xrange(2) Xrange(2) Xrange(1)], [Yrange(1) Yrange(1) Yrange(2) Yrange(2)], [0,0,0,0], 'FaceColor', 'b');
	legend('all tracking data','EnteringCPTime','ExitingCPTime','keep = points in box');
	sd.EnteringCPTime = EnteringCPTime0;
	sd.ExitingCPTime = ExitingCPTime0;
end

