function [PETH,X0D] = tsdPETH0(X, t, varargin)

% [PETH,X0D] = tsdPETH0(X, t, varargin)
%
% input: 
%        TSD X
%        Event times t
% 
% output
%        TSD PETH with t = window, data = peth
%
% parameters:
%   window = number of elements to add on each side [-10 +10]
%   dt = no longer changeable
%
% maintains shape of data in PETH
% only works with 1D tsds
%
% updated ADR 2013-12 

%-------------------
% PARAMETERS
%-------------------
window = -100:100;
process_varargin(varargin);

%-----------------
xT = X.range();
xD = X.data();

assert(size(xD,2)==1, 'Only works with 1D data.');

nEvents = length(t);
nW = length(window);
nD = length(xD);

X0D = nan(nW, nEvents);

%-----------------
for iT = 1:nEvents    
    waitbar(iT/nEvents);
    iX = find(xT > t(iT), 1, 'first');
    if iX + window(1) > 0 && iX + window(2) < nD
        X0D(:, iT) = xD(iX+window);
    end       
end

PETH = squeeze(nanmean(X0D,2));