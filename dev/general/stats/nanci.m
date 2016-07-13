function [Hi,Lo] = nanci(x,FLAG,DIM,ALPHA)
% ci = nanci(x)
% ci = nanci(x,DIM)
% ci = nanci(x,FLAG,DIM)
% ci = nanci(x,FLAG,DIM,ALPHA)
% where
%           ci      is the excursion of the confidence bound, how far up from
%                       the mean the upper bound is or how far down from the
%                       mean the lower bound is.
%
%           FLAG    is a true/false boolean specifying whether to use
%                       sample statistics (default, false) or
%                       population parameters (true) in the calculation.
%           DIM     is the dimension along which to get the confidence
%                       estimates. If not specified, nanci will operate
%                       along the first non-singleton dimension.
%           ALPHA   is the level at which to evaluate the confidence
%                       interval, between 0 and 1. Any values above 0.5
%                       will automatically be adjusted to 1-ALPHA.
%
% [Hi,Lo] = nanci(...)
% where     
%           Hi      is the upper bound of the confidence interval
%                       (m+tcrit*sem), and
%           Lo      is the lower bound of the confidence interval
%                       (m-tcrit*sem).
%
%
sz = size(x);
if all(sz==1)
    nonsingleton = true(1,size(sz));
else
    nonsingleton = sz>1;
end

if nargin<4
    ALPHA = 0.05;
end
if ALPHA>0.5
    ALPHA = 1-ALPHA;
end

if nargin<2
    FLAG = find(nonsingleton,1,'first');
end
if nargin<3
    DIM=FLAG;
    FLAG=false;
end

m = nanmean(x,DIM);
s = nanstderr2(x,FLAG,DIM);
n = sum(~isnan(x),DIM);
df = n-1;
tcrit = tinv(1-ALPHA/2,df);

ci = tcrit.*s;

if nargout<2
    Hi = ci;
end
if nargout>1
    Hi = m+ci;
    Lo = m-ci;
end