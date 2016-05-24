function y = heavisideval(threshold,x,varargin)
% Evaluates the heaviside function with threshold at "threshold" for each
% value of x.
% y = heavisideval(threshold,x)
% where     predY       is the m x n matrix of predicted boolean values
%
%           threshold   is the 1 x 1 scalar threshold value of x, or
%                              m x n matrix of thresholds for each element
%                              of x
%           x           is the m x n matrix of x (predictor) values for
%                           the heaviside function.
%
% OPTIONAL ARGUMENTS:
% ******************
% slope         (-1)
%   Sign of the slope of the Heaviside function. Negative means that when
%   y=1, x<th. Positive means that when y=1, x>th.
%

slope = -1;
process_varargin(varargin);

assert(numel(threshold)==1|all(size(threshold)==size(x)),'threshold must be scalar or same size as x.');

if sign(slope)<0
    y = nan(size(x));
    y(x<threshold) = 1;
    y(x>threshold) = 0;
    y(x==threshold) = 0.5;
elseif sign(slope)>0
    y = nan(size(x));
    y(x>threshold) = 1;
    y(x<threshold) = 0;
    y(x==threshold) = 0.5;
else
    y = ones(size(x))*0.5;
end