function [gmobj,mus,Sigmas,taus] = gmmfit(x,k,varargin)
% Wrapper for fitting mixture of gaussians, sorting components by mean.
% [gmobj,mus,Sigmas,taus] = gmmfit(x,k)
% where         gmobj is a gaussian mixture distribution object,
%               mus is a k x d matrix of k component means for d dimensions
%               Sigmas is a covariance matrix
%               taus is a 1 x k 
% and
%               x is a n x d matrix of observations
%               k is the number of components to fit.
%
% if k is omitted or empty, gmmfit will find the BIC-best number of
% components by fitting increasingly many until the BIC decreases by less
% than 2 or increases.
%
% OPTIONAL:
% ~~~~~~~~
% Regularize    add a regularization constant to covariance matrix (default eps)
% CovType       type of covariance matrix (default full)
% SharedCov     shared covariance between components (default false)
% Start         method of starting values (default randSample)
% Replicates    number of times to repeat process (default 1)
% Options       statset options structure (default is gmdistribution.fit default)
% Sorting       dimensions to sort on (default is 1 to d, in order, ascending)
%
% YAB 2016-06-15: Added ability to automatically search for best k if k is omitted or
% empty.

if size(x,1)==1 & any(size(x)>1);
    x = x';
end 
d = size(x,2);
Regularize = eps;
Options = statset('display','off','maxIter',500,'tolFun',1e-6);
CovType = 'full';
SharedCov = false;
Start = 'randSample';
Replicates = 1;
Sorting = [1:d];
BICthresh = 2;
process_varargin(varargin);

if nargin<2
    disp('Finding BIC-best GMM.')
    k = [];
end

if ~isempty(k)
    gmm = gmdistribution.fit(x,k,'Regularize',Regularize,'Options',Options,'CovType',CovType,'SharedCov',SharedCov,'Start',Start,'Replicates',Replicates);
else
    k = 1;
    disp(['Fitting ' num2str(k) ' components.'])
    gmm = gmdistribution.fit(x,k,'Regularize',Regularize,'Options',Options,'CovType',CovType,'SharedCov',SharedCov,'Start',Start,'Replicates',Replicates);
    BICnew = gmm.BIC;
    disp(['BIC: ' num2str(BICnew)])
    deltaBIC = inf;
    while deltaBIC>BICthresh
        k = k+1;
        BICold = BICnew;
        disp(['Fitting ' num2str(k) ' components.'])
        gmm = gmdistribution.fit(x,k,'Regularize',Regularize,'Options',Options,'CovType',CovType,'SharedCov',SharedCov,'Start',Start,'Replicates',Replicates);
        BICnew = gmm.BIC;
        disp(['BIC: ' num2str(BICnew)])
        deltaBIC = BICold - BICnew;
    end
    k = k-1;
    disp(['BIC-best GMM: ' num2str(k) ' components.'])
    gmm = gmdistribution.fit(x,k,'Regularize',Regularize,'Options',Options,'CovType',CovType,'SharedCov',SharedCov,'Start',Start,'Replicates',Replicates);
end

mus = gmm.mu;
[mus,idSort] = sortrows(mus,Sorting);

Sigmas = gmm.Sigma;
if size(Sigmas,3)==k
    % d x d x k or 1 x d x k
    Sigmas = Sigmas(:,:,idSort);
end

taus = gmm.PComponents;
taus = taus(idSort);

gmobj = gmdistribution(mus,Sigmas,taus);