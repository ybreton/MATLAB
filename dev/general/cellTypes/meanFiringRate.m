function R = meanFiringRate(S)
%
%
%
%

if isa(S,'ts')
    S = {S};
end
if iscell(S)
    sz = size(S);
    S = S(:);
end

R = nan(length(S),1);
for iC=1:length(S);
    if ~isempty(S{iC})
        if length(S{iC}.data>1)
            S0 = S{iC}.data;

            ISI = diff(S0);
            R(iC) = nanmean(1./ISI);
        end
    end
end

R = reshape(R,sz);