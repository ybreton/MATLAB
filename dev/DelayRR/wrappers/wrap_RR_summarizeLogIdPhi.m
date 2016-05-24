function LogIdPhiVeh = wrap_RR_summarizeLogIdPhi(VEH)
% Wrapper concatenates all LogIdPhi values together.
% LogIdPhiVeh = wrap_RR_summarizeLogIdPhi(VEH)
% where     LogIdPhiVeh     is nAllTrials x 1 vector of log10(IdPhi) values
%
%           VEH             is nSess x 1 structure array with sd field of
%                               standard session data.
%

LogIdPhiVeh = [];
for iSess = 1:length(VEH);
    sd = VEH(iSess).sd;
    for iSubsess = 1 : length(sd)
        LogIdPhiVeh = cat(1,LogIdPhiVeh,sd(iSubsess).LogIdPhi(:));
    end
end