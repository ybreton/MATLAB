function Y = sigmoidval(B,X)
% Evaluates a sigmoid of the form
% y = 1/(1+e^-(b*(x-a)))
% where b is a vector of slopes for each dimension of x, and a is a vector
% of locations (thresholds) for each dimension of x.
% Y = sigmoidval(B,X)
% where     Y       is the value of the sigmoid,
%
%           B       is a 2 x nDim array with locations (thresholds) and
%                       slopes of the sigmoid along each dimension in X.
%                       B(1,:) is the location of the sigmoid along each
%                       dimension in x, or the x point at which y=0.5.
%                       B(2,:) is the slope of the sigmoid along each
%                       dimension in x, or the odds increase for a unit
%                       increase in x.
%           X       is an n x nDim array of predictor values for the
%                       sigmoid.

assert(mod(numel(B),1)==0,'B must have an even number of parameters!')
B = reshape(B,2,numel(B)/2);

assert(size(X,2)==size(B,2),'X and B must have the same number of columns.')

a = B(1,:);
b = B(2,:);
n = size(X,1);
e = exp(1);
X = X - repmat(a(:)',[n 1]);
Z = X*b(:);
Y = 1./(1+e.^(-Z));