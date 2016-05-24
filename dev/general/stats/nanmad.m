function MAD = nanmad(x,dim)
% Median absolute deviation from the median
% MAD = nanmad(x,dim)
% where     MAD         is the median absolute deviation from the median
% 
%           x           is the data to use
%           dim         is the dimension along which to calculate MAD;
%                       default is 1.

if nargin<2
    dim=1;
    sz = size(x);
    if length(sz)==2&&sz(1)==1&&sz(2)>1
        disp('Row vector.')
        x = x(:);
    end
end

sz = size(x);
rep = ones(1,length(sz));
rep(dim) = sz(dim);

m = nanmedian(x,dim);
d = x-repmat(m,rep);
MAD = nanmedian(abs(d),dim);