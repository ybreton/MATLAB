function MI = TC_mutual_information(S,D)
% Returns the mutual information between spikes in S and the dimensions of
% D.
%
%
%
if ~iscell(S);
    S = {S};
end

MI = nan(size(S));
for iC=1:numel(S);
    s0 = S{iC};
    TC = TuningCurves(s0,D);

    if length(D)>1
        s = squeeze(TC.H);
    else
        s = TC.H(:);
    end
    x = TC.Occ;
    sx = (s./x);
        

    Psx = sx./nansum(sx(:));
    Ps = s./nansum(s(:));
    Px = x./nansum(x(:));

    Hs = -nansum(Ps(:).*log2(Ps(:)));
    Hx = -nansum(Px(:).*log2(Px(:)));
    Hsx = -nansum(Psx(:).*log2(Psx(:)));
    
    MI(iC) = (Hs+Hx)-Hsx;
end