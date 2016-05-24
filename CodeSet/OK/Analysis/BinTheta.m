function [T] = BinTheta(CSC,varargin)
% 2012-05-16 AndyP
% Caller function for InstSig and ThetaCycleBins to return a data structure
% with pertinent analysis details
%
% [T] = BinTheta(CSC,varargin);
%
% INPUT
%
% CSC -  tsd input with units (A.U. by [s]) from a continuously sampled channel (CSC) 
%
% OUTPUT
%
% T   - structure with four fields: 
%       1. Trange (HF and LF filter cutoff),
%       2. FiltOrder, 
%       3. Phase (theta phase [rad]) 4
%       4. trough times [s] of theta troughs
%
Trange=[6 10];
FiltOrder=256;
process_varargin(varargin);
%---------------------
[~, ~, IP,~]=InstSig(CSC,Trange(1),Trange(2),FiltOrder);
tBins = ThetaCycleBins(IP); % find theta troughs
%---------------------
T.Trange=Trange;
T.FiltOrder=FiltOrder;
T.Phase=IP;
T.trough=tBins;
end

