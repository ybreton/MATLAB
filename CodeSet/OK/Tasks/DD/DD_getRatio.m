function Ratio = DD_getRatio(sd,varargin)
% 2012-03-04 AndyP
% 2012-07-25 AndyP renamed from getDDRatio
% get the larger number of pellets for the session
% Ratio = DD_getRatio(sd);
% Ratio = DD_getRatio(sd,'nL',200);
%
% INPUTS
% sd - structure, lab-standard 'session data' structure containing fields
% OUTPUTS
% Ratio nLx1, the larger number of pellets, (nL = number of laps in the session) 
nL = 101;
process_varargin(varargin);
Ratio = nan(nL,1);
Ratio(1:sd.TotalLaps,1) = repmat(max(sd.World.nPright,sd.World.nPleft), sd.TotalLaps,1);
end