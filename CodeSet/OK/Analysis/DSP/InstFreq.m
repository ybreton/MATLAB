function [IF, IA, IP]=InstFreq(IMF)
% Takes the hilbert transform of the data to calculate instantaneous
% angular frequency. NOTE: it is recomended that some sort of decomposition
% be done before using this function
%
% IF=InstFreq(IMF)
% [IF,IA]=InstFreq(IMF)
% [IF,IA,IP]=InstFreq(IMF)
%
%INPUTS: 
% IMF input data (opperates along columns: N_timesteps x N_IMF) 
%
%OUTPUT:
% IF  instantaneous frequency (Angular Frequency Hz) 
% IA  instantaneous amplitude (power)
% IP  instantaneous phase
%
% See also: help HILBERT INSTSIG

%JCJ 4 June 2003
assert(isa(IMF,'tsd'),'first input CSC must be a tsd object');
dt = IMF.dt();
IMF=IMF.data;
HT=hilbert(IMF);
IP=atan2(imag(HT),real(HT));
IF=(diff(unwrap(IP,[],1),1,1)/dt)./(2.*pi); % in degrees

if nargout >1
    IA=abs(HT).^2;
end
