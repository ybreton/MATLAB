function [flavour,amount,overall] = wrap_RR_getWholeSessThresh(sess)
% Wrapper to get the flavour, amount, and overall root-mean squared
% deviations from overall thresholds fit from the whole session.
% [flavour,amount,overall] = wrap_RR_getWholeSessThresh(sess)
% where     flavour         is nSessions x 3 RMSD of flavours at each
%                               nPellets
%           amount          is nSessions x 4 RMSD of amounts at each zone
%           overall         is nSessions x 1 RMSD of thresholds from grand.
%
%           sess            is nSessions x 1 structure with field sd
%                               containing sd data.
%

flavour = nan(length(sess),3);
amount = nan(length(sess),4);
overall = nan(length(sess),1);

for iSess = 1 : length(sess)
    flavour(iSess,:) = sess(iSess).sd(1).WholeSession.RMSD.Flavour(:)';
    amount(iSess,:) = sess(iSess).sd(1).WholeSession.RMSD.Amount(:)';
    overall(iSess,:) = sess(iSess).sd(1).WholeSession.RMSD.Overall(:)';
end

