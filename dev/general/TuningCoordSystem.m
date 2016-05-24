function [varargout] = TuningCoordSystem(TC,varargin)
% Simple function to return the coordinate system grids used in tuning
% curves and Bayesian decoding.
%
% [d1,d2,...dn] = TuningCoordSystem(TC)
% where         d1, ..., dn     are nBin(1) x nBin(2) x ... x nBin(n)
%                                   matrices with entries representing the
%                                   bin centers of each dimension,
% 
%               TC              is a structure produced by TuningCurves.
%
% [d1,d2,...dn] = TuningCoordSystem(B)
% where         B               is a structure produced by
%                                   BayesianDecoding.
%
% TC = TuningCoordSystem(TC,'structure')
%                               will append the field Coords to the input
%                               structure TC.
%
% Usage examples:
%>>D1 = {sd.x 64}
%>>D2 = {sd.y 64}
%>>TC = TuningCurves(sd.S, {D1, D2}); %where D1 is a tsd of x positions and
%                                      D2 is a tsd of y positions
%>>B  = BayesianDecoding(Q,TC);       %where TC was produced from the above
%                                      TuningCurves function
%
% what is the decoding when rotating the maze?
%>>[X,Y] = TuningCoordSystem(B);
% returns 64x64 matrices of x positions X along dimension 1 and y positions
% Y along dimension 2. This information can then be used to rotate the
% matrix appropriately.
%
structure = false;
process_varargin(varargin);

dims = length(TC.nBin);
varargout = cell(1,dims);
for iOut = 1 : dims
    shape = ones(1,dims);
    shape(iOut) = TC.nBin(iOut);
    % spread this dimension along its actual dimension.
    binc = reshape(linspace(TC.min(iOut),TC.max(iOut),TC.nBin(iOut)),shape);
    % binc is the list of bin centers for this variable, arrayed along its
    % dimension. 
    % In other words, binc for dimension 1 is nBin(1) x 1 x 1 x ... x 1;
    %                 binc for dimension 2 is 1 x nBin(2) x 1 x ... x 1;
    % etc.
    nReps = TC.nBin;
    nReps(iOut) = 1;
    coords = repmat(binc,nReps);
    % coords is the list, replicated across the different dimensions, so
    % row 1 is 1 across all columns, layers, etc.
    varargout{iOut} = coords;
end

if nargout==1 && structure
    TC.Coords = varargout;
    varargout = TC;
end