function sd = FPTgetZoneTimesVid(sd,varargin)
% 
debug=false;
World = sd.World;
SSN = sd.ExpKeys.SSN;
idDash = regexpi(SSN,'-');
ratStr = SSN(1:idDash(1)-1);
dateVec = [str2double(SSN(idDash(1)+1:idDash(2)-1)) str2double(SSN(idDash(2)+1:idDash(3)-1)) str2double(SSN(idDash(3)+1:end))];

% Coords = sd.Coord;
% Zones{1} = [Coords.SoM_x Coords.SoM_y];
% Zones{2} = [Coords.CP_x Coords.CP_y];
% Zones{3} = [Coords.LF_x Coords.LF_y];
% Zones{4} = [Coords.RF_x Coords.RF_y];

comp1 = [2012 12 13];
comp2 = [2013 03 01];
comp3 = [2013 06 01];
if datenum(dateVec)>datenum(comp1)
    sd.Coord.SoM_x = 480; % Start of Maze <x,y>
    sd.Coord.SoM_y = 195;
    sd.Coord.CP_x = 205;  % Choice point <x,y>
    sd.Coord.CP_y = 200;
    sd.Coord.LF_x = 340;  % Left feeder <x,y>
    sd.Coord.LF_y = 375;
    sd.Coord.RF_x = 320;  % Right Feeder <x,y>
    sd.Coord.RF_y = 30;
end
if datenum(dateVec)>=datenum(comp1) && datenum(dateVec)<datenum(comp2)
    sd.Coord.SoM_x = 240; % Start of Maze <x,y>
    sd.Coord.SoM_y = 240;
    sd.Coord.CP_x = 550;  % Choice point <x,y>
    sd.Coord.CP_y = 225;
    sd.Coord.RF_x = 402;  % Right feeder <x,y>
    sd.Coord.RF_y = 410;
    sd.Coord.LF_x = 405;  % Left Feeder <x,y>
    sd.Coord.LF_y = 77;
%                 sd.InZoneDistance = [60 60 60 60];
end
if datenum(dateVec)>=datenum(comp2) && datenum(dateVec)<datenum(comp3)
    sd.Coord.SoM_x = 240; % Start of Maze <x,y>
    sd.Coord.SoM_y = 240;
    sd.Coord.CP_x = 550;  % Choice point <x,y>
    sd.Coord.CP_y = 240;
    sd.Coord.RF_x = 405;  % Right feeder <x,y>
    sd.Coord.RF_y = 410;
    sd.Coord.LF_x = 405;  % Left Feeder <x,y>
    sd.Coord.LF_y = 70;
%                 sd.InZoneDistance = [60 60 60 60];
end
if datenum(dateVec)>=datenum(comp3)
    sd.Coord.SoM_x = 217; % Start of Maze <x,y>
    sd.Coord.SoM_y = 250;
    sd.Coord.CP_x = 530;  % Choice point <x,y>
    sd.Coord.CP_y = 251;
    sd.Coord.RF_x = 375;  % Right feeder <x,y>
    sd.Coord.RF_y = 410;
    sd.Coord.LF_x = 375;  % Left Feeder <x,y>
    sd.Coord.LF_y = 75;
end
Coords = sd.Coord;
process_varargin(varargin);

sd.Coord = Coords;

Zones{1} = [Coords.SoM_x Coords.SoM_y];
Zones{2} = [Coords.CP_x Coords.CP_y];
Zones{3} = [Coords.LF_x Coords.LF_y];
Zones{4} = [Coords.RF_x Coords.RF_y];

% if datenum(dateVec)>datenum([2012 11 29])
%     % new coords
%     Zones = {[180,204], [553,189], [394,29], [426,361]}; 
% else
%     % old coords
%     Zones = {[553,189], [180,204], [350,363], [328,31]}; 
% end

LeftF1 = 0; % left F - CORRECT FOR RR3  % FIXED ADR/CB 28/Nov/2012
RightF1 = 2; % right F  - CORRECT FOR RR3

