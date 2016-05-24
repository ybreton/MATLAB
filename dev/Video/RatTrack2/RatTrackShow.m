function RatTrackShow(RatTrackData)

if nargin==0
	global RatTrackData
end

clf

imshow(RatTrackData.meanFrame*3); 
hold on
plot(RatTrackData.LEDx,RatTrackData.LEDy)
quiver(RatTrackData.LEDx, RatTrackData.LEDy, ...
	+ 5*cos(RatTrackData.LEDphiB), + 5*sin(RatTrackData.LEDphiB), ...
	'r')
quiver(RatTrackData.LEDx, RatTrackData.LEDy, ...
	+ 3*cos(RatTrackData.LEDphiH), + 3*sin(RatTrackData.LEDphiH), ...
	'g')