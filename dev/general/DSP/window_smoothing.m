function yy = window_smoothing(y,smoothingWindow,varargin)
% Uses a smoothingWindow to smooth y in overlapping windows.
% yy = window_smoothing(y,smoothingWindow)
% where         yy              is a set of smoothed data,
%               
%               y               is a set of data to smooth,
%               smoothingWindow is a 1 x nBins set of weighting
%                               coefficients for smoothing
% If smoothingWindow is an even number of nBins long, window_smoothing will
% interpolate it to nBins+1.
% 
process_varargin(varargin);

bin = length(smoothingWindow(:));
if mod(bin,2)==0
    hw = bin/2;
    smoothingWindow = [smoothingWindow(1:hw); nanmean(smoothingWindow(hw:hw+1)); smoothingWindow(hw+1:end)];
    bin = length(smoothingWindow(:));
end

hw = (bin-1)/2;
yy = nan(size(y));
for iT=1:numel(y)
    t1 = max(1,iT-hw);
    t2 = min(iT+hw,length(y));
    % There are dt1 below iT in the window and dt2 above it.
    dt1 = iT-t1;
    dt2 = t2-iT;
    % The peak of w should be at iT.
    w1 = hw+1-dt1;
    w2 = hw+1+dt2;
    
    y0 = y(t1:t2);
    w0 = smoothingWindow(w1:w2);
    sw = nansum(w0);
    yy(iT) = (y0(:)'*w0(:))/sw;
end

if nargout<1
    subplot(2,1,1)
    bar(yy)
    ylabel(sprintf('Smoothed with %.0f-bin windows',bin))
    subplot(2,1,2)
    plot(linspace(-(bin-1)/2,(bin-1)/2,bin),smoothingWindow);
    ylabel(sprintf('Smoothing window of %.0f bins',bin))
end