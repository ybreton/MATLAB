function tab = mat2tab(mat,varargin)
% Converts a matlab matrix into a table according to which each dimension
% is a predictor and each dimension's subscript is the predictor's value.
% tab = mat2tab(mat)
% where     tab         is nElements x nDims+1 matrix of values (column 1)
%                           and dimension subscripts (columns 2:end)
% 
%           mat         is an n x m x ... x p (nElements total) matrix of
%                           values
% tab = mat2tab(mat,'dimnames',{'Dim1','Dim2',...,'Dim_n'})
% where     tab         is nElements x nDims+1 matrix of values (column 1)
%                           and dimension subscripts (columns 2:end)
% 
%           mat         is a structure with fields
%              .HEADER
%                       is a 1 x nDims+1 cell array of column headers
%              .DATA    is an nElements x nDims+1 matrix of values (column
%                           1) and dimension subscripts (columns 2:end)
% 

sz = size(mat);
dimnames = {};
varname = inputname(1);
removeNaNs = true;
process_varargin(varargin);
if iscell(varname)
    varname = varname{1};
end

if ~isempty(dimnames)
    assert(length(dimnames)==length(sz),'dimnames must have one entry for each dimension.');
end

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
Y = mat(:);

if removeNaNs
    idx = ~isnan(Y);
else
    idx = true(numel(Y),1);
end
header = cell(1,1+length(dimnames));
header{1} = varname;
header(2:length(dimnames)+1) = dimnames;
data = [Y(idx) X0(idx,:)];

if ~isempty(dimnames)
    tab.HEADER = header;
    tab.DATA = data;
else
    tab = data;
end