function [PETH,X0D] = tsdPETH(X, t, varargin)

% [PETH,X0D] = tsdPETH(X, t, varargin)
%
% input: 
%        TSD X
%        Event times t
% 
%
% output
%        TSD PETH with t = window, data = peth
%
% parameters:
%   window = [-2 5]
%   dt = 0.5; % time steps
%
% maintains shape of data in PETH
%
% updated ADR 2012-12 

%-------------------
% PARAMETERS
%-------------------
window = [-2 5];
dt = 0.5;
process_varargin(varargin);

%-----------------
nEvents = length(t);
timeWindow = window(1):dt:window(2);
nW = length(timeWindow);

xT = X.range();
xD = X.data();

shape = size(xD); nB = prod(shape(2:end));
%X0 = reshape(xD,size(xD,1), nB);

X0D = nan(nW, nEvents, nB);
%-----------------
for iT = 1:nEvents
	X0D(:, iT, :) = interp1(xT, xD, timeWindow+t(iT))';
end

X0D = reshape(X0D, [nW, nEvents, shape(2:end)]);

PETH = tsd(timeWindow, squeeze(nanmean(X0D,2)));
X0D = tsd(timeWindow, X0D);