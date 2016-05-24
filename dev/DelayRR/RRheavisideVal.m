function predY = RRheavisideVal(threshold,x,varargin)
% Evaluates the heaviside function with threshold at threshold for each
% value of x.
% predY = RRheavisideVal(threshold,x)
% where     predY       is the m x n matrix of predicted stay/go values
%
%           threshold   is the scalar threshold value of x,
%           x           is the m x n matrix of delay (predictor) values for
%                           the heaviside function.
%

assert(numel(x)==1|size(threshold)==size(x),'threshold must be scalar or same size as x.');

predY = nan(size(x));
predY(x<threshold) = 1;
predY(x>threshold) = 0;
predY(x==threshold) = 0.5;