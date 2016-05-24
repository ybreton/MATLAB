function [IF_delta, IA_delta, IP_delta, CSC0_delta]=InstSig_delta(CSC, varargin)
%2012-05-16 AndyP
%Bandpass filters signal then takes the Hilbert transform
% [IF, IA, IP, CSC0]=InstSig_delta(CSC);
% 
% calls InstSig with 
%   LFcutoff = 2;
%   HFcutoff = 4;
%   FiltOrder = 256;

LFcutoff = 2; %[Hz]
HFcutoff = 4; %[Hz]
FiltOrder = 256;
process_varargin(varargin);
assert(isa(CSC,'tsd'),'input CSC must be a tsd object');
[IF_delta, IA_delta, IP_delta, CSC0_delta]=InstSig(CSC,LFcutoff,HFcutoff,FiltOrder);
end




