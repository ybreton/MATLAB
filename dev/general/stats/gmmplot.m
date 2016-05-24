function [ph,y] = gmmplot(gmobj,x,varargin)
% plots the 1D gaussians indicated in gmdistribution object gmobj at x values
% indicated in x.
% The function plots (P[x+tolX<=X|gaussian_i]-P[x-tolX<=X|gaussian_i])*P[gausian_i], 
% the cdf evaluated just above x minus the cdf evaluated just below x, for
% every x. By default, the tolerance tolX is halfway between unique x
% values.
%
% ph = gmmplot(gmobj,x)
%   where       ph      is a vector of handles to the plot objects for each
%                           of the k components of the GMM.
%   
%               gmobj   is a gmdistribution object specifying the Gaussian
%                           Mixture Model with k components,
%               x       is a n x 1 vector of x values for plotting probability.
%
% [ph,y] = gmmplot(gmobj,x)
%   where       y       is a n x k matrix of y values plotted, for each of
%                           the k components at each of the n values in x.
%
% OPTIONAL ARGUMENTS:
% ******************
% tolX      (default: half distance between unique x values)
% plotFlag  (default: true)
%
% e.g.:
% gmobj = gmmfit([randn(500,1); randn(250,1)/2+1],2)
% x = -3:0.2:3
% gmmplot(gmobj,x) will plot the two gaussians, with the height of each
% gaussian i equal to
% y_i = (normcdf(x+0.2/2,mu_i,sigma_i)-normcdf(x-0.2/2,mu_i,sigma_i))*tau_i.
%
%

assert(gmobj.NDimensions==1,'gmdistribution object must be unidimensional.')
uniqueX = unique(x);
dX = diff(uniqueX);
dX = [dX(1);dX(:)];
tolX = nan(size(x));
for iX = 1 : length(uniqueX)
    idX = uniqueX(iX)==x;
    tolX(idX) = dX(iX);
end
plotFlag=true;
process_varargin(varargin);
x = unique(x);

pBin = gmmPBin(gmobj,x(:),'tolX',tolX(:));

if plotFlag
    ph=plot(x,pBin,'-');
end

if nargout>1
    y = pBin;
end