TotalPellets = 0;
TotalLaps = 0;

state = 0; % always start from state 1
zone = 0;

FeederTimes = [];
FeedersFired = [];
EnteringZoneTime = [];
ExitZoneTime = [];
EnteringCPTime = [];
ExitingCPTime = [];
EnteringSoMTime = [];
ExitingSoMTime = [];
ZoneIn = [];
ZoneDelay = [];
FeederSkip = [];
BackwardsTimes = [];
timeInZone = -1;
countdownTimer = inf;
t = [];

CheckFirstFlag=0;
CheckR=0; %#ok<*NASGU>
CheckL=0;
GoingBackwards = 0;

DelayedSideDelays = sd.ZoneDelay(sd.ZoneIn==sd.DelayZone);
if isempty(DelayedSideDelays);DelayedSideDelays=nan;end
startDelayTime = DelayedSideDelays(1);
display(sd.World);
if sd.World.incrLgoL>0&&sd.World.incrLgoR<0
    startTimeL = startDelayTime;
    startTimeR = 1;
    policy = 'L';
    disp('Left delaying world');
else
    startTimeL = 1;
    startTimeR = startDelayTime;
    policy = 'R';
    disp('Right delaying world');
end

leftDelay = startTimeL;
rightDelay = startTimeR;
X = sd.x.data;
Y = sd.y.data;
T = sd.x.range;
idnan = isnan(X)|isnan(Y)|isnan(T);
X = X(~idnan);
Y = Y(~idnan);
T = T(~idnan);
InZoneDistance = sd.InZoneDistance;

