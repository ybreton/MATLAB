function Path = VT_medianPath(sd,t,pathStr,varargin)
% 2013-03-13 AndyP
% Path = VT_medianPath(sd,t,pathStr);
% Calculate median path in <x,y> for different lap types defined by indices in pathStr and lap times in t.  To calculate
% median path for all laps create a field in sd that has a vector from 1:TotalLaps.
% INPUTS
% sd - standard data structure, containing field pathStr
% pathStr - string, must be a field in sd:
% sd.(pathStr) (note: using dynamic field notation for structures) contains fields which are indices for laps of different
% types (ie. sd.LRTA.LT=[5,7,10] indicates that laps 5,7,10 are laps of type 'LT').
%
% OUTPUTS
% Path - structure with the median <x,y> position <medx,medy>.  medx and
% medy are, themselves, structures that contain fields for each lap type
% specified by pathStr.  Each structure in Path.medx and Path.medy contains N points of
% resampled position data determined by the varargin option factor.  (ie.
% Path.medx.LT: [1x1000 double].  Default: factor=1000 points
%
% VARARGIN OPTIONS
% factor - 1x1 double, integer to resample tracking data
% minLaps - 1x1 double, minimum number of laps to use when taking the
% median.  Default: 1 lap.
% smoothing - 1x1 double, optional smoothing to median path
% doPlot - 1x1 logical, check whether function is working

factor = 1000;  % integer number to resample tracking data
minLaps = 1;    % minimum number of laps to use when taking the median.
smoothing = 10; % optional smoothing to median path
doPlot = true;  % check whether function is working

process_varargin(varargin);

% checks
fnames = fieldnames(sd);
assert(any(strcmp(fnames,pathStr)),sprintf('sd must contain field %s',pathStr));
assert(isstruct(t),'input t must be a structure');
fnames = fieldnames(t);
assert(any(strcmp(fnames,'t0')),'t must have field t0 for lap start times');
assert(any(strcmp(fnames,'t1')),'t must have field t0 for lap end times');
assert(length(t.t0)==length(t.t1),'t0 and t1 must be the same length');

%%% resample tracking data to N points, get median of <x,y> data
pathnames = fieldnames(sd.(pathStr));
nP = length(pathnames);  % nP number of path types
for iP=1:nP
	nL = length(sd.(pathStr).(pathnames{iP}));  % nL number of laps of type iP
	assert(nL<=length(t.t0),sprintf('lap index of field %s exceeds the lap times in t',pathnames{iP}));
	px0 = nan(factor,nL);
	py0 = nan(factor,nL);
	for iL=1:nL
		if nL> minLaps  % can't take a median path from 1 lap
			Px = sd.x.restrict(t.t0(sd.(pathStr).(pathnames{iP})(iL)),t.t1(sd.(pathStr).(pathnames{iP})(iL))); % restrict <x> to path type
			Py = sd.y.restrict(t.t0(sd.(pathStr).(pathnames{iP})(iL)),t.t1(sd.(pathStr).(pathnames{iP})(iL))); % restrict <y> to path type
			if ~isempty(Px.data);
				Px = Px.removeNaNs; % can't interp with NaNs
				Py = Py.removeNaNs; % can't interp with NaNs
				px0(1:factor,iL) = interp1(1:length(Px.data), Px.data, linspace(1, length(Px.data), factor)); % resample <x> path to N points
				py0(1:factor,iL) = interp1(1:length(Py.data), Py.data, linspace(1, length(Py.data), factor)); % resample <y> path to N points
			end
		end
	end
	medx.(pathnames{iP})(1:factor) = nanmedian(px0,2); % find median of <x> path
	medy.(pathnames{iP})(1:factor) = nanmedian(py0,2); % find median of <y> path
	if smoothing>0
		medx.(pathnames{iP})(1:factor)=smooth(medx.(pathnames{iP})(1:factor),smoothing); % smooth <x> every N points
		medy.(pathnames{iP})(1:factor)=smooth(medy.(pathnames{iP})(1:factor),smoothing); % smooth <y> every N points
	end
end

% pack outputs
Path.medx = medx;
Path.medy = medy;
Path.params.pathStr = pathStr;
Path.params.pathnames = pathnames;
Path.params.factor = factor;

% optional plot output
if doPlot
	figure(1); clf;
	nXY = ceil(sqrt(length(pathnames)));
	for iP=1:nP
		subplot(nXY,nXY,iP); hold on;
		plot(-sd.y.data,-sd.x.data,'.','markersize',1,'color',[0.5 0.5 0.5]);
		plot(-Path.medy.(pathnames{iP}),-Path.medx.(pathnames{iP}),'r.','markersize',5);
		title(pathnames{iP},'fontsize',40);
		axis off;
	end
end
end