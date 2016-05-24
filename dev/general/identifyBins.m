function [I,bin] = identifyBins(x,bin,varargin)
% Returns a list of bins to which each observation in x belongs. Bins
% extend halfway in both directions to the next bin. The lowest and highest
% bins extend symmetrically in both directions.
%
% I = identifyBins(x,bin)
% [I,bin] = identifyBins(x,bin)
% where     I           is m x n x ... x p matrix of bin assignments 1
%                           through k. Identifier k+1 represents
%                           observations in x that are above the highest
%                           bin.
%
%           x           is m x n x ... x p matrix of x values,
%           bin         is vector of k bin centers.
%
%
% OPTIONAL ARGUMENTS:
% ******************
% edges     (default false)     bin is a vector of bin edges.
%                               identifier k represents observations in x
%                               at or above highest edge.
% left      (default true)      left-handed bin interval: x is within bin
%                               iff binLo<=x<binHi.
%                               When left is false, x is within bin iff
%                               binLo<x<=binHi.
%
% identifier 0 represents observations in x that are below the lowest edge.

edges = false;
left = true;
process_varargin(varargin);

bin = bin(:);
bin = sort(bin(~isnan(bin(:))&~isinf(bin(:))));

if edges
    binLo = bin(1:end-1);
    binHi = bin(2:end);
    bin = binLo+(binHi-binLo)/2;
else
    binw = diff(bin);
    binw = [binw(1);binw(:)];
    
    binLo = bin-binw/2;
    binHi = bin+binw/2;
end

I = nan(size(x));
if left
    id0 = x<binLo(1);
    I(id0) = 0;
    for iB = 1 : length(binLo)
        idB = x>=binLo(iB) & x<binHi(iB);
        I(idB) = iB;
    end
    idInf = x>=binHi(end);
    I(idInf) = length(binLo)+1;
else
    id0 = x<=binLo(1);
    I(id0) = 0;
    for iB = 1 : length(binLo)
        idB = x>binLo(iB) & x<=binHi(iB);
        I(idB) = iB;
    end
    idInf = x>binHi(end);
    I(idInf) = length(binLo)+1;
end