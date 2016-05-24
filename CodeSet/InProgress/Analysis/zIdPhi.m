function sd = zIdPhi(sd, varargin)

% z = zIdPhi(sd, varargin)
%
% Calculates zIdPhi
% Assumes sd contains sd.EnteringCPTime and sd.ExitingCPTime variables

dxdtWindow = 0.33;
dxdtSmoothing = 0.33;

process_varargin(varargin);

[ dx ] = dxdt(sd.y, 'window', dxdtWindow, 'postSmoothing',dxdtSmoothing);
[ dy ] = dxdt(sd.x, 'window', dxdtWindow, 'postSmoothing',dxdtSmoothing);

phi = tsd(dx.range(), atan2(dy.data(), dx.data()));
uphi = tsd(phi.range(), unwrap(phi.data()));
dphi = dxdt(uphi, 'window', dxdtWindow, 'postSmoothing',dxdtSmoothing);

nPasses = length(sd.EnteringCPTime);

IdPhi = nan(nPasses,1);

for iL = 1:nPasses
    dphi0 = dphi.restrict(sd.EnteringCPTime(iL), sd.ExitingCPTime(iL));
    IdPhi(iL) = sum(abs(dphi0.data()));
end

sd.IdPhi = IdPhi;
sd.zIdPhi = zscore(IdPhi);



