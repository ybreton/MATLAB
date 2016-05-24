function RSS = LSerrfun(b,x,y,Fcn,varargin)
% Returns the residual sum of squares of y from the prediction of a
% function based on x, using parameters b.
% 
% This function is particularly useful in combination with fminsearch,
% fminbnd, and fmincon. Assuming that parameters (b) to function Fcn are
% fit such that the residual sum of squares between outcomes (y) and their
% prediction based on the predictors (x) is minimized, the statements
% fminsearch(@(b) LSerrfun(b,x,y,Fcn),...)
% fminbnd(@(b) LSerrfun(b,x,y,Fcn),...)
% fmincon(@(b) LSerrfun(b,x,y,Fcn),...)
% will accomplish the fit using no bounds on the parameters, upper and
% lower bounds on the parameters, or bounds and constraints on the
% parameters, respectively.
% 
% RSS = LSerrfun(b,x,y,Fcn)
% where     RSS         is a scalar of the residual sum of squares,
%                       Sum_i { (Y_i-Ypred_i)^2 }
%
%           b           is an array of the parameters that define the
%                       function
%           x           is an array of x-values (predictors) for the
%                       function
%           y           is a vector of y-values (outcomes) for the function
%           Fcn         is a handle to a function of the form
%                       F(b,x) = y
%                       that returns the predicted y value according to the
%                       corresponding x-values, based on a set of
%                       parameters in b.
%
% RSS = LSerrfun(b,x,y,Fcn,varargin)
% where     Fcn         is a handle to a function of the form
%                       F(b,x,varargin) = y
%                       that returns the predicted y value according to the
%                       corresponding x-values, based on a set of
%                       parameters in b.
%
% Usage Example:
% Fit the parameters (b) of the equation "y=1./(1+exp(-(b(1)+b(2)*x)))" to a
% data set with a single vector of outcomes (y) and a single vector of
% predictor values (x).
% We begin by initializing x and y, using 2 as intercept and 3 as slope for
% the true values of b and adding noise to the data in y.
% >> e = exp(1);
% >> x = randn(100,1);
% >> bTrue = [2; 3];
% >> y = (1./(1+e.^(-(bTrue(1)+bTrue(2).*x+randn(100,1)))));
% We next create a function called logitVal that implements the function we
% are trying to fit. Its arguments must be in the order (parameter,
% predictor), similar to glmval for general linear models.
% 
% function P = logitVal(b,x)
% e = exp(1);
% P = 1./(1+e.^(-(b(1)+b(2).*x(:))));
%
% The fitting process can now begin.
% b0 = fminsearch(@(b) LSerrfun(b,x,y,@logitVal), [0;0])
% will find the values of b such that 
% sum( (y - @logitVal(b,x)).^2 )
% is minimized, using the starting values of 0 for intercept and slope.
%
% This is accomplished using the fact that
% Sum_i { d_i.^2 } = Sum_i { d_i.*d_i } = dot(d,d)
% which means that any NaNs in the vector will return a NaN dot product.
% Ensure before attempting to fit that you have dealt with missing (NaN)
% values in a reasonable way for your application.
%
%

if nargin>4
    yPred = Fcn(b,x,varargin);
else
    yPred = Fcn(b,x);
end
RSS = dot(y(:)-yPred(:),y(:)-yPred(:));
