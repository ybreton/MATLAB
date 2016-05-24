function sd = RRalignedXY(sd,varargin)
% Produces a cell array of x and y tsd's with the maze rotated for each
% zone.
% sd = RRalignedXY(sd)
% where         sd          is standard session data structure
%
% with fields:
% sd.xAlign     nZones x 1 cell array of x positions, rotated for each zone
%                   so the rat is moving up and to the right (arm entry) or
%                   up and to the left (zone exit)
% sd.yAlign     nZones x 1 cell array of y positions, rotated for each zone
%                   so the rat is moving up and to the right (arm entry) or
%                   up and to the left (zone exit)
%
%

[x,y]=RRcentreMaze(sd);
theta(1) = pi/2;
theta(2) = 0;
theta(3) = -pi/2;
theta(4) = pi;

process_varargin(varargin);

rotation = nan(2,2,length(theta));
for iZ=1:length(theta)
    rotation(:,:,iZ) = [cos(theta(iZ)) -sin(theta(iZ));
                        sin(theta(iZ))  cos(theta(iZ))];
end

xy = [x.data y.data];
t = x.range;

sd.xAlign = cell(length(theta),1);
sd.yAlign = cell(length(theta),1);
for iZ=1:length(theta)
    xyZ = (squeeze(rotation(:,:,iZ))*xy')';
    sd.xAlign{iZ} = tsd(t,xyZ(:,1));
    sd.yAlign{iZ} = tsd(t,xyZ(:,2));
end