function ang = zero2twoPiAngle(negPi2Pi,varargin)
% Converts an angle that ranges [-pi, pi] to one that ranges [0, 2*pi].
% ang = zero2twoPiAngle(negPi2Pi,varargin)
% where     ang         is an angle that ranges between [0, 2*pi]
%
%           negPi2Pi    is an angle that ranges between [-pi, pi]
%
% OPTIONAL ARGUMENTS:
% ******************
% direction     (default +1, 'ccw')     direction of full circle.
%                                       enter -1 or 'cw' for clockwise.
%
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

ang = direction*negPi2Pi;
ang(ang<0) = 2*pi+ang(ang<0);
