function m = celldim2matdim(c)
% Convert inner cell array dimensions to matrix with outer x inner
% dimensions
%
% M = celldim2matdim(C)
% where         M          is a M x N x ... x P  x  A x B x ... C matrix
%
%               C           is a M x N x ... x P cell array, with cells
%                           that are at most of dimension
%                           A x B x ... x C
%
%   Converts a (m x n x ... x p) cell array
%   with cells that are (a x b x ... x c)
%   into a matrix with entries that are
%   (m x n x ... x p   x   a x b x ... x c)
%
%

sz = size(c);
% Get the maximum size of the data in cells of c
sz0 = [-inf -inf];
for iC=1:numel(c);
    cz = size(c{iC});
    for iDim=1:length(cz)
        if length(sz0)>=iDim
            sz0(iDim) = max(sz0(iDim),cz(iDim));
        else
            sz0(iDim) = cz(iDim);
        end
    end
end
m = nan([sz sz0]);
m = reshape(m,[prod(sz) prod(sz0)]);
for iC=1:numel(c);
    x = nan(sz0);
    cz = size(c{iC});
    str = sprintf('1:%.0f,',cz);
    str2= '';
    for iExDim=1:length(cz)-length(sz0)
        str2 = [str2 ':,'];
    end
    str = [str str2];
    str = str(1:end-1);
    try
        eval(['x(' str ')=c{iC};'])
    catch exception
        warning(exception.message)
    end
    m(iC,:) = x;
end
m = reshape(m,[sz sz0]);