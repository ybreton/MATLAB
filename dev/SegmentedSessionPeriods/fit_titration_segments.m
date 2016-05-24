function [fit,RSS] = fit_titration_segments(sd,K,varargin)
%
%
%
%

minDuration = 0;
debug = false;
process_varargin(varargin);

ZoneIn = sd.ZoneIn(:);
DelayZone = sd.DelayZone(:);
DelayDuration = sd.ZoneDelay(:);
ZoneTime = sd.EnteringZoneTime(:);
NormZoneTime = ZoneTime - ZoneTime(1);
TotalLaps = sd.TotalLaps;
Laps = (1:TotalLaps)';

InDelay = ZoneIn == DelayZone;

% Duration = tsd(NormZoneTime(InDelay),DelayDuration(InDelay));
DelayLaps = Laps(InDelay);
Duration = tsd(DelayLaps,DelayDuration(InDelay));
nDelayLaps = length(DelayLaps);

window = Duration.T(end)-Duration.T(1);
DurationDerivative = dxdt(Duration,'window',window);
nLaps = length(DurationDerivative.T);
LapList = 1:nLaps;

if K>0
    rS = ones(1,K);
    MSEold = inf;
    slopeOld = zeros(K,1);
    rangeOld = zeros(K,2);
    while all(rS<nLaps)
        R(:,1) = LapList(rS);
        rF = ones(1,K);
        while all(rF<nLaps-1)
            R(:,2) = LapList(rF);
            R0 = R';
            R0 = R0(:);
            
            lap = DurationDerivative.T(R0);
            
            if all(diff([0;R0(:)])>=minDuration)
                slope = fitRoutine(DurationDerivative,R,debug);
                RSS = errfunc(DurationDerivative,R,slope);
                if RSS<MSEold
                    MSEold = RSS;
                    slopeOld = slope;
                    rangeOld = R;
                end
            end
            rF(end) = rF(end)+1;
            for k = K : -1 : 1
                if rF(k)>nLaps-1
                    rF(k) = 1;
                    rF(k-1) = rF(k-1)+1;
                end
            end
        end
        rS(end) = rS(end)+1;
        for k = K : -1 : 2
            if rS(k)>nLaps-1
                rS(k) = 1;
                rS(k-1) = rS(k-1)+1;
            end
        end
    end
    RSS = errfunc(DurationDerivative,rangeOld,slopeOld);
    R = DurationDerivative.T(rangeOld(:));
    R = reshape(R,numel(R)/2,2);
    fit = [R';slopeOld(:)'];
else
    RSS = errfunc(DurationDerivative.D,[],zeros(0,2));
    fit = [nan;nan;0];
end


function slope = fitRoutine(dy_tsd,R,debug)

R = reshape(R,numel(R)/2,2);

slope = fminsearch(@(slope) errfunc(dy_tsd,R,slope,debug),zeros(size(R,1)));



function RSS = errfunc(dy_tsd,R,slope,debug)
if nargin < 4
    debug = false;
end
R = reshape(R,numel(R)/2,2);

yPred = zeros(length(dy_tsd.D),1);

for k = 1 : size(R,1)
    id = dy_tsd.T>=R(k,1) & dy_tsd.T<=R(k,2);
    yPred(id) = slope(k);
end

d = yPred(:) - dy_tsd.D(:);
RSS = d'*d;

if debug
    clf
    hold on
    plot(dy_tsd.T,dy_tsd.D,'ko')
    plot(dy_tsd.T,yPred,'r-')
    hold off
    drawnow
end