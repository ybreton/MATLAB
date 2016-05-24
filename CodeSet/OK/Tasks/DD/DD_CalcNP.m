function [nP] = DD_CalcNP(sd,varargin)
% 2012-02-14 AndyP
% 2012-07-25 AndyP renamed from DDCalcNP
% Calculate the cumulative number of pellets for each lap
% [nP]=DDCalcNP(sd);
% [nP]=DDCalcNP(sd,'nL',200);
%
% INPUTS
% sd - structure, lab-standard 'session data' structure containing fields
% OUTPUTS
% nP nLx1, the number of pellets earned so far
nL=101;
process_varargin(varargin);
%-----------
if nargin==0; sd=DDinit(pwd,'VT1',0,'VT2',0,'Spikes',0,'DD',1); end
%-----------
nP = nan(nL,1);
for iL=1:sd.TotalLaps
	if sd.ZoneIn(iL)==sd.DelayZone; nP(iL,1)=max(sd.World.nPright,sd.World.nPleft);
	elseif sd.ZoneIn(iL)~=sd.DelayZone; nP(iL,1)=min(sd.World.nPright,sd.World.nPleft);
	end
end
%-----------
nP=cumsum(nP,1);
end


