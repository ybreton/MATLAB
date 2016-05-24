function [tBins,p2p] = ThetaCycleBins(thetaPhase,varargin)

%returns times of peaks (p2p=peak2peak=1) or troughs (p2p=0) of theta
%cycles detected from a tsd of theta phase. Assumes theta phase tsd is
%derived from the Hilbert transform (that is, from trough:trough phase
%spans -pi:pi. If phase is not assigned in this way, results will NOT be
%correct.
%
% IN:
% thetaPhase - tsd of theta phase (in radians), derived from Hilbert transform
% OUT:
% tBins - tsd of times of peaks (or troughs) of theta
% p2p   - 1x1 logical, if true tBins are peak times, if false tBins are
% trough times
%amw - 15 Feb 2011
%2012-05-16 AndyP tsd output
%2013-03-14 AndyP p2p output

p2p = true; %cycles defined from peak:peak; if false, from trough:trough
process_varargin(varargin);

rPhase = thetaPhase.range;

if p2p;
    [~,~,~,imin] = extrema(circ_dist(abs(thetaPhase.data),zeros(length(thetaPhase.data),1))); 
    tBins = sort(rPhase(imin));   
else  
    [~,imax] = extrema(thetaPhase.data); %#ok<UNRCH>
    tBins = sort(rPhase(imax)); 
end

tBins = ts(tBins);

end



