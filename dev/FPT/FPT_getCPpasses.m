function [ sd ] = FPT_getCPpasses( sd, varargin )
% 2012-04-26 AndyP
% 2012-07-25 AndyP renamed function from DDgetCPpasses.m
% get choice point entering and exiting times
% sd = DDtri_getCPpasses(sd);
% sd = DDtri_getCPpasses(sd, 'splitTime', 3);
% sd = DDtri_getCPpasses(sd, 'Xrange',[190 200],'Yrange',[150 250]);
%
% INPUTS
% sd - structure, lab-standard 'session data' structure
% OUTPUTS
% sd - structure, lab-standard 'session data' structur
X=sd.x.data;
Y=sd.y.data;
time=sd.x.range;
splitTime = 5; %  [s] the minimum lap time cutoff
Xrange = [190 210]; % [pixels] the minimum and maximum pixel number in X dimension
Yrange = [150 250]; % [pixels] the minimum and maximum pixel number in Y dimension
% timestamp constraints
L0 = [sd.x.starttime, sd.ExitZoneTime];  %  [s]  nLx1, minimum time of event
L1 = [sd.EnteringZoneTime, sd.x.endtime]; % [s]  nLx1, maximum time of event
% position restraints
keep = Xrange(1) < X & X < Xrange(2) & Yrange(1) < Y & Y < Yrange(2);
process_varargin(varargin);
%--------------
if ~isempty(keep); 
	[Lstart,~] = FindAnyLap(time(keep), X(keep),'splitTime',splitTime); 
end
%--------------
EnteringCPTime = nan(1,sd.TotalLaps);
ExitingCPTime = nan(1,sd.TotalLaps);
if ~isempty(keep);
	for iL = 1:sd.TotalLaps;
		LstartToUse = find(Lstart > L0(iL) & Lstart < L1(iL)); % apply timestamp constraints
		if isempty(LstartToUse)
		else
			if length(LstartToUse)>1; LstartToUse=LstartToUse(end); end
			EnteringCPTime(1,iL) =Lstart(LstartToUse);
			ExitingCPTime(1,iL) = L1(iL);
			assert(ExitingCPTime(iL)-EnteringCPTime(iL)>0,'negative times');
		end
	end
else error('no tracking data');
end
%--------------
sd.EnteringCPTime = EnteringCPTime;
sd.ExitingCPTime = ExitingCPTime;
end

