function [A,B,C] = LoadVT_lumrg_ANTI_restricted(fn, xm, xM, ym, yM) 
%
%
%2011/02/11 Modified by Nate J. Powell and Andy Papale.  
% This function loads all video tracker data EXCEPT a box around some area in the camera's
% field of view.  The goal of this funciton is to remove suprious pixels
%('ghost pixels') or reflections from the tracking data.
%
% [TS] = LoadVT(fn) : ts-obj
% [X,Y] = LoadVT(fn) : 2 tsd-obj
% [X,Y,PHI] = LoadVT(fn): 3 tsd-obj%
% fn = VT file
% xm = xminimum
% xM = xMaximum
% ym = yminimum
% yM = yMaximum
%
% X,Y returned in camera coordinates
% PHI returned in radians
% NOTE: timestamps returned are in seconds!
%
% Status: PROMOTED
% ADR: 2001
% Version v1.0

A = []; B = []; C = []; %#ok<NASGU>

switch nargout
case 1 % TS only
	TS = LoadVT0_lumrg_ANTI_restricted(fn, xm, xM, ym, yM);
	A = ts(TS'/1e6);
case 2 % X,Y only
	[TS,X,Y] = LoadVT0_lumrg_ANTI_restricted(fn, xm, xM, ym, yM);
	A = tsd(TS'/1e6,X');
	B = tsd(TS'/1e6,Y');
case 3 % X,Y,PHI
	[TS,X,Y,PHI] = LoadVT0_lumrg_ANTI_restricted(fn, xm, xM, ym, yM);
	A = tsd(TS'/1e6,X');
	B = tsd(TS'/1e6,Y');
	C = tsd(TS'/1e6,PHI');
otherwise
	error('Invalid function call.');
end