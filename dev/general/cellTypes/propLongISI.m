function p = propLongISI(S,X,T,varargin)
% Proportion of time spent in ISI's that exceed criterion
% p = propLongISI(S,X,T)
% where     p       is m x n x ... x p matrix of proportions,
%
%           S       is m x n x ... x p cell array of spike ts's, or
%                   is a ts
%           X       is the criterion for a long ISI
%           T       is the duration of the session
%

process_varargin(varargin);

if isa(S,'ts')
    S = {S};
end
if iscell(S)
    sz = size(S);
    S = S(:);
end

p = nan(length(S),1);
for iC=1:length(S);
    if ~isempty(S{iC})
        S0 = S{iC}.data;
    
        ISI = diff(S0);
        longISI = ISI>X;
        p(iC) = nansum(ISI(longISI))/T;
    end
end

p = reshape(p,sz);