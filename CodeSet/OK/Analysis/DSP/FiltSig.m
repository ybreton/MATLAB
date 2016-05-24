function [CSC0]=FiltSig(CSC,LFcutoff,HFcutoff,FiltOrder)
%2012-05-16 AndyP
%Bandpass filter a tsd object (eg, a CSC channel) with a zero-phase digital
%filter
%[CSC0]==FiltSig(CSC,LFcutoff,HFcutoff,FiltOrder);
% INPUTS
% CSC - tsd, range in [s], data in [A.U.], data from a continuously sampled channel (csc)
% LFcutoff - 1x1 double, [Hz], low-frequency cutoff for FIR filter
% HFcutoff - 1x1 double, [Hz], high-frequency cutoff for FIR filter
% FiltOrder - 1x1 double, FIR filter order
% OUTPUTS
% CS0 - filtered CSC signal
assert(isa(CSC,'tsd'),'first input CSC must be a tsd object');                       
Filter = fir1(FiltOrder,[LFcutoff/(1/CSC.dt()/2) HFcutoff/(1/CSC.dt()/2)],'bandpass');   % Construct bandpass window-based FIR filter.
CSC0 = filtfilt(Filter,1,CSC.data);
CSC0=tsd(CSC.range,CSC0);
end







