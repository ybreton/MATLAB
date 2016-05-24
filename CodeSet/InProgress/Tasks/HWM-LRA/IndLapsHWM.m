function sd = IndLapsHWM(sd, varargin)

% sd = IndLapsHWM3(sd)
% 
% Calculates entering and exiting times in CP based on a circle centered at
% CP_x, CP_y of radius InZoneDistance, and puts it into sd.
%
% NOTE: this version works from an sd input, not a file
%
% returned sd contains EnteringCP, ExitingCP, L0, L1, nLaps
% data

CP_x = 152; 
CP_y = 294; 
InZoneDistance = 45;
process_varargin(varargin);

% Variables
TS = sd.x.range();
XD = sd.x.data();
YD = sd.y.data();
CP = (XD-CP_x).^2 + (YD-CP_y).^2 <= InZoneDistance^2;
sd.CP = CP;

% Identify Laps
[EnteringCP, ExitingCP] = FindAnyLap(TS(CP), XD(CP));
L0 = [sd.x.starttime(); ExitingCP]; 
L1 = [ExitingCP; sd.x.endtime()];
nLaps = length(L0);
sd.ExitingCP=ExitingCP;
sd.EnteringCP=EnteringCP;
sd.L0=L0;
sd.L1=L1;
sd.nLaps=nLaps;

