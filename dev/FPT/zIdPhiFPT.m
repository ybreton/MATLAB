function sd = zIdPhiFPT(sd, varargin)

% sd = zIdPhi(sd, varargin)
%
% Calculates zIdPhi
% 2012-04-16 AndyP added arbitrary (tstart, tend) times
% 2012-06-21 AndyP fixed x,y assignment error line 17
% 2012-06-21 AndyP added VT1 or VT2 option
%
% 2012-07-25 ADR tend defined as ExitingCPTime
% 2013-01-21 AndyP added checks for sorted timestamps, dxdt returns error if timestamps are out of order  
% 2014-08-13 YAB additions for FPT/Aging:
%               - tIdPhi field provides time in CP, removing NaN position
%               samples,
%               - nIdPhi field identifies how many position samples
%               contributed to IdPhi calculation,
%               - IdPhi where nIdPhi is 0 is now nan,
%               - LogIdPhi field calculates the Log10[IdPhi]
%               - zSideIdPhi field calculates Z[IdPhi] normalizing to
%               mean/std of side,
%               - zLogIdPhi field calculates Z[Log10[IdPhi]] normalizing to
%               mean/std of side.
%               - nanflag optional argument in (default false) replaces
%               IdPhi with nan when the number of position samples (nIdPhi)
%               is 0 or time in CP (tIdPhi) is 0.
%               - minPos optional argument in (default 0) sets the minimum
%               number of non-nan position samples for valid IdPhi.
%               - minSec optional argument in (default 0) sets the minimum
%               amount of non-nan time for valid IdPhi.
%               
VT = 1;
dxdtWindow = 0.5;
dxdtSmoothing = 0.1;
tstart = sd.EnteringCPTime;
tend = sd.ExitingCPTime;
nanflag = false;
minPos = 0;
minSec = 0;
process_varargin(varargin);
%%%%%%%%%%%%%%%%%%%%
if VT==1
	x = sd.x;
	y = sd.y;
elseif VT==2
	x = sd.x2;
	y = sd.y2;
else
	error('unknown VT');
end
x = x.removeNaNs;
y = y.removeNaNs;
%%%%%%%%%%%%%%%%%%%%
assert(length(tstart)==length(tend),'tstart must equal tend');
if ~issorted(x.range); time=sort(x.range); x=tsd(time,x.data); end % cheetah (ring buffer error?) causes out of order timestamps
if ~issorted(y.range); time=sort(y.range); y=tsd(time,y.data); end
[ dx ] = dxdt(x, 'window', dxdtWindow, 'postSmoothing',dxdtSmoothing);
[ dy ] = dxdt(y, 'window', dxdtWindow, 'postSmoothing',dxdtSmoothing);

phi = tsd(dx.range(), atan2(dy.data(), dx.data()));
uphi = tsd(phi.range(), unwrap(phi.data()));
dphi = dxdt(uphi, 'window', dxdtWindow, 'postSmoothing',dxdtSmoothing);
%%%%%%%%%%%%%%%%%%%%
nPasses = length(tstart);
IdPhi = nan(nPasses,1);
nIdPhi = nan(nPasses,1);
tIdPhi = nan(nPasses,1);
for iL = 1:nPasses
	dphi0 = dphi.restrict(tstart(iL), tend(iL));
	IdPhi(iL) = sum(abs(dphi0.data()));
    nIdPhi(iL) = length(~isnan(data(x.restrict(tstart(iL),tend(iL)))));
    xL = x.restrict(tstart(iL),tend(iL));
    t = xL.range;
    xD = xL.data;
    idnan = isnan(xD);
    t(idnan) = [];
    if ~isempty(t)
        tIdPhi(iL) = max(t)-min(t);
    else
        tIdPhi(iL) = 0;
    end
end

% construct output %
sd.nIdPhi = nIdPhi;
sd.tIdPhi = tIdPhi;

if nanflag
    IdPhi(nIdPhi<minPos|tIdPhi<minSec) = nan;
end

sd.IdPhi = IdPhi;

sd.zIdPhi = (IdPhi-nanmean(IdPhi))./nanstd(IdPhi);
sd.LogIdPhi = log10(IdPhi);

sd.zSideIdPhi = nan(size(IdPhi));
sd.zLogIdPhi = nan(size(IdPhi));
uniqueZones = unique(sd.ZoneIn);
idOK = ~isinf(sd.LogIdPhi);
nL=length(tstart);
for zone = uniqueZones(:)';
    idZone = sd.ZoneIn(1:nL)==zone;
    sd.zSideIdPhi(idZone(:)) = nanzscore(IdPhi(idZone(:)));
    LogIdPhiZone = (log10(IdPhi(idZone(:)&idOK(:))));
    sd.zLogIdPhi(idZone(:)&idOK(:)) = nanzscore(LogIdPhiZone);
end

sd.LogIdPhi = log10(IdPhi);