for iT = 1 : length(T)
	t = T(iT);
    x = X(iT);
    y = Y(iT);
    if debug
        clf
        hold on
        plot(X,Y,'-','color',[0.8 0.8 0.8])
        plot(x,y,'.k')
        theta=linspace(-pi,pi);
        for iZ=1:length(Zones)
            circleX = Zones{iZ}(1)+InZoneDistance(iZ)*cos(theta);
            circleY = Zones{iZ}(2)+InZoneDistance(iZ)*sin(theta);
            plot(circleX,circleY,'r:');
        end
        hold off
        drawnow
    end
    
	zone = GetZone(x,y,Zones,InZoneDistance);
	switch state(end)
		case 0 % LIMBO ZONE (Zone 0)
			switch zone
				case 1
					if GoingBackwards == 0
						state = 1;
						EnteringSoMTime(end+1)=t;
					else
						state = 0;
					end
				case 2
					if GoingBackwards == 0
						state = 2;
					else
						state = 0;
					end
				case 3
					state = 3;
					GoingBackwards = 1;
				case 4
					state = 4;
					GoingBackwards = 1;
			end
		case 1 % START OF MAZE ZONE (SOM, Zone 1)
			switch zone
				case 2
					GoingBackwards = 0;
					ExitingSoMTime(end+1) = t; %#ok<*AGROW>
					EnteringCPTime(end+1) = t;
					state = 2;
				case 3
					GoingBackwards = 1;
					BackwardsTimes(end+1) = t;
					state = 0;
				case 4
					GoingBackwards = 1;
					BackwardsTimes(end+1) = t;
					state = 0;
			end	
		case 2 %  CHOICE POINT ZONE (CP, Zone 2)
			switch zone
				case 1
					GoingBackwards = 1;
					BackwardsTimes(end+1) = t;
					state = 1;
				case 3 % went L
					if GoingBackwards == 0
						timeInZone = leftDelay;
						state = 3;
						ExitingCPTime(end+1)=t;
						EnteringZoneTime(end+1) = t;
						ZoneDelay(end+1) = leftDelay;
						ZoneIn(end+1) = 3;
						countdownTimer = T(iT);
						TotalLaps = TotalLaps+1;
			
						if CheckFirstFlag==0;
							[checkR, checkL, CheckFirstFlag] = CheckFirst(ZoneIn,  policy, CheckFirstFlag); %29/Oct/2010 AEP
						end
					
						leftDelay = max(1,leftDelay + World.incrLgoL);
						rightDelay = max(1,rightDelay + World.incrRgoL+checkL); %added checkL 29/Oct/2010 AEP
					end
					
				case 4 %went R
					if GoingBackwards==0
						timeInZone = rightDelay;
						state = 4;
						ExitingCPTime(end+1)=t;
						EnteringZoneTime(end+1) = t;
						ZoneDelay(end+1) = rightDelay;
						ZoneIn(end+1) = 4;
						countdownTimer = T(iT);
						TotalLaps = TotalLaps+1;
						
						if CheckFirstFlag==0;
							[checkR, checkL, CheckFirstFlag] = CheckFirst(ZoneIn,  policy, CheckFirstFlag); %29/Oct/2010 AEP
						end
						
						leftDelay = max(1,leftDelay + World.incrLgoR+checkR); %added checkR 29/Oct/2010 AEP
						rightDelay = max(1,rightDelay + World.incrRgoR);
						
					end
			end
			
		case 3 % LEFT FEEDER ZONE (LF, Zone 3)
			switch zone
				case 1
					
					GoingBackwards = 0;
					state = 1;
					if timeInZone ~= -2;
						FeedersFired(end+1)=NaN;   %Changed from zero. 01/27/2012 AEP and BJS  changed from '0' which could be problematic for analysis
						FeederTimes(end+1)=NaN;  %Changed from zero. 10/26/2011 AEP and JJS  changed from '0' which could be problematic for analysis
						FeederSkip(end+1)=1;
					else
					end
					timeInZone = -1;
					countdownTimer = inf;
					ExitZoneTime(end+1) = t; %PlayTones(1000, 0.1);
					EnteringSoMTime(end+1) = t;
					
				case 2
					if timeInZone ~= -2;
						FeedersFired(end+1)=NaN;  %Changed from zero. 01/27/2012 AEP and BJS  changed from '0' which could be problematic for analysis
						FeederTimes(end+1)=NaN; %Changed from zero. 10/26/2011 AEP and JJS  changed from '0' which could be problematic for analysis
						FeederSkip(end+1)=0;
					else
					end
					GoingBackwards = 1;
					BackwardsTimes(end+1) = t;
					state = 0; % limbo
					timeInZone = -1;
					countdownTimer = inf;
					
				case {0,3} %added case 0 so countdown will continue if tracking is lost
					state = 3;
					if timeInZone>0 && (T(iT)-countdownTimer) > 1 % second
						timeInZone = timeInZone-1;
						countdownTimer = T(iT);
						
					end
					if timeInZone==0; % FIRE
						FeederTimes(end+1) = t;
						FeedersFired(end+1) = LeftF1;
						FeederSkip(end+1)=0;
						TotalPellets = TotalPellets + World.nPleft;
						timeInZone = -2;
						state = 3;
					end
			end
			
		case 4 % RIGHT FEEDER ZONE (RF, Zone 4)
			switch zone
				case 1
					GoingBackwards = 0;
					state = 1;
					if timeInZone ~= -2;
						FeedersFired(end+1)=NaN; %2012-01-27 AndyP and BJS
						FeederTimes(end+1)=NaN;
						FeederSkip(end+1)=1;
					else
					end
					timeInZone = -1;
					countdownTimer = inf;
					ExitZoneTime(end+1) = t;  %PlayTones(1000, 0.1);
					EnteringSoMTime(end+1) = t;
					
				case 2
					GoingBackwards = 1;
					BackwardsTimes(end+1)=t;
					if timeInZone ~= -2;
						FeedersFired(end+1)=NaN;  %2012-01-27 AndyP and BJS
 						FeederTimes(end+1)=NaN;
						FeederSkip(end+1)=0;
					else
					end
					state = 0; % limbo
					timeInZone = -1;
					countdownTimer = inf;
					
				case {0,4}  %added case 0 so countdown will continue if tracking is lost
					state = 4;
					if timeInZone>0 && (T(iT)-countdownTimer) > 1 % second
						timeInZone = timeInZone-1;
						countdownTimer = T(iT);
						
					end
					if timeInZone==0; % FIRE
						FeederTimes(end+1) = t;
						FeedersFired(end+1) = RightF1;
						FeederSkip(end+1)=0;
						TotalPellets = TotalPellets + World.nPright;
						timeInZone = -2;
						state = 4;
					end
			end
		otherwise
			error('unknown zone');
    end
