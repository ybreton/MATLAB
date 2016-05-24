function y = scaled_logit(x,b,r,const)
% Calculates a scaled logit function of the form
% y = (1/(1+e^-(x*b)))*(max-min)+min
% where     x is a column matrix of predictors,
%           b is a column vector of slopes for those predictors
%           max is the maximum asymptote of the logit (Default 1)
%           min is the minimum asymptote of the logit (Default 0)
% y = scaled_logit(x,b,r,const)
%           r is the range of the scaled logit (optional, default [1 0])
%           const is a logical indicating whether to include a constant in
%           z = x*b, where y = (1/(1+e^-z))*(r(2)-r(1))+r(1).
%
if nargin < 4
    const = true;
end
if nargin < 3
    r = [1 0];
end
r = sort(r,'descend');

e = exp(1);
if const
    X = [ones(size(x,1),1) x];
else
    X = x;
end
    
z = X*b;
yScaled = 1./(1+e.^-z);
y = (yScaled*(r(1)-r(2)))+r(2);
