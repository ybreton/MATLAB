function c = enumeratePairwiseComparisons(n,varargin)
% For a list of size n, enumerates all pairwise comparisons of the elements
% of the list.
% c = enumeratePairwiseComparisons(n)
% where     c           is 2 x 2 x nC2 array of comparisons,
%                           with c(:,:,k) the two possible pairwise
%                           comparisons, e.g. [1 vs 2; 2 vs 1]
%
%           n           is the number of groups for which to enumerate
%                           pairwise comparisons.
%
% c = enumeratePairwiseComparisons(n,'uniqueComparisons',true)
% where     c           is 2 x nC2 array of comparisons,
%                           with c(:,k) the single non-repeating pairwise
%                           comparison, e.g. [1 vs 2]
%
% example:
% The pairwise comparisons in a list of 2 elements should be a single set
% of 2 redundant comparisons: 1 vs 2 and 2 vs 1. To check,
% >> c = enumeratePairwiseComparisons(2)
% c =
% 
%      1     2
%      2     1
% 
% Each column has the elements of the list of size 2 that form a (redundant)
% pairwise comparison.
%
% example 2:
% The pairwise comparisons in a list of 3 elements should be 3 sets of 2
% redundant comparisons: 1 vs 2 and 2 vs 1; 1 vs 3 and 3 vs 1; and 2 vs 3
% and 3 vs 2.
% >> c = enumeratePairwiseComparisons(3)
% c(:,:,1) =
% 
%      1     2
%      2     1
% 
% 
% c(:,:,2) =
% 
%      1     3
%      3     1
% 
% 
% c(:,:,3) =
% 
%      2     3
%      3     2
% 
% Each column has the elements of the list of size 3 that form a (redundant)
% set of pairwise comparisons. Each element of dimension 3 forms a unique
% set set of pairwise comparisons.
%
% example 3:
% There are 3 unique pairwise comparisons in a list of 3 elements: 1 vs 2,
% 1 vs 3, and 2 vs 3, assuming that their converses are identical. 
% >> c = enumeratePairwiseComparisons(3,'uniqueComparisons',true)
% c =
% 
%      1     1     2
%      2     3     3
%
% Each column has the elements of the list of size 3 that form unique
% pairwise comparisons.
%
uniqueComparisons = false;
process_varargin(varargin);

% number of pairwise comparisons is kC2.
nComps = nchoosek(n,2);

c = nan(2,2,nComps);

iComp=1;
for g1=1:n-1
    for g2=g1+1:n
        c(1,1,iComp) = g1;
        c(1,2,iComp) = g2;
        c(2,1,iComp) = g2;
        c(2,2,iComp) = g1;
        
        iComp=iComp+1;
    end
end

if uniqueComparisons
    c = squeeze(c(:,1,:));
end