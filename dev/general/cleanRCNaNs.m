function B = cleanRCNaNs(A)
% Removes rows that contain all nans and columns that contain all nans.

keepCol = true(1,size(A,2));
for iC = 1 : size(A,2)
    keepCol(iC)=~all(isnan(A(:,iC)));
end
keepRow = true(size(A,1),1);
for iR = 1 : size(A,1)
    keepRow(iR)=~all(isnan(A(iR,:)));
end

B = A(keepRow,:);
B = B(:,keepCol);