function sqsum = square_sum(X,Y)
%#
coder.inline('never')

sqsum = zeros(size(X));
parfor iXY = 1 : numel(X)
    sqsum(iXY) = X(iXY)*X(iXY)+Y(iXY)*Y(iXY);
end