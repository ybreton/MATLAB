function phi = RatTrackTestEllipse(im, x0, y0)

% phi = RatTrackTestEllipse(im, x0, y0)
nOrientations = 16;
phi = linspace(-pi,pi,nOrientations);
s = nan(nOrientations,1);

[m,n] = size(im);
[X,Y] = meshgrid(1:n, 1:m);

for iPhi = 1:nOrientations
	s(iPhi) = RatTrackTestOneEllipse(im, X, Y, x0, y0, phi(iPhi));	
end
[~,mPhi] = min(s);
phi = phi(mPhi);

function s = RatTrackTestOneEllipse(im, X, Y, x0, y0, phi0)

% s = RatTrackTestEllipse(im, phi)

global RatTrackParms

majorAxis = 50;
eccentricity = 1.2;

focus1x = x0 - eccentricity/2.5*majorAxis*cos(phi0); 
focus1y = y0 - eccentricity/2.5*majorAxis*sin(phi0); 
focus2x = x0 + eccentricity*majorAxis*cos(phi0);
focus2y = y0 + eccentricity*majorAxis*sin(phi0);

% ellipse 
% really want 
%      hypot(focus1x-X,focus1y-Y) + hypot(focus2x-X,focus2y-Y) < 2*axis

d = sqrt((focus1x-X).^2+(focus1y-Y).^2) + sqrt((focus2x-X).^2+(focus2y-Y).^2);
r = d < (2*majorAxis);
s = mean(abs(double(im(r))-RatTrackParms.ratColor));
% s = std(double(im(r)));

% figure(1); clf
% RGB_label = label2rgb(r, @jet, 'k');
% imshow(imadd(repmat(im,[1 1 3]),RGB_label));
% hold on;
% plot(focus1x,focus1y,'ro', focus2x, focus2y, 'rx');
% title(num2str(s));
% drawnow
% return

