function [Delays,Dadj] = DD_getDelays(sd, varargin)
% 2011-05-06 AEP
% 2012-07-25 AndyP renamed from getDDdelays
%  Get the adjusted delay on each lap
%  [Delays,Dadj] = DD_getDelays(sd, varargin);
%  [Delays,Dadj] = DD_getDelays(sd, 'nL',100);
%  nL is the matrix size.  Set to the maximum lap number expected.  Extra
%  slots will be filled with nans.
%  [Delays,Dadj] = DD_getDelays(sd, 'DelayUpStep',+1);
%  DelayUpStep sets the number of seconds that the adjusting delay is
%  increased
%  DelayDnStep sets the number of seconds that the adjusting delay is
%  decreased
%  INPUTS
%  sd - standard session data format
%  OUTPUTS
%  1.  Delays   nL x 1 double     the delay experienced by the rat on each lap (larger-later OR smaller-sooner)
%  2.  Dadj     nL x 1 double     the adjusting delay on each lap (always larger-later)

nL = 101;
DelayUpStep=1;
DelayDnStep=-1;
process_varargin(varargin);
%------------------
if nargin==0; sd = DDinit('VT1',0,'VT2',0,'Spikes',0,'DD',1); end
%------------------
Dadj = nan(nL,1);
Delays = nan(nL,1);
Delays(1:sd.TotalLaps,1)=sd.ZoneDelay;
%------------------
firstDelayed = find(sd.ZoneIn==sd.DelayZone, 1, 'first'); %find first delayed lap
if isempty(firstDelayed); ExcludeSessionFlag=1; [~,SSN,~]=fileparts(pwd); fprintf('%s delay side not sampled \n',SSN); else ExcludeSessionFlag=0; end
%------------------
if ExcludeSessionFlag ==0;
	Dadj(1:firstDelayed) = sd.ZoneDelay(firstDelayed); %set delay = starting delay until the delayed side is sampled

	for iD = (firstDelayed+1):sd.TotalLaps
		if sd.ZoneIn(iD)==sd.DelayZone; %delayed side sampled
			Dadj(iD) = sd.ZoneDelay(iD);
			if sd.ZoneDelay(iD) ~=Dadj(iD-1)+DelayUpStep && Dadj(iD-1)~=1; error('wrong delay calculated.'); end %check
		elseif Dadj(iD-1)~=1; %downward titration (DelayDnStep is negative)
			Dadj(iD) = Dadj(iD-1)+DelayDnStep;
		else %the delay is floored and is not changing
			Dadj(iD)=1;
		end
	end

end
end

