function Align = CheckAlignment(VT1,varargin)
% 2012-05-27 AndyP
% 2013-04-21 AndyP, changed output structure
% Align = CheckAlignment();
% Align = CheckAlignment(varargin);
% perform maze alignment to video tracker.  Alignment accomplished through tone feedback, the faster the beep, the
% closer to the goal.  Align zones 1,2,3,4 in that order.  Then align points 1,2,3,4 in VT2.
% INPUTS
% VT1, n x 1 cell array, n = number of zones to align
% OUTPUTS
% Align - structure with elements:
%         1) tolerance (see varargin options)
%         2) protocol (see varargin options)
%         2) time - datevec output converted to char array, time this
%         function was run
%         2) funRun - dbstack output, function that generated this structure 
%         3) VT1_AlignedPoints (see varargin options VT1)
%         4) VT2_AlignedPoints (see varargin options VT2)
%         5) VT1 - measured coordinates in VT1
%         6) VT2 - measured coordinates in VT2
% 
% VARARGIN OPTIONS
% tolerance = 1x1 double, max distance in pixels between actual and
% expected zone location
% protocol = char array, should match protocol in Keys file
% VT2, n x 1 cell array, n = number of points in VT2 to align

tolerance = 5; %max distance (in pixels) permitted between actual and expected zone location
protocol = '';
% VT2 field of view
VT2 = {};

extract_varargin;

ConnectToCheetah('CheckAlignment');

[funRun,~]=dbstack;
[y, m, d, h, mn, s] = datevec(now);
time0 = sprintf('Date: %d/%d/%d   Time: %d:%d:%2.3f\n', m, d, y, h, mn, s);

% VT1 alignment
for iAlign=1:length(Alignones);
    x0 = VT1{iAlign}(1);
    y0 = VT1{iAlign}(2);
    [x,y]=AlignIt(x0,y0,tolerance,'VT1');
    Align.VT1{1,iAlign}=[x,y];
end
fprintf('VT1 alignment complete \n');
pause(0.5);

% VT2 alignment
if ~isempty(VT2)
    for iAlign=1:length(VT2);
        x0 = VT2{1,iAlign}(1);
        y0 = VT2{1,iAlign}(2);
        [x(1),y(1)]=AlignIt(x0,y0,tolerance.*3,'VT2');
        
        % get VT2 coordinates in VT1
        ts = nan;
        while ~isnan(ts);
            [x(2),y(2),ts]=GetPositionFromCheetah('VTobject','VT1');
        end
        PlayTones(2.*1000,1); % 1000Hz frequency
        Align.VT2{3,iAlign}=[x(1),y(1)];
        Align.VT2_to_VT1{2,iAlign}=[x(2),y(2)];
    end
    fprintf('VT2 alignment complete \n');
end

homedir = 'C:\CheetahData';
cd(homedir);

% append parameters to Output
Align.tolerance = tolerance;
Align.protocol = protocol;
Align.funRun = funRun;
Align.time = time0;
Align.VT1_AlignedPoints = VT1;
Align.VT2_AlignedPoints = VT2;

save('CheckAlignment','Align');
DisconnectFromCheetah;
end


function [x,y]=AlignIt(x0,y0,tolerance,obj)
ts = []; x=[]; y=[];
BackupTs=ts; BackupX=x; BackupY=y;
freq = 500; % [Hz] frequency of audible beeps
aligned=false;
while ~aligned;
    if ~isnan(ts); BackupTs = ts; BackupX=x; BackupY=y; end
    [x,y,ts]=GetPositionFromCheetah('VTobject',obj);
    if isnan(ts); ts=BackupTs; end
    if isnan(x); x=BackupX; end
    if isnan(y); y=BackupY; end
    
    d = sqrt((x-x0).^2+(y-y0).^2); % get distance from LED to zone
    if ~isempty(d) | ~isnan(d) %#ok<OR2>
        if d <= tolerance;
            aligned=true;
            PlayTones(2.*freq,1); % good job, you found the goal!
        else
            dur = d./2000; % duration  of beep inversely proportional to distance from goal
            PlayTones(freq,dur); % tone feedback, the faster the beep, the closer to the goal
        end
    end
end
end

