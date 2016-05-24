function [PETH,outputS,outputT,outputI]=varWindowSpikePETH(S,t,window,varargin)
% spikePETH(S, t, varargin)
%
% input: 
%        TS S
%        Event times t
%        Event time windows [tStart tEnd]
% 
% output:
%        TSD PETH - tsd with time as window, data as sum by binsize
% 
% if no outputs, plots
%
% parameters:
%   dt = 0.01; % seconds
%   showHist = false
%   showSpikes = false
%
% ADR 2012-01
%
% ADR & JS 2012-11 fixed bug that histc changes its orientation when
% only one spike is in the window

%--------------------------
% parameters
%--------------------------
dt = 0.01;
showSpikes = false;
showHist = false;
if nargout<1
    showSpikes=true;
end
process_varargin(varargin);

%-------------------------
% prep
%--------------------------
nT = length(t);

outputS = [];
outputT = [];
outputI = [];

ISI = tsd(S.range(), [nan; diff(S.range())]);

%---------------------------
% go
%---------------------------
x = min(window(:,1)):dt:max(window(:,2));
H = nan(nT,length(x));
DX = nan(nT,length(x));
for iT = 1:nT
	S0 = data(  S.restrict(t(iT)+window(iT,1), t(iT)+window(iT,2)));
	I0 = data(ISI.restrict(t(iT)+window(iT,1), t(iT)+window(iT,2)));
	outputS = cat(1, outputS, S0-t(iT));
	outputT = cat(1, outputT, repmat(iT, size(S0)));
	outputI = cat(1, outputI, I0);
    x0 = window(iT,1):dt:window(iT,2);
    h0 = histc(x0,x);
    bin0 = find(h0>0);
    H0 = nan(1,length(x));
    H0(bin0) = histc(S0-t(iT),x(bin0));
    H(iT,:) = H0;
    DX0 = nan(1,length(x));
    DX0(bin0) = dt;
    DX(iT,:) = DX0;
end
H = nansum(H,1);
DX = nansum(DX,1);
Rt = H./DX;
PETH = tsd(x', Rt');

if showSpikes
	% display
	figure	
	if ~isempty(outputS)
		scatterplotc(outputS, outputT,1./outputI, 'MarkerSize',5, 'plotchar', '.');
	end
	axis([min(window(:,1)) max(window(:,2)) 0 nT]);
	xlabel('peri-event (sec)');
	ylabel('Event #');	
end

if showHist
	% display
	figure
	bar(PETH.range(), PETH.data());
	set(gca, 'XLim', [window(1) window(2)]);
	xlabel('peri-event (sec)');
	ylabel('Count');	
end