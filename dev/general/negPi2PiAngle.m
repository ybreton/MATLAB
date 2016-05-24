function negPi2Pi = negPi2PiAngle(ang,varargin)
% Converts an angle that ranges [0, 2*pi] to one that ranges [-pi, pi].
% negPi2Pi = negPi2PiAngle(ang)
% where     negPi2Pi    is an angle that ranges between [-pi, pi]
%
%           ang         is an angle that ranges between [0, 2*pi]
%
% OPTIONAL ARGUMENTS:
% ******************
% direction     (default +1, 'ccw')     direction of full circle for ang.
%                                       enter -1 or 'cw' for clockwise.
%

direction = 1;
process_varargin(varargin);
if ischar(direction)
    directionStr = direction;
    direction = 0;
    if strcmpi(directionStr,'cw')
        direction = -1;
    elseif strcmpi(directionStr,'ccw')
        direction = 1;
    else
        error('Valid direction strings are ''cw'' and ''ccw''.')
    end
end
direction = sign(direction);

negPi2Pi = ang;
negPi2Pi(ang>pi) = -(2*pi-ang(ang>pi));
negPi2Pi = negPi2Pi*direction;