function [H, binsUsed] = HistISI(TS, varargin)

% H = HistISI(TS, parameters)
%  H = HistISI(TS, 'maxLogISI','maxLogISI',5)      for fixed upper limit 10^5 msec (or 100 sec)
%
% INPUTS:
%      TS = a single ts object
%
% OUTPUTS:
%      H = histogram of ISI
%      N = bin centers
%
% PARAMETERS:
%     nBins 500
%     maxLogISI variable
%     minLogISI
%
% If no outputs are given, then plots the figure directly.
%
% Assumes TS is in seconds or timestamps!
%
% ADR 1998
% version L5.3
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m
%
% Status: PROMOTED (Release version)
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.
%
% ADR 2011-12 fixed for new codeset

%--------------------
assert(isa(TS, 'ts'), 'input is not a ts object.');
epsilon = 1e-100;
nBins = 500;
maxLogISI = 6;
minLogISI = -1;
DoPlotYN = true;

extract_varargin;

%--------------------
% Assumes data is passed in in seconds
if ~isempty(TS.data())
	ISI = diff(TS.data()*1000) + epsilon;
	if ~isreal(log10(ISI))
		warning('ISI contains negative differences; log10(ISI) is complex.');
		complexISIs = true;
	else
		complexISIs = false;
	end
	
	H = histc(log10(ISI)', linspace(minLogISI, maxLogISI, nBins));
	binsUsed = logspace(minLogISI,maxLogISI,nBins);
	
	%-------------------
	if nargout == 0 || DoPlotYN
		plot(binsUsed, H);
		if complexISIs
			xlabel('ISI, ms.  WARNING: contains negative components.');
		else
			xlabel('ISI, ms');
		end
		set(gca, 'XScale', 'log', 'XLim', [10^minLogISI 10^maxLogISI]);
		set(gca, 'YTick', max(H));
		
		% draw line at ms
		hold on
		plot([1 1], get(gca, 'YLim'), 'k:')
		plot([2 2], get(gca, 'YLim'), 'r:');
		hold off
	end
end