function sd = DD_zIdPhi(sd, varargin)
% 2013-02-19 AndyP
% 2013-03-19 AndyP, added RobustZ, added checks
% sd = zIdPhi(sd);
% z = zIdPhi(sd, varargin)
% For each lap, calculates integrated absolute change in angular position (IdPhi),
% z-scored IdPhi (zIdPhi), and robustZ-scored IdPhi (RobustZ).
% INPUTS
% sd - standard session data structure, contains fields sd.EnteringCPTime,
% sd.ExitingCPTime that are doubles (size nLx1), where nL is the number of
% laps.
% OUTPUTS
% sd - with the appended fields IdPhi, zIdPhi, RobustZ
% VARARGIN OPTIONS
% dxdtWindow - 1x1 double, maximum window [in sec] for dxdt,dydt, and dphi computations
% dxdtSmoothing - 1x1 double, smoothing [in sec] for dxdt,dydt, and dphi computations 

dxdtWindow = 1;
dxdtSmoothing = 0.33;

process_varargin(varargin);

% checks
fnames = fieldnames(sd);
assert(any(strcmp(fnames,'EnteringCPTime')),'sd must contain field EnteringCPTime');
assert(any(strcmp(fnames,'ExitingCPTime')),'sd must contain field ExitingCPTime');
assert(length(sd.EnteringCPTime)==length(sd.ExitingCPTime),'EnteringCPTime must be the same length as ExitingCPTime');
assert(sum(sd.EnteringCPTime>sd.ExitingCPTime)==0,'mismatched EnteringCPTime/ExitingCPTime pair');

% compute dphi for entire session
dx = dxdt(sd.y, 'window', dxdtWindow, 'postSmoothing',dxdtSmoothing); % compute <x> velocity, dx, using adaptive windowing
dy = dxdt(sd.x, 'window', dxdtWindow, 'postSmoothing',dxdtSmoothing); % compute <y> velocity, dy, using adaptive windowing
phi = tsd(dx.range(), atan2(dy.data(), dx.data())); % compute arctangent of velocity vector, phi
uphi = tsd(phi.range(), unwrap(phi.data())); % unwrap phi, range = (-2pi <= phi <= 2pi)
dphi = dxdt(uphi, 'window', dxdtWindow, 'postSmoothing',dxdtSmoothing); % compute angular acceleration, dphi, the change in angular velocity

nP = sd.TotalLaps;
IdPhi = nan(nPasses,1);
for iL = 1:nP
    dphi0 = dphi.restrict(sd.EnteringCPTime(iL), sd.ExitingCPTime(iL)); % restrict dphi to the choice point of the current lap
    IdPhi(iL) = sum(abs(dphi0.data())); % sum the absolute value of dphi
end

% pack output
sd.IdPhi = IdPhi;
sd.zIdPhi = zscore(IdPhi);
sd.RobustZ = robustZ(IdPhi);



