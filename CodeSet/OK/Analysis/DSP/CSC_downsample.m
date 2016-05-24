function [ csc1 ] = CSC_downsample(csc, varargin)
% 2012-06-14 AndyP
% downsample a csc by an integer factor
% [csc1] = CSC_downsample(csc);
% [csc1] = CSC_downsample(csc,'factor',5);
%
% INPUTS
% csc - a continuously sampled channel (csc)
% OUTPUTS
% csc1 
factor = 5;
process_varargin(varargin);
assert(factor<13, 'downsample factor is too large');
TS=csc.T;
WV=csc.D;
WV=decimate(WV(2:end-1),factor,'fir');
TS =TS(2:factor:end-1);
csc1 = tsd(TS,WV);
end

