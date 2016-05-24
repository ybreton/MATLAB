function [I,B,C] = diagStripe(A,width,varargin)
% returns a stripe of +/- r cells around the diagonal.
% I = diagStripe(A,width)
% where     I       is m x n logical indicating diagonal stripe elements.
%           
%           A       is m x n matrix
%           width   is width of diagonal stripe (3 would be diagonal +/- 2)
%
%
% [I,B] = diagStripe(A,r)
% where     B       is m x n matrix containing diagonal stripe elements of
%                       A and NaNs elsewhere.
%
% [I,B,C] = diagStripe(A,r)
%           C       is m x n matrix containing off-diagonal stripe elements
%                       of A and NaNs elsewhere.
%
% e.g.:
%
% A = [1  2  3  4  5
%      6  7  8  9  10
%      11 12 13 14 15
%      16 17 18 19 20
%      21 22 23 24 25]
%
% [I,B,C] = diagStripe(A,3)
%
% I =[1     1     0     0     0
%     1     1     1     0     0
%     0     1     1     1     0
%     0     0     1     1     1
%     0     0     0     1     1]
%
% B =[1     2     nan   nan   nan
%     6     7     8     nan   nan
%     nan   12    13    14    nan
%     nan   nan   18    19    20
%     nan   nan   nan   24    25]
%
% C =[nan   nan   3     4     5
%     nan   nan   nan   9     10
%     11    nan   nan   nan   15
%     16    17    nan   nan   nan
%     21    22    23    nan   nan]
%


process_varargin(varargin);
r = ((width-1)/2);

idxR = repmat((1:size(A,1))',1,size(A,2));
% number each row
idxC = repmat(1:size(A,2),size(A,1),1);
% number each column

I = idxR<=idxC+r & idxR>=idxC-r;
% diagonal stripe is where each row is at most column +/- r.

B = nan(size(A));
C = B;
B(I) = A(I);
C(~I) = A(~I);