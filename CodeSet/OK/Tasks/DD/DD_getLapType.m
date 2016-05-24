function [TA,UpDn,TAratio] = DD_getLapType(sd,varargin)

% 2012-02-24 AndyP
% 2012-07-25 AndyP renamed from getDDlapType
% 2013-01-21 AndyP corrected function call to DD_getDelays
% Classify adjustment laps or alternation laps on the DD task.  Adjustment laps are
% repeated laps to the same side (LL or RR).  Alternation laps are consecutive laps to
% opposite sides (LR or RL).
%
% [TA,UpDn,TAratio]=DD_getLapType(sd,varargin);
% [TA,UpDn,TAratio]=DD_getLapType(sd,'type',1);
% type==1 classify by lap, type==2 classify by delay
% [TA,UpDn,TAratio]=DD_getLapType(sd,'TA','T');
% if TA='A', get A/(T+A), if TA='T', get T=T/(T+A)
% [TA,UpDn,TAratio]=DD_getLapType(sd,'nW',5);
% nW is the number of laps in the sliding window.
% [TA,UpDn,TAratio]=DD_getLapType(sd,'nL',100);
% nL is the matrix size.  Set to the maximum lap number expected.  Extra
% slots will be filled with nans.
% [TA,UpDn,TAratio]=DD_getLapType(sd,'Dadj',Dadj);
% Dadj = 1 x nL size matrix of the adjusting delay for each lap, where nL
% is the maximum matrix size.  Extra slots should be filled with nans.
% The default is to get Dadj from a separate function GetDDdelays;
%%%  INPUT %%%
% sd = DDinit;  standard session data format
%%%  OUTPUT %%%
% 1.   TA     nL x 1 double    0=alternation lap, 1=titration lap
% 2.   UpDn   nL x 1 double    0=alternation lap, 1=upward titration lap,
% -1=downward titration lap, 2=titration lap where adjusting delay is floored at 1s and is not
% changing
% 3.   TAratio nL x 1 double   ratio of adjustment to total laps OR ratio of alternation to total laps.  The OR conditional is set by the 'TA' parameter


type = 1; % type==1 classify by pairs of laps, type==2 classify by delay on every third lap
nL=101;
nW=1; % window length
TorA = 'T'; % A=A/(T+A),   T=T/(T+A)
Dadj = [];
process_varargin(varargin);

%------------------
TA=nan(nL,1);
UpDn=nan(nL,1);
TAratio=nan(nL,1);
minLaps = round(2.*nW);

%------------------
if type==1; startingLap=2;
elseif type==2;
	startingLap=3;
else error('unknown type');
end

if isempty(Dadj); [~,Dadj]=DD_getDelays(sd,'nL',nL); end

for iL=startingLap:sd.TotalLaps;
	%------------------
	switch type
		case 1 %pairs of laps
			if sd.ZoneIn(iL)==sd.ZoneIn(iL-1);
				TA(iL,1)=1; %Titration
				if Dadj(iL)>Dadj(iL-1); UpDn(iL,1)=1;
				elseif Dadj(iL)<Dadj(iL-1); UpDn(iL,1)=-1;
				else UpDn(iL,1)=2; %floored delay
				end
			elseif sd.ZoneIn(iL)~=sd.ZoneIn(iL-1);
				TA(iL,1)=0; %Alternation
				UpDn(iL,1)=0;
			else error('unknown lap');
			end
		case 2 %delay on every other lap
			if sd.ZoneDelay(iL)==sd.ZoneDelay(iL-2);
				TA(iL,1)=0; %Alternation
				UpDn(iL,1)=0;
			elseif sd.ZoneDelay(iL)~=sd.ZoneDelay(iL-2);
				TA(iL,1)=1; %Titration
				if Dadj(iL)>Dadj(iL-1); UpDn(iL,1)=1;
				elseif Dadj(iL)<Dadj(iL-1); UpDn(iL,1)=-1;
				else UpDn(iL,1)=2; %floored delay
				end
			else error('unknown lap');
			end
		otherwise, error('unknown type');
	end
end
% Get TA ratio
if length(TA(~isnan(TA)))>minLaps;
	for iL=nW:nW:nL;
		startLap = iL - nW+1;
		endLap = iL;
		nT = nansum(TA(startLap:endLap,1)==1);
		nA = nansum(TA(startLap:endLap,1)==0);
		if strcmp(TorA,'T');
			TAratio(iL,1) = nT./(nT+nA);
		elseif strcmp(TorA,'A');
			TAratio(iL,1) = nA./(nT+nA);
		else
			error('unset parameter "TorA"');
		end
	end
else
	[~,SSN,~]=fileparts(pwd);
	fprintf('%s too few laps to complete analysis.  Total number of laps must be greater than round(2.*nW) \n',SSN);
end
end

