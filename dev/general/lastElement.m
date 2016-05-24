function B = lastElement(A,dim)
% Simple function to get the last element along dimension dim.
% B = lastElement(A)
% is equivalent to
% B = A(end,:,:,...,:)
%
% B = lastElement(A,dim)
% is equivalent to
% B = A(:,...,end,...,:), with the end statement at the dim dimension.
%
%

if nargin<2
    dim = 1;
end

sz = size(A);
str = '';
for iD=1:length(sz)
    if iD~=dim
        str = [str 'end,'];
    else
        str = [str ':,'];
    end
end
str = str(1:end-1);

B = eval(['A(' str ');']);