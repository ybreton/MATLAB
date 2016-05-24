function [r,b]=autocorrelogram(t,bin,window)
% Returns the spike autocorrelogram of spikes in t, using bins of width bin
% in a window around each spike of +/-window.
% [h,b]=autocorrelogram(t,bin,window)
% [h,b]=autocorrelogram(t,bin)
% [h,b]=autocorrelogram(t)
% where     h           is the autocorrelation ranging from [0,1],
%           b           is the location of bin centers,
%
%           t           is a list of spike times,
%           bin         is the width of each bin (default 1/1000),
%           window      is the width of the window around each spike (default 1).
% Note that at b=0, the value of h is 1, since the spike times are
% correlated with themselves.
%
%
if nargin<3
    window = 1; % default 1sec window
end
if nargin<2
    bin = 1/1000; % default 1msec bin width
end
if min(diff(t))<=bin
    warning('Using wide bins with multiple spikes will skew results')
end

% Binary signal time bins
tlo = [-inf, min(t)-bin/2:bin:max(t)+bin/2];
thi = [min(t)-bin/2:bin:max(t)+bin/2, inf];
% Get binary signal timepoints for the spike times given
id = nan(length(t),1);
parfor iT=1:length(t)
    id(iT) = find(t(iT)>=tlo&t(iT)<thi);
end
% Set those time points to 1, 0 elsewhere
d = zeros(length(tlo),1);
d(id) = 1;
% max number of lags is window/bin width
maxlags = window/bin;
% cross-correlate signal with itself, up to a maximum number of lags
[r,c]=xcorr(d,maxlags,'coeff');
% centers of the lag values can be converted into actual times
b = c*bin;