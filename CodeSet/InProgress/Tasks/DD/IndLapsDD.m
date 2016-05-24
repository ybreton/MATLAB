function sd = IndLapsDD(sd, varargin)

% sd = IndLapsDD(sd)
% 
% Calculates entering and exiting times in CP based on vt2
% returned sd contains EnteringCP, ExitingCP, L0, L1, nLaps
% data

% Variables
TS = sd.x2.range();
XD = sd.x2.data();
YD = sd.y2.data();
CP = ~isnan(XD) & ~isnan(YD);
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

