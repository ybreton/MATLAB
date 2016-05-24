function [U,I] = nanunique(X,rows,occurrence)
%
%
%
%

r = false;
oc = 'last';
if nargin==2
    if strcmpi(rows,'rows')
        r = true;
    elseif strcmpi(rows,'first')
        oc = rows;
    elseif strcmpi(rows,'last')
        oc = rows;
    end
end
if nargin==3
    r = strcmpi(rows,'rows');
    oc = occurrence;
end

assert(strcmpi(oc,'first')|strcmpi(oc,'last'),'Valid values for occurrence are ''first'' and ''last''.')

if r
    [U,I] = unique(X,'rows',oc);
else
    idnan = isnan(X);
    [U,I] = unique(X(~idnan),oc);
end
