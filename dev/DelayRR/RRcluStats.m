function s = RRcluStats(S)
% BETA.
% returns a structure array with [n x m x ... x p] fields
%       .ISI            mean inter-spike interval
%
%
%
window = 1;

ISI = nan(size(S));
ISI = ISI(:);
for iC = 1 : numel(S)
    S0 = S{iC};
    
    dt = diff(S0.data);
    ISI(iC) = nanmean(dt);
end
ISI = reshape(ISI,size(S));
s.ISI = ISI;