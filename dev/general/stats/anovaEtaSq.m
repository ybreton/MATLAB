function [etaSq,partial] = anovaEtaSq(table)
% Produces a vector of eta square and partial eta squared values for an ANOVA table cell array.
% etaSq = anovaEtaSq(table)
% where     etaSq           is (m+1) x 1 vector of eta-squared values
%                               calculated as
%                               SSeffect / SStotal
%
%           table           is (m+1) x 7 cell array with the ANOVA source
%                               table produced by anova1, anova2, anovan
%                               with columns
%                               {'Source', 'Sum Sq.', 'd.f.', 'Singular?', 'Mean Sq.', 'F', 'Prob>F'}
% the rows of etaSq correspond to the rows of the table, with the first row
% being nan.
%
% [etaSq,partial] = anovaEtaSq(table)
% where     partial         is (m+1) x (m+1) matrix of (i,j) with partial
%                               eta-squared values for row i using error
%                               term in row j, calculated as
%                               SSeffect / (SSeffect+SSerror).
%
% For one-way designs, where SSeffect+SSerror=SStotal, eta^2 = part eta^2.
%

sources = table(2:end,1);
idTotal = find(strcmpi('Total',sources))+1;
idError = find(strncmpi('Error',sources,5))+1;

SS = nan(length(table(:,2)),1);
SS(2:end) = can2mat(table(2:end,2));

etaSq = SS./SS(idTotal);
partial = nan(length(sources)+1);
for iErr=idError
    partial(:,iErr) = SS./(SS(iErr)+SS);
end