function k = DDfindK(N,D,varargin)
% Function to calculate delay-discounting parameter k based on adjusting
% delay D for number of pellets N.
% k = (N-Ns)./(D*Ns - Ds*N)
% k = DDfindK(N,D)
% where     k       is the delay-discounting rate parameter.
%
%           N       is the number of pellets on the alternate side,
%           D       is the adjusting delay on the alternate side.
%
% OPTIONAL ARGUMENTS:
% ******************
% Ns        (default 1)     number of pellets on standard side.
% Ds        (default 1)     delay to reward on standard side.
%

Ds = 1;
Ns = 1;

k = (N-Ns)./(D*Ns - Ds*N);