function output = makeTable(varargin)
% Function creates a cell array from the columnn header-column values pairs
% to export multidimensional arrays to a table.
%
% output = makeTable('A', A, 'B', B, ...)
% where     output      is a nElement (n x m x ... x p) x nMatrices cell
%                           array of values arranged as a table.
%
%           'A'         is a string specifying the column header,
%           A           is a n x m x ... x p matrix of column values.
%
% Matrices containing column values must have identical size. Output table
% will have prod(size(inputArrays)) rows, one for each array element, and
% nMatrices rows, one for each array. Arrays can be cells or numeric.
%
% To export the output cell array to a csv for use in other programs, use
% cell2csv(filename, output, ', ')
% to produce a comma-space separated text file with the entries, available
% from the MATLAB Central File Exchange by Sylvain Fiedler.
%
%
%

inputNames = varargin(1:2:end);
inputMats = varargin(2:2:end);

disp('Checking matrix sizes.')
dims = nan(length(inputMats),1);
for in = 1 : length(inputMats)
    % for each input matrix, what is its dimensionality and size?
    dims(in) = length(size(inputMats{in}));
    sz(in,1:dims(in)) = size(inputMats{in});
end
% Set size of input matrices, above their dimensionality, to size-1.
for in = 1 : length(dims)
    sz(in,dims(in)+1:end) = 1;
end
% Check to make sure all sizes, in all dimensions, are the same. If A is 
% n x m x 1 and B is n x m, they're also the same size.
for in = 1 : size(sz,1)
    id(in) = all(all(repmat(sz(in,:),[size(sz,1) 1])==sz,1)==1,2);
end
if any(~id)
    fprintf('Bad input matrix %s', inputNames(id))
end
assert(all(id));

% Main processing loop. Output has extra top row with column headers.
output = cell(prod(sz(1,:))+1,length(inputMats));
output(1,:) = inputNames(:)';
for in = 1 : length(inputMats)
    col = inputMats{in};
    disp(['Processing column ''' inputNames{in} '''']);
    if iscell(col)
        for element = 1 : numel(col);
            output{element+1,in} = col{element};
        end
    else
        for element = 1 : numel(col);
            output{element+1,in} = col(element);
        end
    end
end