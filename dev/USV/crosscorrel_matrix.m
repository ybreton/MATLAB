function [R,n] = crosscorrel_matrix(Ampl,dim)
%
%
%
%
if nargin<2
    dim = 2;
end

n = nan(size(Ampl,dim));
R = nan(size(Ampl,dim));
for c1 = 1 : size(Ampl,dim)-1;
    R(c1,c1) = 1;
    for c2 = c1+1:size(Ampl,dim);
        idnan = isnan(Ampl(:,c1))|isnan(Ampl(:,c2));
        r = corrcoef(Ampl(~idnan,c1),Ampl(~idnan,c2));
        n(c1,c2) = length(Ampl(~idnan,c1));
        n(c2,c1) = length(Ampl(~idnan,c2));
        R(c1,c2) = r(2);
        R(c2,c1) = r(2);
    end
end