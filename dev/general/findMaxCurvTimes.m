function tMax = findMaxCurvTimes(sd,varargin)
% Wrapper to find the time of maximum curvature between t1 and t2.
% tMax = findMaxCurvTimes(sd)
% where     tMax        is nLaps x 1 vector of maximum curvature times, and
%
%           sd          is standard data structure.
%
% OPTIONAL ARGUMENTS:
% ******************
% nL    (default: length(sd.ZoneIn))
%                       number of laps to calculate max curvature times.
% t1    (default: sd.EnteringZoneTime)
%                       time to begin curvature calculation.
% t2    (default: sd.ExitZoneTime)
%                       time to stop curvature calculation.
%
%

t1 = sd.EnteringZoneTime;
t2 = sd.ExitZoneTime;
nL = min(length(t1),length(t2));
process_varargin(varargin);
t1 = t1(:);
t2 = t2(:);
assert(length(t1)<=nL,'Start times must be at least as long as nL.')
assert(length(t2)<=nL,'Stop times must be at least as long as nL.')

C = Curvature(sd.x.restrict(t1,t2),sd.y.restrict(t1,t2));

tMax = nan(nL,1);
for iLap=1:nL
    D = data(C.restrict(t1(iLap),t2(iLap)));
    T = range(C.restrict(t1(iLap),t2(iLap)));
    [maxC,I] = nanmax(D);
    tMax(iLap) = T(I);
end