end % outer while timing loop


ZoneTimes = nan(6,TotalLaps*2);
ZoneTimes(1,1:length(EnteringSoMTime)) = EnteringSoMTime;
ZoneTimes(2,1:length(ExitingSoMTime)) = ExitingSoMTime;
ZoneTimes(3,1:length(EnteringCPTime)) = EnteringCPTime;
ZoneTimes(4,1:length(ExitingCPTime)) = ExitingCPTime;
ZoneTimes(5,1:length(EnteringZoneTime)) = EnteringZoneTime;
ZoneTimes(6,1:length(ExitZoneTime)) = ExitZoneTime;

[ZoneTimes,ZoneDelay,ZoneIn] = fixFPTzoneTimes(ZoneTimes,ZoneDelay,ZoneIn);

idOK = find(any(~isnan(ZoneTimes)),1,'last');
ZoneTimes = ZoneTimes(:,1:idOK);

clf
set(gca,'xtick',[])
set(gca,'ytick',[])
set(gca,'xlim',[0 720])
set(gca,'ylim',[0 480])
hold on
for iLap=1:size(ZoneTimes,2)
    plot(data(sd.x.restrict(ZoneTimes(1,iLap),ZoneTimes(2,iLap))),data(sd.y.restrict(ZoneTimes(1,iLap),ZoneTimes(2,iLap))),'.g')
    plot(data(sd.x.restrict(ZoneTimes(3,iLap),ZoneTimes(4,iLap))),data(sd.y.restrict(ZoneTimes(3,iLap),ZoneTimes(4,iLap))),'.b')
    plot(data(sd.x.restrict(ZoneTimes(5,iLap),ZoneTimes(6,iLap))),data(sd.y.restrict(ZoneTimes(5,iLap),ZoneTimes(6,iLap))),'.r')
    title(num2str(iLap));
    drawnow
end
hold off

EnteringSoMTime= ZoneTimes(1,1:idOK);
ExitingSoMTime= ZoneTimes(2,1:idOK);
EnteringCPTime= ZoneTimes(3,1:idOK);
ExitingCPTime= ZoneTimes(4,1:idOK);
EnteringZoneTime= ZoneTimes(5,1:idOK);
ExitZoneTime= ZoneTimes(6,1:idOK);

ZoneIn(end+1:idOK) = nan;
ZoneDelay(end+1:idOK) = nan;

ZoneTimes = ZoneTimes(:,1:idOK);
ZoneTimes(7,end) = nan;
ZoneTimes(7,1:end-1) = ZoneTimes(1,2:end);
D = diff(ZoneTimes,1,1);

sd.TimeInSoM=D(1,:);
sd.TimeSoMtoCP=D(2,:);
sd.TimeInCP=D(3,:);
sd.TimeCPtoZone=D(4,:);
sd.TimeInZone=D(5,:);
sd.TimeZonetoSoM=D(6,:);

idnan = isnan(ZoneIn);
idnanfeeds = isnan(FeederTimes);

sd.FeederTimes=FeederTimes(~idnanfeeds);
sd.FeedersFired=FeedersFired(~idnanfeeds);
sd.FeederSkip=FeederSkip(~idnanfeeds);
sd.EnteringZoneTime=EnteringZoneTime(~idnan);
sd.ExitZoneTime=ExitZoneTime(~idnan);
sd.EnteringCPTime=EnteringCPTime(~idnan);
sd.ExitingCPTime=ExitingCPTime(~idnan);
sd.EnteringSoMTime=EnteringSoMTime(~idnan);
sd.ExitingSoMTime=ExitingSoMTime(~idnan);
% sd.ZoneIn=ZoneIn(~idnan);
% sd.ZoneDelay=ZoneDelay(~idnan);

