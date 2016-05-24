function dphi = angularVel(x,y,varargin)
% gets the angular velocity at each xy.
dxdtSmoothing = 0.1;
dxdtWindow = 0.5;
process_varargin(varargin);

[ dx ] = dxdt(x, 'window', dxdtWindow, 'postSmoothing',dxdtSmoothing);
[ dy ] = dxdt(y, 'window', dxdtWindow, 'postSmoothing',dxdtSmoothing);

phi = tsd(dx.range(), atan2(dy.data(), dx.data()));
uphi = tsd(phi.range(), unwrap(phi.data()));
dphi = dxdt(uphi, 'window', dxdtWindow, 'postSmoothing',dxdtSmoothing);