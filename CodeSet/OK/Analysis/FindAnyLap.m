function [Lstart, Lend] = FindAnyLap(ts,x, varargin)
% 2011-04-13 AndyP  This function finds laps on the DD task based on
% restrictions in the VT data.  Function is based on a similar version
% written for the MT task.
% x input are the x coordinates of VT2
% Lstart, Lend are the output 

splitTime = 2; % sec.  Gives the minimum time between the last point on Lap X and the first point on lap X+1
RemoveNans = true;
process_varargin(varargin);

if RemoveNans
	NaNsCut = isnan(x);
	if any(NaNsCut)
		%disp('Removing NaNs from VT2');
		ts(isnan(x)) = [];
		x(isnan(x))=[]; %#ok<NASGU>
	end
end

d = diff(ts); %takes the difference between consecutive datapoints
L = find(d > splitTime);
L = [ts(1); ts(L); ts(end)]; %#ok<FNDSB>

nLaps = length(L)-1;
for iL = 1:nLaps
	xr0 = ts(ts > L(iL));
	Lstart(iL) = xr0(1);
	[~,ix] = max(ts(ts <= L(iL+1)));
	Lend(iL) = ts(ix);
end