sd.TimeInSoM=sd.TimeInSoM(~idnan);
sd.TimeSoMtoCP=sd.TimeSoMtoCP(~idnan);
sd.TimeInCP=sd.TimeInCP(~idnan);
sd.TimeCPtoZone=sd.TimeCPtoZone(~idnan);
sd.TimeInZone=sd.TimeInZone(~idnan);
sd.TimeZonetoSoM=sd.TimeZonetoSoM(~idnan);

sd.BackwardsTimes=BackwardsTimes;
% sd.TotalLaps=length(sd.ZoneIn);
% 
% disp('Fixing CP exit times...')
% for iLap=1:length(sd.ExitingCPTime);
%     Tin = sd.EnteringCPTime(iLap);
%     Tout = sd.ExitingCPTime(iLap);
%     if isnan(Tin)&&~isnan(Tout)&&iLap==1
%         Tin = min(sd.x.range);
%     end
%     if isnan(Tout)&&~isnan(Tin)&&iLap==sd.TotalLaps
%         Tout = max(sd.x.range);
%     end
%     x0=data(sd.x.restrict(Tin,Tout));
%     y0=data(sd.y.restrict(Tin,Tout));
%     t0=range(sd.x.restrict(Tin,Tout));
%     right=(x0<Zones{2}(1)-InZoneDistance(2));
%     left=(x0>Zones{2}(1)+InZoneDistance(2));
%     up=(y0>Zones{2}(2)+InZoneDistance(2));
%     down=(y0<Zones{2}(2)-InZoneDistance(2));
%     NA=isnan(x0)|isnan(y0);
%     pt = (1:length(t0))';
%     in = find(~right&~left&~up&~down&~NA,1,'first');
%     if any(in)
%         sd.EnteringCPTime(iLap) = t0(in);
%     end
%     out = find((right|left|up|down)&(pt>in),1,'first');
%     if any(out)
%         disp(['Fixing lap ' num2str(iLap)])
%         sd.ExitingCPTime(iLap) = t0(out-1);
%         sd.TimeInCP(iLap) = t0(out-1)-t0(in);
%         sd.TimeCPtoZone(iLap) = max(t0)-t0(out-1);
%     end
% end

function [z,d] = GetZone(x,y,Z,D)

z = 0; d = inf;
for iZ = 1:length(Z)
	d0 = sqrt((x-Z{iZ}(1))*(x-Z{iZ}(1)) + (y-Z{iZ}(2))*(y-Z{iZ}(2)));
	if (d0<D(iZ))
		z = iZ; d = d0;
	end
end

function [checkR, checkL, CheckFirstFlag] = CheckFirst(ZoneIn,  policy, CheckFirstFlag) %Prevent delay from changing until delayed side is sampled.
if strcmp(policy,'Right') || strcmp(policy,'RIGHT') || strcmp(policy,'r') || strcmp(policy,'R') || strcmp(policy, 'right');
	if size(find(ZoneIn==4))>0 %Delay on the right side.
		checkR = 0;
		checkL = 0;
		CheckFirstFlag=1;
	else % do not change the delay until delayed zone has been traversed.
		checkR = 0;
		checkL = 1;
	end
end

if strcmp(policy, 'Left')||strcmp(policy, 'LEFT')||strcmp(policy, 'l')||strcmp(policy, 'L') || strcmp(policy, 'left');
	if size(find(ZoneIn==3))>0 % Delay on left side.
		checkL = 0;
		checkR = 0;
		CheckFirstFlag=1;
	else % do not change the delay until delayed zone has been traversed.
		checkL = 0;
		checkR = 1;
	end
end