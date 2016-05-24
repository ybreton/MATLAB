function [p,table,stats,terms,means,errors,Ns] = anovan2(Y,varargin)
% Conducts an n-way analysis of variance using the dimensions of Y as
% predictors. NaN values are ignored.
% 
% [p,table,stats,terms,means,errors,Ns] = anovan2(Y)
% where     p       is a vector of p-values for the ANOVA,
%           table   is a source table for the ANOVA,
%           stats   is a structure with ANOVA statistics,
%           terms   returns the main and interaction terms used in the
%                       ANOVA computations,
%           means   is a m x n x ... x p matrix of cell means,
%           errors  is a m x n x ... x p matrix of cell standard errors,
%           Ns      is a m x n x ... x p matrix of cell sample sizes,
%
%           Y       is a m x n x ... x p x N matrix of dependent values,
%                       where each dimension corresponds to one independent
%                       variable, and each index of the dimension is a
%                       separate level. The last dimension of Y is assumed
%                       to be the replicates.
%
% [p,table,stats,terms,means,errors,Ns] = anovan2(Y, replicates)
% where     replicates  is the dimension(s) along which replicates of the
%                       dependent variable are found.
%
% [p,table,stats,terms,means,errors,Ns] = anovan2(Y,'covariate',C)
% where     C       is a m x n x ... x p x N matrix with values of a single
%                       continuous (covariate) predictor, or
%           C       is a Ncov cell array of m x n x ... x p x N matrices with
%                       values of each covariate in each cell of the cell
%                       array.
%
% Examples:
%   ONEWAY ANOVA--
%   Suppose we have obtained 4 replicates of a dependent variable (for
%   example, at most 4 subjects to a group) for each of 3 levels of an
%   independent variable called "Rows", stored in matrix Y.
% Y = randn(3,4);
%   The ANOVA of the effect of Rows on Y will be returned by
% anovan2(Y,'varnames',{'Rows'})
% 
%   TWO-WAY ANOVA--
%   Suppose we have obtained 5 replicates of a dependent variable (say, 5
%   subjects per group) for each of 3 levels of the independent variable
%   "Rows" and for each of the 4 levels of the independent variable
%   "Columns", stored in matrix Y.
% Y = randn(3,4,5);
%   Entering
% p = anovan2(Y,'model','full','varnames',{'Rows' 'Columns'});
%   assumes that Y is a dependent variable whose values were collected for
%   3 different levels of one independent variable (dimension 1, "Rows")
%   at 4 different levels of a separate independent variable (dimension 2,
%   "Columns"), with 5 different replicates (dimension 3) each. Will return
%   the p-value associated with the main effect of dimension 1, the main
%   effect of dimension 2, and their interaction.
%
%   TWO-WAY ANOVA WITH 1 COVARIATE--
%   Suppose we have obtained 5 replicates of a dependent variable for each
%   of 3 levels of the independent variable "Rows" and each of 4 levels of
%   the independent variable "Columns", stored in matrix Y, as well as a
%   single covariate called "Cov", stored in matrix C.
% Y = randn(3,4,5);
% C = randn(3,4,5);
%   Entering
% p = anovan2(Y,'covariate',C,'model','full','varnames',{'Rows' 'Columns'});
%   assumes that Y is a dependent variable whose values were collected for
%   3 different levels of the independent variable "Rows" and 4 different
%   levels of the independent variable "Columns", along with a continuous
%   covariate that was collected alongside each observation. Will return
%   the p-value associated with the main effect of "Rows", the main effect
%   of "Columns", the main effect of the covariate "Cov", and the
%   Rows*Columns, Rows*Cov, Columns*Cov, and Rows*Columns*Cov interaction.
%
%   THREE-WAY ANOVA WITH 2 COVARIATES--
%   Dimension 1 is IV "Rows" with 3 levels, Dimension 2 is IV "Columns"
%   with 4 levels, Dimension 3 is IV "Pages" with 5 levels, and Dimension 4
%   is replicates (6 cases in each combination of Row/Column/Page) of the
%   dependent variable, stored in Y. Each observation is also associated
%   with 2 covariates, stored in each cell of cell array C.
% Y = randn(3,4,5,6);
% C{1} = randn(3,4,5,6);
% C{2} = randn(3,4,5,6);
% p = anovan2(Y,'covariate',C,'model','full','varnames',{'Rows' 'Columns' 'Pages'});
%   Assumes that Y is a dependent variable whose values were collected 6
%   times for 3 different levels of the independent variable "Rows", each
%   of the 4 different levels of the independent variable "Columns", and
%   each of the 5 different levels of the independent variable "Pages",
%   along with 2 continuous covariates that were collected alongside each
%   observation. Will return the p-value associated with the main effect of
%   "Rows", the main effect of "Columns", the main effect of "Pages", the
%   main effect of the covariate "Cov1", the main effect of the covariate
%   "Cov2", and all interactions.
%
% OPTIONAL ARGUMENTS:
% ******************
% These arguments are the same as in anovan. Please look up the anovan
% documentation for these optional arguments.
% alpha             (default 0.05)
%               Type-I (false-positive) error rate. Must be between 0 and
%               1.
% display           (default 'on')
%               Display ANOVA table. Values can be 'on' or 'off'.
% model             (default 'linear')
%               ANOVA model to test. See anovan documentation for valid
%               values of 'model'.
% nested            (default [])
%               For use with mixed designs (e.g., subjects nested in
%               groups); Matrix where Mij==1 indicates that dimension i is
%               nested in j, Mij==0 indicates that dimension i is not
%               nested in j.
% random            (default [])
%               For use with random (e.g., subject) factors. 
% sstype            (default 3)
%               Type of sums of squares to use. See anovan documentation
%               for valid values of sstype (1,2,3,h) and their meaning.
% varnames          (default X1,...,Xi,...,Xn)
%               Cell array of strings with the names of each dimension's
%               factor. If varnames has one value for each dimension of Y,
%               the replicates dimensions will be removed.
%               Covariates will be identified in order as 
%               Cov1,...,Covj,...,Covm.
%

