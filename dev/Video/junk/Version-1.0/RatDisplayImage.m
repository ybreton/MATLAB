function RatDisplayImage(im, fignum, T, time)

global RatTrackData

figure(fignum);
clf;
imshow(im);
if ~isempty(time)
	title(sprintf('%s - %s %d:%f', ...
		RatTrackData.fn, T, floor(time/60), rem(time,60)));
else
	title(sprintf('%s - %s', ...
		RatTrackData.fn, T));
end

