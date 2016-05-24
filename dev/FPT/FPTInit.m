 function sd = FPTInit(fdfn,varargin)
 
% sd = TaskInit(fd)
%
% FPT task initialization function
% checks and loads keys, video-tracker-1, and spikes
%
% ADR 2011-12
% YAB 2012-12:      FPT initialization
%                   Loads keys file, VT1, mat, events
%                   Assumes VT1 contains ('LED' and 'phiH') or 'Head'

Keys = true; %1 = load keys.m, 0 = don't
% VT = true;  %1 = load -VT.mat, 0 = don't.
% VT1 = false;  %1 = load -VT1.mat, 0 = don't
VT = [];
VT1 = [];
Spikes = false;  %1 = load spikes, 0 = don't
DD  = true;  %1 = load DD*.mat, 0 = don't
Use__Ts = false; % load ._t cells
Events = false; % load events file
if mod(length(varargin),2)~=0;
	varargin{end+1}=nan;
end
correctTrackingGlitches = false;
Vmax = 300;
Amax = 1000;
useMP4 = true;
process_varargin(varargin);
Keys = logical(Keys);

Spikes = logical(Spikes);
DD = logical(DD);
Use__Ts = logical(Use__Ts);
Events = logical(Events);

if nargin>0 && ~isempty(fdfn)
    idDelim = max(regexp(fdfn,'\'));
    fd = fdfn(1:idDelim-1);
    fn = fdfn(idDelim+1:end);
    assert(exist(fd, 'dir')==7, 'Cannot find directory %s.', fd);
    assert(exist(fdfn, 'file')==2, 'Cannot find file %s.',fn)
	pushdir(fd);
	dirpushed = true;
else
	fd = pwd;
    fList = files(fd);
    fn=filter_files(fList,'\.mat',{'-VT1'});
    fn=fn{1};
    fdfn = [fd '\' fn];
    dirpushed = false;
end


[~, SSN, ~] = fileparts(fd);

% Each mat file has structure
% DD-yyyy-mm-dd-hh_nn_ss.mat
idDateStart = regexp(fn,'[0-9]{4}-[0-9]{2}-[0-9]{2}');
idTimeStart = regexp(fn,'-[0-9]{2}_[0-9]{2}_[0-9]{2}');
idExt = regexp(fn,'.mat');
idRat = regexp(fd,'R[0-9]{3}');
Rstr = fd(idRat:idRat+3);
Dstr = fn(idDateStart:idTimeStart-1);
Tstr = fn(idTimeStart+1:idExt-1);

nvt = FindFiles('*.nvt','CheckSubdirs',0);
fpt = FindFiles('FPT-tracking-*.txt','CheckSubdirs',0);
unzippedNVT = false;
if isempty(nvt)&isempty(fpt)
    zipfile = FindFiles('*.zip','CheckSubdirs',0);
    unzippedNVT = true;
    unzip(zipfile{1})
    nvt = FindFiles('*.nvt','CheckSubdirs',0);
    fpt = FindFiles('FPT-tracking-*.txt','CheckSubdirs',0);
end
if isempty(fpt)&~isempty(nvt)
    x = [];
    y = [];
    T = [];
    for f = 1 : length(nvt)
        [x0,y0] = LoadVT_lumrg(nvt{f});
        Tx = x0.range;
        Dx = x0.data;
        Dy = y0.data;
        T = cat(1,T,Tx(:));
        x = cat(1,x,Dx(:));
        y = cat(1,y,Dy(:));
    end
    [T,id] = unique(T);
    x = tsd(T,x(id));
    y = tsd(T,y(id));
end
if ~isempty(fpt)&isempty(nvt)
    x = [];
    y = [];
    T = [];
    for f = 1 : length(fpt)
        [x0,y0] = LoadFPT_tracking(fpt{f});
        Tx = x0.range;
        Dx = x0.data;
        Dy = y0.data;
        T = cat(1,T,Tx(:));
        x = cat(1,x,Dx(:));
        y = cat(1,y,Dy(:));
    end
    [T,id] = unique(T);
    x = tsd(T,x(id));
    y = tsd(T,y(id));
end
VT=true;
vtfn = fullfile(fd, [SSN '-vt.mat']);
if exist('vtfn','file')==2
    save(vtfn,'x','y','-append')
else
    save(vtfn,'x','y')
end
sd.x = x;
sd.y = y;

% if isempty(VT)&&isempty(VT1)
%     vtfn = fullfile(fd, [SSN '-vt.mat']);
%     vtfn = FindFile(vtfn);
%     vt1fn = fullfile(fd, [SSN '-vt1.mat']);
%     vt1fn = FindFile(vt1fn);
%     if ~isempty(vtfn)
%         VT = true;
%         VT1 = false;
%         fprintf('\nUsing %s-vt.mat\n',SSN);
%     elseif ~isempty(vt1fn)
%         VT1 = true;
%         VT = false;
%     end
% end
% RTDfn0 = FindFiles('*-RatTrackData.mat');
% RTDfn = '';
% for f = 1 : length(RTDfn0)
%     RTD = load(RTDfn0{f});
%     if isfield(RTD,'VIDEOTRACKER')
%         RTDfn = RTDfn0{f};
%         VT = load(RTDfn);
%         RTD = VT.VIDEOTRACKER;
%     end
% end

%-----------------------
% KEYS
%-----------------------
if Keys
    keysfn = [strrep(SSN, '-', '_') '_keys'];
    assert(exist(keysfn, 'file')==2, 'Cannot find keys file %s.', keysfn);
    eval(keysfn);
    sd.ExpKeys = ExpKeys;
    sd.ExpKeys.SSN = SSN;
    sd.ExpKeys.fd = fd;

    assert(~iscell(ExpKeys.Behavior), 'Multiple Behaviors');
end

%------------------------
% VIDEO TRACKING
%------------------------
W = warning();
warning off MATLAB:unknownObjectNowStruct

% if isempty(RTDfn)
%     if VT
%         W = warning();
%         warning off MATLAB:unknownObjectNowStruct
%         vt1fn = fullfile(fd, [SSN '-vt.mat']);
%         nvtzip = fullfile(fd, [SSN '-VT1.zip']);
%         vtnvt = fullfile(fd, 'VT1.nvt');
%         assert(exist(vt1fn, 'file')==2, 'Cannot find vt file %s.', vt1fn);
%         if exist(vt1fn, 'file')
%             load(vt1fn);
% 
% %             if Keys==1;
% %                 sd.x = x.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
% %                 sd.y = y.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
% %             end
% 
%             tx = x.range;
%             ty = y.range;
%             keep = ~isnan(tx)&~isnan(ty);
%             x = x.data;
%             y = y.data;
%             x = tsd(tx(keep),x(keep,:));
%             y = tsd(ty(keep),y(keep,:));
%             sd.x = x;
%             sd.y = y;
%             x = tsd(sort(x.range),x.data);
%             y = tsd(sort(y.range),y.data);
%         else
%             if exist(nvtzip, 'file')==2
%                 unzip(nvtzip)
%                 [x,y]=LoadVT_lumrg(vtnvt);
%                 save(vt1fn,'x','y');
%                 delete(vtnvt)
%             else
%                 warning('FileNotFound: No VT file found.');
%             end
%         end
%         warning(W);
%     end
%     if VT1
%         W = warning();
%         warning off MATLAB:unknownObjectNowStruct
%         vt1fn = fullfile(fd, [SSN '-vt1.mat']);
%     % 	assert(exist(vtfn, 'file')==2, 'Cannot find vt file %s.', vtfn);
%         if exist(vt1fn, 'file')
%             load(vt1fn);
%             if ~(exist('Head','var')==1) & ~(exist('x','var')==1 && exist('y','var'))
%                 assert(exist('LED','var')==1&exist('phiH','var'), 'Missing LED and phiH for locating head position.')
%                 t = LED.T;
%                 xy = extract_headXY(LED,phiH);
%                 xy = xy.D;
%             elseif exist('x','var')==1 && exist('y','var')
%                 xy = [x.D(:) y.D(:)];
%                 t = x.T;
%             else
%                 t = Head.T;
%                 xy = Head.D;
%             end
%             % t = xxx corresponds to start of MPEG, microseconds in SMI -> s in x.T.
%             % ExpKeys.TimeOnTrack 
%             keep = ~isnan(t);
% 
%             x = xy(:,1);
%             y = xy(:,2);
%             x = tsd(t(keep),x(keep,:));
%             y = tsd(t(keep),y(keep,:));
%             x = tsd(sort(x.range),x.data);
%             y = tsd(sort(y.range),y.data);
%             if Keys==1;
%                 sd.x = x.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
%                 sd.y = y.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
%             end
%             sd.x = x;
%             sd.y = y;
% 
%         else
%             warning('FileNotFound: No VT file found.');
%         end
%         warning(W);
%     end
% else
%     x = RTD.LED.x;
%     y = RTD.LED.y;
%     t = unique([x.range;y.range]);
%     x = x.data;
%     y = y.data;
%     idnan = isnan(t);
%     x = tsd(t(~idnan),x(~idnan));
%     y = tsd(t(~idnan),y(~idnan));
% %     if Keys==1;
% %         sd.x = x.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
% %         sd.y = y.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
% %     else
%         sd.x = x;
%         sd.y = y;
% %     end
% end
% T = sd.x.range;
% D = sd.x.data;
% [T,id] = unique(T);
% D = D(id);
% sd.x = tsd(T,D);
% T = sd.y.range;
% D = sd.y.data;
% [T,id] = unique(T);
% D = D(id);
% sd.y = tsd(T,D);

% RatTrackData
% RatTrackFN = FindFile('*-RatTrackData.mat');
% if ~isempty(RatTrackFN)
%     RTdat = load(RatTrackFN);
%     if isfield(RTdat,'RatTrackData')
%         if ~isfield(RTdat.RatTrackData,'movieTime')
%             x0 = tsd(sort(RTdat.RatTrackData.timestamp(:)),RTdat.RatTrackData.LEDx(:));
%             y0 = tsd(sort(RTdat.RatTrackData.timestamp(:)),RTdat.RatTrackData.LEDy(:));
%         else
%             x0 = tsd(sort(RTdat.RatTrackData.movieTime(:)),RTdat.RatTrackData.LEDx(:));
%             y0 = tsd(sort(RTdat.RatTrackData.movieTime(:)),RTdat.RatTrackData.LEDy(:));
%         end
%     elseif isfield(RTdat,'LEDx') && isfield(RTdat,'LEDy')
%         x0 = RTdat.LEDx;
%         y0 = RTdat.LEDy;
%         T = x0.range;
%         D = x0.data;
%         T = sort(T);
%         x0 = tsd(T,D);
%         T = y0.range;
%         D = y0.data;
%         T = sort(T);
%         y0 = tsd(T,D);
%     elseif isfield(RTdat,'LED')
%         D = RTdat.LED.data;
%         T = RTdat.LED.range;
%         T = sort(T);
%         x0 = tsd(T,D(:,1));
%         y0 = tsd(T,D(:,2));
%     end
%     sd.LED.x = x0;
%     sd.LED.y = y0;
%     
%     if any(diff(sd.LED.x.range)<=0) || any(diff(sd.LED.y.range)<=0)
%         disp('LED time stamps not ordered.')
%         T = sd.LED.x.range;
%         D = sd.LED.x.data;
%         [T0,id] = unique(T);
% %         D0 = nan(length(T0),1);
% %         for t = 1 : length(T0)
% %             id = T==T0(t);
% %             D0(t,1) = mean(D(id));
% %         end
% 
%         D0 = D(id);
%         sd.LED.x = tsd(T0,D0);
%         T = sd.LED.y.range;
%         D = sd.LED.y.data;
%         [T0,id] = unique(T);
%         D0 = D(id);
% %         D0 = nan(length(T0),1);
% %         for t = 1 : length(T0)
% %             id = T==T0(t);
% %             D0(t,1) = mean(D(id));
% %         end
%         sd.LED.y = tsd(T0,D0);
%     end
%     idnan = isnan(sd.LED.x.range)|isnan(sd.LED.x.data);
%     T = sd.LED.x.range;
%     D = sd.LED.x.data;
%     sd.LED.x =  tsd(T(~idnan),D(~idnan));
%     idnan = isnan(sd.LED.y.range)|isnan(sd.LED.y.data);
%     T = sd.LED.y.range;
%     D = sd.LED.y.data;
%     sd.LED.y =  tsd(T(~idnan),D(~idnan));
% end

%-------------------------
% EVENTS
%-------------------------
if Events
    eventsfn = fullfile(fd, [SSN '-events.Nev']);
    assert(exist(eventsfn, 'file')==2, 'Cannot find events file %s.', eventsfn);
end

%-------------------------
% SPIKES
%-------------------------
if Spikes
    fc = FindFiles('*.t', 'CheckSubdirs', 0);
    S = LoadSpikes(fc);
    for iC = 1:length(S)
        S{iC} = S{iC}.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
    end
    sd.S = S;
    sd.fc = fc;
    for iC = 1:length(fc)
        [~, sd.fn{iC}] = fileparts(sd.fc{iC});
        sd.fn{iC} = strrep(sd.fn{iC}, '_', '-');
    end
end
%-----------------------
% DD.mat File
%-----------------------
if DD
	DD = fullfile(fd, [SSN '-DD.mat']);
	assert(exist(DD, 'file')==2, 'Cannot find *DD.mat file %s.', DD);
	if exist(DD, 'file')
		load(DD); % process *DD.mat file
		if ~strcmp(sd.ExpKeys.Behavior,'FPT Aging DD');
% 			if datenum(SSN(6:end),'yyyy-mm-dd')<datenum('2011-09-05','yyyy-mm-dd')
				%fix bug in feeders fired and feeder times 2012-03-17 AndyP
% 				[FeedersFired, FeederTimes, ~] = DD6_FixFeedersFired(FeederTimes, FeedersFired, ZoneIn, TotalLaps); %#ok<NODEF>
% 				sd.Coord.SoM_x = 280; % Start of Maze <x,y>
% 				sd.Coord.SoM_y = 209;
% 				sd.Coord.CP_x = 141;  % Choice point <x,y>
% 				sd.Coord.CP_y = 209;
% 				sd.Coord.LF_x = 141;  % Left feeder <x,y>
% 				sd.Coord.LF_y = 337;
% 				sd.Coord.RF_x = 141;  % Right Feeder <x,y>
% 				sd.Coord.RF_y = 81;
% 				sd.InZoneDistance = [77 77 77 77]; %radius of zone [1 2 3 4] (# pixels)
% 			elseif datenum(SSN(6:end),'yyyy-mm-dd')>datenum('2011-09-05','yyyy-mm-dd')
            dateStr = SSN(6:end);
            % datenum problem.
            % dt = 365*Y+12*M+D.
            dt = kludge_datenum(dateStr,'-');
            comp1 = kludge_datenum('2012-12-13','-');
            comp2 = kludge_datenum('2013-03-01','-');
            comp3 = kludge_datenum('2013-06-01','-');
%             InZoneDistance = [60 60 60 60];
            if dt<comp1
				sd.Coord.SoM_x = 480; % Start of Maze <x,y>
				sd.Coord.SoM_y = 195;
				sd.Coord.CP_x = 205;  % Choice point <x,y>
				sd.Coord.CP_y = 200;
				sd.Coord.LF_x = 340;  % Left feeder <x,y>
				sd.Coord.LF_y = 375;
				sd.Coord.RF_x = 320;  % Right Feeder <x,y>
                sd.Coord.RF_y = 30;
% 				sd.InZoneDistance = [60 60 60 60]; %radius of zone [1 2 3 4] (# pixels)
            end
            if dt>=comp1 && dt<comp2
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
            if dt>=comp2 && dt<comp3
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
            if dt>=comp3
                sd.Coord.SoM_x = 217; % Start of Maze <x,y>
				sd.Coord.SoM_y = 250;
				sd.Coord.CP_x = 530;  % Choice point <x,y>
				sd.Coord.CP_y = 251;
				sd.Coord.RF_x = 375;  % Right feeder <x,y>
				sd.Coord.RF_y = 410;
				sd.Coord.LF_x = 375;  % Left Feeder <x,y>
				sd.Coord.LF_y = 75;
%                 sd.InZoneDistance = [60 60 60 60];
            end
            sd.Coord.LD_y = sd.Coord.LF_y;
            sd.Coord.LD_x = sd.Coord.CP_x;
            sd.Coord.RD_x = sd.Coord.CP_x;
            sd.Coord.RD_y = sd.Coord.LF_y;
		else
        end
        
        MazeCoordfn = FindFiles('*-MazeCoord.mat','CheckSubdirs',false);
        if ~isempty(MazeCoordfn)
            load(MazeCoordfn{1});
            sd.Coord = Coord;
%             InZoneDistance(:)=90;
        end
        
		%--------------
		[sd.DelayZone, ~,~] = DD_getWorld(World);
		sd.ZoneDelay = ZoneDelay;
		sd.ZoneIn = ZoneIn;
		sd.World = World;
		sd.TotalLaps = TotalLaps;	
		%--------------
        multiplier = 1e-6;
%         for t = 1 : length(EnteringCPTime)
%             x0 = sd.x.restrict(EnteringCPTime(t)*multiplier,EnteringCPTime(t)*multiplier+1);
%             y0 = sd.y.restrict(EnteringCPTime(t)*multiplier,EnteringCPTime(t)*multiplier+1);
%             if (isempty(x0.data)&&isempty(y0.data))||(all(isnan(x0.data))&&all(isnan(y0.data)));
%                 multiplier = 1;
%             end
%         end
        x0 = x.restrict(EnteringCPTime(1)*multiplier,EnteringCPTime(length(EnteringCPTime))*multiplier);
        y0 = y.restrict(EnteringCPTime(1)*multiplier,EnteringCPTime(length(EnteringCPTime))*multiplier);
        if (length(x0.data)<10&&length(y0.data)<10)||(all(isnan(x0.data))&&all(isnan(y0.data)));
            multiplier = 1;
        end
        
		if exist('EnteringZoneTime','var'); sd.EnteringZoneTime = EnteringZoneTime*multiplier; end 
		if exist('ExitZoneTime','var'); sd.ExitZoneTime = ExitZoneTime*multiplier; end    
		if exist('FeedersFired','var'); sd.FeedersFired=FeedersFired; end
		if exist('FeederTimes','var'); sd.FeederTimes = FeederTimes*multiplier; end 
		if exist('BackwardsTimes','var'); sd.BackwardsTimes=BackwardsTimes*multiplier; end  
		if exist('EnteringSoMTime','var'); sd.EnteringSoMTime=EnteringSoMTime*multiplier; end 
		if exist('ExitingSoMTime','var'); sd.ExitingSoMTime=ExitingSoMTime*multiplier; end 
		if exist('EnteringCPTime','var'); sd.EnteringCPTime=EnteringCPTime.*multiplier; end
		if exist('ExitingCPTime','var'); sd.ExitingCPTime=ExitingCPTime.*multiplier; end
		
		if exist('FeederSkip','var'); sd.FeederSkip=FeederSkip; end
		if exist('SwitchLap','var'); sd.SwitchLap=SwitchLap; end
		sd.InZoneDistance = InZoneDistance;
	else
		warning('FileNotFound: No *DD.mat file found.');
	end
end

if correctTrackingGlitches
    x = sd.x.data;
    tx = sd.x.range;
    y = sd.y.data;
    ty = sd.y.range;

    Vx = diff(x)./diff(tx);
    Vy = diff(y)./diff(ty);
    Ax = diff(Vx)./diff(tx(2:end));
    Ay = diff(Vy)./diff(ty(2:end));
    V = sqrt(Vx.^2+Vy.^2);
    A = sqrt(Ax.^2+Ay.^2);
    idFast(:,1) = [false; V>=Vmax];
    idFast(:,2) = [false;false; A>=Amax];
    idFast = any(idFast,2);
    x0 = x;
    y0 = y;
    x0(idFast) = interp1(tx(~idFast),x(~idFast),tx(idFast));
    y0(idFast) = interp1(ty(~idFast),y(~idFast),ty(idFast));
    
    sd.x = tsd(tx,x0);
    sd.y = tsd(ty,y0);
    sd.old.x = tsd(tx,x);
    sd.old.y = tsd(ty,y);
end

if length(sd.EnteringCPTime)<length(sd.ExitingCPTime)
    sd.EnteringCPTime = [nan sd.EnteringCPTime];
end
if length(sd.EnteringCPTime)>length(sd.ExitingCPTime)
    sd.ExitingCPTime = [sd.ExitingCPTime nan];
end

HEADfn = FindFiles('*-HEADxy.mat','Checksubdirs',false);
if ~isempty(HEADfn)
    disp('Loading head tracking. Final x,y position is not smoothed or interpolated.')
    load(HEADfn{1})
    sd.x = Head.x;
    sd.y = Head.y;
end
disp('Calculating zone times based on smoothed head tracking.')
sd0 = SmoothPath(sd);
xD = sd0.x.data;
yD = sd0.y.data;
t = sd0.x.range;
idnan = isnan(xD)|isnan(yD)|isnan(t);
xD(idnan) = interp1(t(~idnan),xD(~idnan),t(idnan));
yD(idnan) = interp1(t(~idnan),yD(~idnan),t(idnan));
sd0.x = tsd(t,xD);
sd0.y = tsd(t,yD);
if useMP4
    sd = FPTgetZoneTimesVid(SmoothPath(sd),'Coords',sd.Coord);
end


%-----------------------
% Cleanup
%-----------------------
if nargout<1
    save([SSN '-sd.mat'],'sd');
end
if unzippedNVT
    delete(nvt{1})
end
if dirpushed
    popdir;
end