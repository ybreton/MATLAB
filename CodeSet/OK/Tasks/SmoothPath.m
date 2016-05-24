function sd = SmoothPath(sd, varargin)

% sd = SmoothPath(sd, varargin)
% smooths x and y fields of sd with a gaussian
%
% PARMS 
%   sigma = 0.1; % seconds
%   window = 0.2 % seconds

sigma = 0.1;
window = 0.2;
process_varargin(varargin);

sd.x = sd.x.smooth(sigma, window);
sd.y = sd.y.smooth(sigma, window);