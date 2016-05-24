function [staygo,sdOut] = RRGetStaygo(sd,varargin)
% Produces stay/go boolean matrix.
% [staygo,sd] = RRstaygo(sd)
% where     staygo is nSubsess x trial boolean of stay (1), go (0), or no lap (nan)
%           if sd output is specified, will add field Staygo to each subsession.
%           
%           sd is nSubSess x 1 structure array of sd files.
%
% OPTIONAL:
% nLaps     (default 200)   maximum number of laps
% nZones    (default 4)     number of zones
%

nLaps = 200;
nZones = 4;
process_varargin(varargin);

sd = sd(:);

staygo = nan(numel(sd),nLaps*nZones*numel(sd));
for s = 1 : numel(sd)
    sg = double(ismember(sd(s).ExitZoneTime,sd(s).FeederTimes));
    if ~isempty(sg)
        if sg(end)==0
            % When session ends, it is either counting down or not.
            % If it was counting down, it will be scored as a skip.
            % If it was not counting down, it will be scored as a stay.
            % Skipped the last zone entered means the stay is censored.
            sg(end) = nan;
        end
    end
    staygo(s,1:length(sg)) = sg(:)';
end

if nargout>1
    for s = 1 : numel(sd)
        sd0 = sd(s);
        sd0.Staygo = staygo(s,:);
        sdOut(s) = sd0;
    end
end