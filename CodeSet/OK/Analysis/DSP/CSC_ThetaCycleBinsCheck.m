function [tBin,trem] = CSC_ThetaCycleBins2(Tp,P,p2p,varargin)
% 2013-03-14 AndyP
% tBin = CSC_ThetaCycleBins2(sd,Tp,csc);
% Determine end times for theta cycles in Tp. 
%
% INPUTS
% Tp - ts times [s] of theta cycle bins (ie Tp=ThetaCycleBins)
% P  - tsd phase of theta [rad] from Hilbert transform, range of phase [-pi,+pi] (ie from [~,~,P,~]=InstSig...)
% p2p - 1x1 logical, parameter from ThetaCycle bins indicating whether theta cycles were
%       computed from trough-to-trough (false) or from peak-to-peak (true).  (ie. [Tp,p2p]=ThetaCycleBins))
%
% OUTPUTS
% tBin - structure with elements t0, t1 containing matched theta start and end
% times for theta cycles [s]
% trem - structure with elements t0, containing theta cycle bin times that were
% removed from tBin [s]
%
% VARARGIN OPTIONS
% rP = 2x2 cell array, phase range constraints {p2p,nan; ~p2p_min,
% ~p2p_max}.  Constraints that are used depend on whether phase was calculated from
% peak-to-peak or from trough-to-trough.
% ThetaPeriod = 1x2 double, Constraint on period of individual theta cycle [s]
% doPlot = 1x1 logical, optional plot output

rP = {2.8,nan; -0.2,0.2}; % 1x2 cell array  pR = phase constraint {p2p,nan; ~p2p_min, ~p2p_max}
ThetaPeriod = [0.07 0.25];    % 1x1 double [s] minimum length of theta cycle
doPlot = false;   % 1x1 logical, optional plot output

process_varargin(varargin);

tD0 = Tp.data;   % tD0 = start times of theta cycles
t0rem = Tp.data; % t0rem = start times to be removed
nT=length(tD0);  % nT = number of theta cycles
pD = P.data;     % phase from Hilbert transform of theta, -pi<=all(P.data)<=+pi
pT = P.range;    % time [s] from Hilbert transform of theta
dt = P.dt;       % timestep from Hilbert transform of theta

%%% find end time, tD1, phase reversal constraint - line 46
tD1 = nan(length(tD0),1); % tD1 = end time for theta cycles
ok = ones(length(tD0),1); % ok = theta cycles to keep

[~,Indx]=histc(P.range,[P.starttime-P.dt; tD0]); % get index of theta cycle for each datapoint in P
assert(sum(Indx==0)==0,'index out of range');    % check that all indices are in range

for iT=2:nT; % bin 1 contains P data before tD0(1) and is discarded
	if iT~=nT
		Dend = pD(Indx==iT+1); % get phase from current point to the beginning of the next theta cycle
		Tend = pT(Indx==iT+1); % get times from current point to the beginning of the next theta cycle
		tempD = cat(1,pD(Indx==iT),Dend(1)); % append first data point from next theta cycle
		tempT = cat(1,pT(Indx==iT),Tend(1)); % append first data point from next theta cycle
	else
		tempD = []; % no more data left
		tempT = []; % no more data left 
	end
		% get second half of phase
	if ~p2p
		D = find(tempD==min(tempD)); % find minimum in theta phase, -pi, at theta trough
	else
		D = find(tempD==max(tempD)); % find peak in theta phase, +pi, at theta trough 
	end
	remT = tempT(D:end); % remainder of theta cycle
	remD = tempD(D:end); % remainder of theta cycle
	% Find phase change point, keep theta cycles if:
	% 1) a change point is found,
	% 2) only one change point is found,
	% 3) the change occurs within ThetaPeriod
	if ~p2p
		tempt1 = remT(remD>0); % keep phase > 0 after minimum in theta phase
	else
		tempt1 = remT(remD<0); % keep phase < 0 after maximum in theta phase
	end
	keep0 = ~isempty(tempt1) && nansum(diff(tempD)<-1)==1; % only one phase reversal should occur each theta cycle
	if keep0 % each theta cycle has only one phase reversal
		if iT~=nT && ((tD0(iT)-dt)-tD0(iT-1)) < ThetaPeriod(2); % theta is continuous, if next theta cycle is within one theta bin, use it as the end of the theta cycle
			tD1(iT-1)=tD0(iT)-dt; % use last point before next theta cycle as the end time for the current theta cycle
		else
			tD1(iT-1)=tempt1(end-1); % theta is not continuous, use the point calculated in tempt1 as the end of the theta cycle
		end
	else
		tD0(iT-1)=nan; % discard current theta cycle
		tD1(iT-1)=nan; % discard current theta cycle
		ok(iT-1)=0;
		%fprintf('%d \n',iT); % check number of cycles removed so far
	end
end
%fprintf('%d \n',nansum(ok)); % check number of cycles removed so far
ok = (tD1-tD0)>ThetaPeriod(1) & (tD1-tD0)<ThetaPeriod(2);
%fprintf('%d \n',nansum(ok)); % check final number of theta cycles removed
% phase constraint
if ~p2p % trough-to-trough
	ok = ok & P.data(tD0)>rP{1,1} & P.data(tD1)>rP{1,1}; % check if tD1 is at phase ~=pi where theta is at its trough
else % peak-to-peak
	ok = ok & P.data(tD0)>rP{2,1} & P.data(tD0)<rP{2,2} & P.data(tD1)>rP{2,1} & P.data(tD1)<rP{2,2}; % check if tD1 is at phase ~=0, where theta is at its peak
end
%fprintf('%d \n',nansum(ok));
% group, remove NaNs
tD0(isnan(tD0) | ~ok)=[];
tD1(isnan(tD1) | ~ok)=[];
t0rem(ok)=[];

% package output
tBin.t0 = ts(tD0);
tBin.t1 = ts(tD1);
trem.t0 = ts(t0rem);

% optional plot output
if doPlot
	figure(1); clf; %#ok<UNRCH>
	%%% Plot Theta Phase (black line) vs time.  Plot start time of theta
	%%% cycle bins (blue dots) and endtime (red dots).  Plot removed theta
	%%% cycle bins (cyan circles).
	subplot(1,3,1); hold on;
	plot(P.range,P.data,'k');
	plot(tBin.t0.data,P.data(tBin.t0.data),'b.','markersize',20);
	plot(tBin.t1.data,P.data(tBin.t1.data),'r.','markersize',20);
	plot(trem.t0.data,P.data(trem.t0.data),'co','markersize',5);
	xlabel('time (s)','fontsize',24);
	ylabel('phase (rad)','fontsize',24);
	set(gca,'fontsize',24);
	legend('phase','start','stop','removed');
	title('Phase vs Time','fontsize',36);
	h = zoom; setAxesZoomMotion(h,gca,'vertical');
	%%% Histogram of Phase [rad] at Start Time
	subplot(1,3,2); hold on;
	hist(P.data(tBin.t0.data),1000);
	title('Histogram of Phase at Start Time, t0','fontsize',36);
	%%% Histogram of Theta Period [s]
	subplot(1,3,3); hold on;
	hist(tBin.t1.data-tBin.t0.data,1000);
	title('Histogram of Cycle Period (t1-t0)','fontsize',36);
end
end