function z = VT_linearizePath(sd,Path,LapTimes,varargin)
% 2013-03-19 AndyP
% z = VT_linearizePath(sd,Path,LapTimes);
% get the linearized position z from <x,y> paths in Path and lap times in
% LapTimes.  For each lap, the linearized position is an ordered
% one-dimensional representation of the position of the rat.
%
% INPUTS
% sd - standard session data structure, contains fields x and y
% Path - structure with fields medx and mey containing the median path of
% <x,y> tracking data for a specific path (or set of paths) from a session.
% (eg. from Path=VT_medianPath)
% LapTimes - structure with fields containing lap start and end times [in sec] for each type of path.  
% Each field in LapTimes is a (nL x 2) double with nL being the number of laps of the type of path.
% The first column of LapTimes contains lap start times and the second column contains lap end times.
%
% OUTPUTS
% z - tsd of linearized path, same size as tracking data
%
% VARARGIN OPTIONS
% doPlot - 1x1 logical, optional plot output to check if function is working correctly

doPlot = true;

process_varargin(varargin);

% checks
fnames = fieldnames(sd);
assert(any(strcmp(fnames,'x')),'sd must contain tracking data field x');
assert(any(strcmp(fnames,'y')),'sd must contain tracking data field y');
assert(isstruct(Path),'Path must be a structure');
fnames = fieldnames(Path);
assert(any(strcmp(fnames,'medx')),'Path must contain field medx');
assert(any(strcmp(fnames,'medy')),'Path must contain field medx');
fnames0 = fieldnames(LapTimes);

%%% get linearized path zi of <x,y> data from median paths
pnames = fieldnames(Path.medx);
nP = length(pnames); % nP - number of paths
for iP=1:nP
	assert(any(strcmp(pnames,fnames0{iP})),'Path and LapTimes must have all the same fields');
	x0 = sd.x.mask(LapTimes.(pnames{iP})(:,1),LapTimes.(pnames{iP})(:,2),false); % NaN data outside trial pair, keep data in trial pair, trial pair is path start/end time
	y0 = sd.y.mask(LapTimes.(pnames{iP})(:,1),LapTimes.(pnames{iP})(:,2),false); % NaN data outside trial pair, keep data in trial pair, trial pair is path start/end time
	xD = x0.data;
	yD = y0.data;
	notnan = ~isnan(xD) & ~isnan(yD);   % keep track of nans
	zi = x0.data;          % dummy tracking variable
	zi(notnan) = griddata(Path.medx.(pnames{iP}), Path.medy.(pnames{iP}), 1:length(Path.medx.(pnames{iP})), xD(notnan), yD(notnan), 'nearest'); %#ok<FPARK>
	zi(~notnan) = nan;
	z.(pnames{iP}) = tsd(x0.range,zi); % pack into tsd
end

% optional plot output
if doPlot
	nXY = ceil(sqrt(nP));
	figure(1); clf;
	for iP=1:nP
		subplot(nXY,nXY,iP); hold on;
		z0 = z.(pnames{iP}).removeNaNs;
		plot3(sd.x.range,sd.x.data,sd.y.data,'.','markersize',1,'color',[0.5 0.5 0.5]);
		plot3(z0.range,  Path.medx.(pnames{iP})(z0.data), Path.medy.(pnames{iP})(floor(z0.data)),'r');
		title(pnames{iP},'fontsize',36);
		xlabel('time (s)','fontsize',24);
		ylabel('<z(medx)>','fontsize',24);
		zlabel('<z(medy)>','fontsize',24);
		axis off;
	end
end



end