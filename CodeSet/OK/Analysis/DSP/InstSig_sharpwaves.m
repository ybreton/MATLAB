function [IF_sharpwaves, IA_sharpwaves, IP_sharpwaves, CSC0_sharpwaves]=InstSig_sharpwaves(CSC,varargin)
%2012-05-16 AndyP
%Bandpass filters signal then takes the Hilbert transform
% [IF, IA, IP, CSC0]=InstSig_sharpwaves(CSC);
% 
% calls InstSig with 
%   LFcutoff = 140
%   HFcutoff = 200;
%   FiltOrder = 256;

LFcutoff = 140; %[Hz]
HFcutoff = 200; %[Hz]
FiltOrder = 256;
process_varargin(varargin);
assert(isa(CSC,'tsd'),'input CSC must be a tsd object');
[IF_sharpwaves , IA_sharpwaves , IP_sharpwaves, CSC0_sharpwaves ]=InstSig(CSC,LFcutoff,HFcutoff,FiltOrder);
end




