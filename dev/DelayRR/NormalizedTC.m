function TC = NormalizedTC(TC);
% Adds fields
%               .Norm
%               .Rate
% to tuning curve structure TC.

Occ = reshape(TC.Occ,[1 size(TC.Occ)]);
nCells = size(TC.H,1);
Occ = repmat(Occ,[nCells ones(1,length(size(TC.Occ)))]);

TC.Norm = Occ;
TC.Rate = TC.H./TC.Norm;
