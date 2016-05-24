function [entryTheta,armTheta,feederTheta] = RRzoneAngles(sd,varargin)
% Identifies on the maze what angles correspond to zone entry,
% arm entry, and feeder.
%
%
%

nZones=4;
process_varargin(varargin);

[sd.x,sd.y] = RRcentreMaze(sd);
if ~isfield(sd,'theta')
    sd.theta = tsd(sd.x.range,atan2(sd.y.data,sd.x.data));
end
if ~isfield(sd,'radius')
    sd.radius = tsd(sd.x.range,sqrt(sd.x.data.^2+sd.y.data.^2));
end
stayGo = RRGetStaygo(sd);
entryTheta = nan(nZones,1);
armTheta = nan(nZones,1);
feederTheta = nan(nZones,1);
for iZ=1:nZones
    Tin = sd.EnteringZoneTime(iZ:nZones:end);
    Tout = sd.EnteringZoneTime(iZ+1:nZones:end);
    nTrls = length(Tout);
    Tfire = sd.FeederTimes(sd.FeedersFired==iZ);
    sg = stayGo(iZ:nZones:end);
    % Radius of zone entry
    entryTheta(iZ) = nanmedian(sd.theta.data(Tin));
    
    % Radius of arm entry
    mT = nan(nTrls,1);
    for iTrl=1:nTrls
        dat = data(sd.theta.restrict(Tin(iTrl),Tout(iTrl)));
        if dat(end)<dat(1)
            dat = wrapTo2Pi(dat);
            mT(iTrl) = wrapToPi(mean(dat));
        else
            mT(iTrl) = mean(dat);
        end
    end
    armTheta(iZ) = nanmedian(mT(sg(1:nTrls)==0));
    
    % Radius of feeder
    feederTheta(iZ) = nanmedian(sd.theta.data(Tfire));
end