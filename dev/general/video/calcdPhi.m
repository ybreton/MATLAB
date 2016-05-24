function [dphi,dphiAbs] = calcdPhi(x,y,varargin)

dxdtWindow = 0.33;
dxdtSmoothing = 0.33;

process_varargin(varargin);

[ dy ] = dxdt(y, 'window', dxdtWindow, 'postSmoothing',dxdtSmoothing);
[ dx ] = dxdt(x, 'window', dxdtWindow, 'postSmoothing',dxdtSmoothing);

phi = tsd(dx.range(), atan2(dy.data(), dx.data()));
uphi = tsd(phi.range(), unwrap(phi.data()));
dphi = dxdt(uphi, 'window', dxdtWindow, 'postSmoothing',dxdtSmoothing);
dphiAbs = tsd(dphi.range,abs(dphi.data));