function threshold = wrap_RR_summarizeThreshold(VEH,varargin)
% Wrapper produces nZones x nPellets x nSessions matrix of threshold
% values.
% threshold = wrap_RR_summarizeThreshold(VEH)
% where     threshold       is nZones x nPellets x nSessions matrix of
%                               threshold values for zone, pellet, session.
%
%           VEH             is nSessions x 1 structure with field sd of
%                               standard session data.
%
%
maxZones = 4;
maxPellets = 3;
process_varargin(varargin);

threshold = nan(maxZones,maxPellets,length(VEH));
for iSess = 1 : length(VEH)
    sd = VEH(iSess).sd;
    threshold(:,:,iSess) = sd(1).WholeSession.Thresholds.FlavourAmount;
end
