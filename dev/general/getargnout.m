function varargout = getargnout(N,fcn,varargin)
% returns the Nth output argument of function fcn.
% [OUT1,...,OUTi] = getargnout(N,fcn,IN1,...,INj)
% where             OUT         is the argument returned as the N'th
%                               output.
% 
%                   N           is a 1 x 1 scalar or 1 x 1 x ... x n vector
%                               with the output argument to return,
%                   fcn         is a function handle to call,
%                   IN          is the input arguments to the function.
%
% for example,
% >> A = rand(3,1,2);
% >> sz = size(A)
% sz =
% 
%      3     1     2
%
% >> B = getargnout(2,@find,(sz>1))
% B =
% 
%      1     3
%
% In this case, getargnout will produce the same output as C in
% >> [~,C] = find(sz>1).
%
% 

if length(N)>1
    nMax = max(N(:));
else
    nMax = N;
end
bigDims = find(size(N)>1);
assert(length(bigDims)<=1,'N cannot be a matrix in any two dimensions. N must be either a scalar or a 1 x 1 x ... x n vector.');
N = N(:);

[v{1:nMax}] = fcn(varargin{:});

varargout = cell(1,length(N));
for iOut=1:length(N);
    varargout{iOut} = v{N(iOut)};
end