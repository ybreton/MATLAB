function [ PhaseW ] = DD_getPhaseSW2(sd,varargin )
% 2014-01-29 YAB window slides from 1 through nL rather than binning in nW.
% 2012-02-20 AndyP
% 2012-07-25 AndyP renamed from getDDphaseSW
% 2013-01-21 AndyP corrected function call to DD_getLapType
% Classify behavioral phases on the DD task with a sliding window analysis.
% 1=investigation, 2=titration, 3=exploitation
% [PhaseW] = DD_getPhaseSW(sd,varargin);
% [PhaseW] = DD_getPhaseSW(sd,'TA',TA);
% TA is a 1x x nL size matrix where 1=adjustment lap and 0=alternation lap.
%  Extra slots should be filled with nans.  The default is to get TA from a
%  separate function GetDDlaptype;
% [PhaseW] = DD_getPhaseSW(sd,'nW',5);
% nW is the number of laps in the sliding window.
% [PhaseW] = DD_getPhaseSW(sd,'nL',100);
% nL is the matrix size.  Set to the maximum lap number expected.  Extra
% slots will be filled with nans.
% [PhaseW] = DD_getPhaseSW(sd,'thr',1/5);
% 'thr' sets the threshold for classifying a titration phase.  If thr=1/5,
% if there are greater than 1/5 adjustment laps in a window, all 5 laps in
% the window will be classified as part of a titration phase.
% [PhaseW] = DD_getPhaseSW(sd,'maxI',30);
% 'maxI' sets the maximum lap that can be classified as an 'investigation'
% lap.
%%%  INPUT %%%  
% sd = DDinit;  standard session data format
%%%  OUTPUT %%%   
% PhaseW   nL x 1 double     the behavioral phase classification for each lap, where 1=investigation,
% 2=titration, 3=exploitation

TA =[];
nW = 5;
nL = 101;
thr = 1/nW;
maxI=30;
process_varargin(varargin);
%------------------
PhaseW = nan(nL,1);
if isempty(TA); [TA,UpDn,~] = DD_getLapType(sd,'type',1,'TorA','T','nW',nW,'nL',nL);end
first = min(find(~isnan(TA)));
binW = (nW-1)/2;
binC = first+binW:nL;
binLo = binC-binW;
binLo = min(max(1,binLo),nL);
binHi = binC+binW;
binHi = min(max(1,binHi),nL);

	for iL=1:length(binC) % slide through each window
		W=TA(binLo(iL):binHi(iL),1); %get window
        if sum(double(~isnan(W)))==nW
            if nansum(W)/sum(W)>thr & UpDn(iL)~=2; %#ok<AND2> exclude laps where the adjusting delay is floored and is not changing
                PhaseW(binC(iL),1)=2; % classify titration phase
            else
                PhaseW(binC(iL),1)=3; % classify exploitation phase
            end
        else
            PhaseW(binC(iL),1) = nan;
        end
	end
	T1 = min(find(PhaseW==2,1,'first'), maxI);
    if T1>=first+binW+1
        PhaseW(first+binW:T1-1)=1; % classify investigation phase
    end


