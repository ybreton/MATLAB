function [flavour,amount,overall] = wrap_RR_getSubSessThresh(sess)
% Wrapper to get the thresholds fit to each subsession from each session.
%
%
%

nSubsess = 0;
for iSess = 1 : length(sess)
    nSubsess = max(nSubsess,length(sess(iSess).sd));
end

flavour = nan(length(sess),nSubsess,3);
amount = nan(length(sess),nSubsess,4);
overall = nan(length(sess),nSubsess);

for iSess = 1 : length(sess)
    for s = 1 : length(sess(iSess).sd)
        flavour(iSess,s,:) = sess(iSess).sd(1).WholeSession.RMSD.Flavour(:)';
        amount(iSess,s,:) = sess(iSess).sd(1).WholeSession.RMSD.Amount(:)';
        overall(iSess,s) = sess(iSess).sd(1).WholeSession.RMSD.Overall;
    end
end

