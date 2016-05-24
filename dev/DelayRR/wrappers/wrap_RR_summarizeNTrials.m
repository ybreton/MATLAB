function nTrialsVeh = wrap_RR_summarizeNTrials(VEH)
% Wrapper produces nSess x 1 vector of number of trials.
% n = wrap_RR_summarizeNTrials(VEH)
% where     n       is nSess x 1 vector of number of trials.
%
%           VEH     is nSess x 1 structure array with field sd, standard
%                       session data for each session.
%

nTrialsVeh = nan(length(VEH),1);
for iSess = 1 : length(VEH)
    sd = VEH(iSess).sd;
    [~,sd] = RRGetStaygo(sd);
    if length(sd)==1
        nTrialsVeh(iSess) = nansum(double(sd.Staygo==1|sd.Staygo==0));
    end
end

