function [pellets,sdOut] = RRGetPellets(sd,varargin)
% Produces pellets matrix.
% [pellets,sd] = RRGetPellets(sd)
% where     pellets is nSubSess x trial vector of pellets delivered,
%           if sd output is specified, will add field Pellets to each subsession.
%           
%           sd is nSubsess x 1 cell array of sd files.
%
% OPTIONAL:
% nLaps     (default 200)   maximum number of laps
% nZones    (default 4)     number of zones
%

nLaps = 200;
nZones = 4;
process_varargin(varargin);


pellets = nan(numel(sd),nLaps*nZones*numel(sd));

for s = 1 : numel(sd)
        zone = sd(s).ZoneIn;
    
        pt = sd(s).nPellets;
        nReps = ceil(length(zone)/length(pt));
        pt = repmat(pt,1,nReps);
        pt = pt(1:length(zone));
        
        pellets(s,1:length(zone)) = pt;
end

if nargout>1
    for s = 1 : numel(sd)
        sd0 = sd(s);
        sd0.Pellets = pellets(s,:);
        sdOut(s) = sd0;
    end
end