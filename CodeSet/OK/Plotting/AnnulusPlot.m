function AnnulusPlot(D, varargin)

% AnnulusPlot(D, varparms)
%
% D = nBins x nCols;
clf;
r0 = 10;
r1 = 12;
zStep = 10;
process_varargin(varargin);

[nBins, nZ] = size(D);

phi = linspace(-pi,pi,nBins-1);
p0 = cat(2, phi, phi(1));
p1 = cat(2, phi(end), phi);
xse = r0*cos(p0); xsw = r0*cos(p1); xne = r1*cos(p0); xnw = r1*cos(p1);
yse = r0*sin(p0); ysw = r0*sin(p1); yne = r1*sin(p0); ynw = r1*sin(p1);

X = [xse' xne' xnw' xsw']';
Y = [yse' yne' ynw' ysw']';

for iZ = 1:nZ
	Z = repmat([1.25 1 1 1.25],nBins,1)*zStep+zStep*iZ; Z = Z';
	patch(X,Y,Z,D(:,iZ)');
end
shading flat
view(3);
alpha(0.5);