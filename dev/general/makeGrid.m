function [Xmat,Ymat,Zmat] = makeGrid(X,Y,Z)
%
%
%
%

uniqueX = unique(X);
uniqueY = unique(Y);
[Xmat,Ymat] = meshgrid(uniqueX,uniqueY);
[nr,nc] = size(Xmat);
Zmat = nan(nr,nc);
for c = 1 : length(uniqueX)
    for r = 1 : length(uniqueY)
        idZ = X==uniqueX(c) & Y==uniqueY(r);
        if ~isempty(Z(idZ))
            Zmat(r,c) = Z(idZ);
        end
    end
end