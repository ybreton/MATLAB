function [phiB0,phiH0] = RatTrackTestEllipse(im, x0, y0)

global RatTrackParms

% phi = RatTrackTestEllipse(im, x0, y0)
nOrientationsB = 12;
nOrientationsH = 8;
phiB = linspace(-pi,pi,nOrientationsB);
phiH = linspace(pi/2,3*pi/2,nOrientationsH);
s = nan(nOrientationsB,nOrientationsH);

[m,n] = size(im);
[X,Y] = meshgrid(1:n, 1:m);

for iPhi = 1:nOrientationsB
	for jPhi = 1:nOrientationsH
		s(iPhi,jPhi) = RatTrackTestTwoEllipse(im, X, Y, x0, y0, phiB(iPhi), phiH(jPhi), true); % show ellipses.
	end
end

[~,mPhi] = min(s(:));
phiB0 = phiB(rem(mPhi, nOrientationsB));
phiH0 = phiB0 + phiH(ceil(mPhi/nOrientationsB));

RatTrackTestTwoEllipse(im, X, Y, x0, y0, phiB0, phiH0-phiB0, RatTrackParms.debug);


function s = RatTrackTestTwoEllipse(im, X, Y, x0, y0, phi0, phi1, flagSHOW)

%BODY
r = 20;
x1 = x0 + 2*r * cos(phi0);
y1 = y0 + 2*r  * sin(phi0);
[s1,bw1] = TestCircle(im, X, Y, r, x1, y1);

%HEAD
r = 12;
x1 = x0 + 2*r  * cos(phi0+phi1);
y1 = y0 + 2*r  * sin(phi0+phi1);
[s2,bw2] = TestCircle(im, X, Y, r, x1, y1);

s = s1 + s2;

if flagSHOW
	ShowRatMask(im, imadd(bw1,bw2), s);
end


function [s,bw] = TestCircle(im, X, Y, r, focus1x, focus1y)

global RatTrackParms

d = (focus1x-X).^2+(focus1y-Y).^2;
bw = d < (r*r);
T = double(im(bw))-RatTrackParms.ratColor;
s = mean(abs(T));


function ShowRatMask(im, r, s)

figure(1); clf
RGB_label = label2rgb(r, @jet, 'k');
imshow(imadd(repmat(im,[1 1 3]),RGB_label));
hold on;
title(num2str(s));
drawnow
return

% function s = RatTrackTestOneEllipse(im, X, Y, x0, y0, phi0)
% 
% % s = RatTrackTestEllipse(im, phi)
% 
% majorAxis = 50;
% eccentricity = 1.2;
% 
% focus1x = x0 - eccentricity/2.5*majorAxis*cos(phi0); 
% focus1y = y0 - eccentricity/2.5*majorAxis*sin(phi0); 
% focus2x = x0 + eccentricity*majorAxis*cos(phi0);
% focus2y = y0 + eccentricity*majorAxis*sin(phi0);
% 
% s = TestEllipse(im, X, Y, majorAxis,  focus1x, focus1y, focus2x, focus2y);

% function [s,r] = TestEllipse(im, X, Y, majorAxis, focus1x, focus1y, focus2x, focus2y)
% 
% global RatTrackParms
% 
% d = sqrt((focus1x-X).^2+(focus1y-Y).^2) + sqrt((focus2x-X).^2+(focus2y-Y).^2);
% r = d < (2*majorAxis);
% s = mean(abs(double(im(r))-RatTrackParms.ratColor));