sz = size(Y);

% Identify if there is a replicates vector
if mod(length(varargin),2)==1
    replicates=varargin{1};
    varargin = varargin(2:end);
else
    replicates=length(sz);
end
for iRep=1:length(replicates)
    fprintf('\nReplicates along dimension %d',replicates(iRep));
end
fprintf('\n')
keep = 1:length(sz);
keep = keep(all(repmat(keep(:),[1 length(replicates)])~=repmat(replicates(:)',[length(keep) 1]),2));

% Optional arguments
alpha = 0.05;
covariate = [];
display = 'on';
model = 'linear';
nested = zeros(length(sz));
random = [];
sstype = 3;
varnames = cell(1,length(size(Y)));
for iX=1:length(sz)
    varnames{iX} = sprintf('X%d',iX);
end
process_varargin(varargin);

% Check arguments in:
% varnames only contains IV names or dimension names for Y
if length(varnames)==length(sz);
    varnames = varnames(keep);
elseif length(varnames)>length(sz) || length(varnames)<length(keep)
    error('varnames must have either one entry for each of the dimensions of Y, or one entry for each IV to be used in Y.')
end
% 0>alpha>1
assert(alpha>0&&alpha<1,'alpha must be between 0 and 1.')
% each covariate is same size as Y
if ~isempty(covariate)
    if ~iscell(covariate)
        assert(all(size(covariate)==size(Y)),'covariate must be same size as Y.')
    else
        for iC=1:numel(covariate)
            assert(all(size(covariate{iC})==size(Y)),sprintf('covariate %d must be same size as Y.',iC))
        end
    end
end
% display is either on or off
assert(strcmpi(display,'on')||strcmpi(display,'off'),'display must be either on or off.');
if ~isempty(random)
    assert(all(random<=length(sz))&&all(random>0),'random must be a vector of dimensions with random (non-fixed; e.g., subject) factors.')
end

% keep only non-replicate IV dimensions
nested = nested(keep,keep);
if ~isempty(random)
    random = random(any(repmat(random(:),[1 length(keep)])==repmat(keep(:)',[length(random) 1]),2));
end

Y0 = Y(:);
X0 = nan(prod(sz),length(sz));
for iX=1:length(sz)
    lvls = 1:sz(iX);
    rs = ones(1,length(sz));
    rp = sz;
    rs(iX) = sz(iX);
    rp(iX) = 1;
    x = repmat(reshape(lvls,rs),rp);
    X0(:,iX) = x(:);
end
X0 = X0(:,keep);
for iX=1:size(X0,2)
    fprintf('\nIV%d along dimension %d: %s',iX,keep(iX),varnames{iX})
end
fprintf('\n')

if ~isempty(covariate)
    disp('Processing covariates...')
    if iscell(covariate)
        Nc = length(covariate);
        C = nan(length(Y0),Nc);
    else
        C = nan(length(Y0),1);
        Nc = 1;
    end
    k = size(X0,2);
    continuous = k+1:k+Nc;
    
    if iscell(covariate)
        for iC=1:numel(covariate)
            c = covariate{iC};
            C(:,iC) = c(:);
            varnames{k+iC} = sprintf('Cov%d',iC);
        end
    else
        C = covariate(:);
        varnames{k+1} = sprintf('Cov');
    end
    X0 = [X0 C];
    nested0 = zeros(size(X0,2));
    nested0(1:size(nested,1),1:size(nested,2)) = nested;
    nested = nested0;
else
    continuous = [];
end
idx = ~isnan(Y0);
Y0 = Y0(idx);
X0 = X0(idx,:);

[p,table,stats,terms] = anovan(Y0,X0,'alpha',alpha,'continuous',continuous,'display',display,'model',model,'nested',nested,'random',random,'sstype',sstype,'varnames',varnames);

if nargout>4
    uniqueX = unique(X0,'rows');
    msz = sz;
    msz(replicates) = 1;
    means = nan(msz);
    errors = nan(msz);
    Ns = nan(msz);
    for iX=1:size(uniqueX,1)
        sub = ones(1,length(sz));
        for iV=1:size(uniqueX,2)
            sub(keep(iV)) = uniqueX(iX,iV);
        end
        idx = all(repmat(uniqueX(iX,:),[size(X0,1) 1])==X0,2);
        mY = nanmean(Y0(idx));
        nY = sum(double(~isnan(Y0(idx))));
        sY = nanstd(Y0(idx))./sqrt(nY);

        str1 = ['means('];
        str2 = ['errors('];
        str3 = ['Ns('];
        for iDim=1:length(sub)
            str1 = [str1 num2str(sub(iDim)) ','];
            str2 = [str2 num2str(sub(iDim)) ','];
            str3 = [str3 num2str(sub(iDim)) ','];
        end
        str1 = [str1(1:end-1) ') = mY;'];
        str2 = [str2(1:end-1) ') = sY;'];
        str3 = [str3(1:end-1) ') = nY;'];
        eval(str1);
        eval(str2);
    end
end