function s = tab2struc(tab,cols,varargin)
% Converts a table with headers (tab.Header/tab.Header.Col) and data
% (tab.Data) to a structure array with fields for each column in the table.
% Data in the structure are arranged as 
% cols(1) x cols(2) x ... x cols(3) x nReplicates
% arrays
% with fields of the structure for each column in the table.
% s = tab2struc(tab,cols)
% where     s           is a structure with fields
%            .DimA, .DimB, ...
%                       for all numerical dimensions, their numerical
%                       values
%            .DimX.Names, .DimY.Names, ...
%                       for all non-numerical dimensions, the identifier
%                       strings involved
%            .DimX.Level1, .DimX.Level2, ...
%                       for all non-numerical dimensions, booleans
%                       indicating that an element corresponds to  that
%                       level of the dimension
%            .Field1, .Field2, ...
%                       for all numerical columns, values of the column
%            .Field101.Names, Field102.Names, ...
%                       for all non-numerical dimensions, the identifier
%                       strings involved
%            .Field101.Level, ...
%                       for all non-numerical dimensions with fewer than
%                       nBool (default 10) unique values, booleans
%                       indicating that an element corresponds to that
%                       level of the column
%
% OPTIONAL ARGUMENTS:
% ******************
% nBool         (default 10)
%       max number of level booleans for a non-numerical factor.
%
% Example:
% Begin by creating a table with columns Col1, Col2, Col3, 
%
% >> tab.Header = {'Col1' 'Col2' 'Col3'}; 
% 
% and for which the data are [1 2 3 3] for column 1;
%                            [2 3 4 3] for column 2; and
%                            [3 4 5 3] for column 3.
% 
% >> tab.Data = [1 2 3; 
%             2 3 4; 
%             3 4 5; 
%             3 3 3];
%
% Create a structure array where the rows of each field are values of
% column 1, the columns of each field are values of column 2, and each
% field of the structure array is a column of the table.
%
% s = tab2struc(tab,[1 2])
% Column 1: Col1
% Column 2: Col2
% Column 3: Col3
% Dimension 1: Col1
% Dimension 2: Col2
% 
% s = 
% 
%       dimNames: {'Col1'  'Col2'}
%      dimLevels: {[3x1 double]  [3x1 double]}
%     dimNumeric: [1 1]
%           Col1: [3x3 double]
%           Col2: [3x3 double]
%           Col3: [3x3 double]
% 
% s.Col1 = [     1     1     1
%                2     2     2
%                3     3     3 ]
%
% s.Col2 = [     2     3     4
%                2     3     4
%                2     3     4 ]
%
% s.Col3 = [     3   NaN   NaN
%              NaN     4   NaN
%              NaN     3     5 ]
%
%

nBool = 10;
process_varargin(varargin);

Header = tab.Header;
if isstruct(Header)
    if isfield(Header,'col');
        Header = Header.col;
    end
end
Data = tab.Data;

levels = cell(1,length(Header));
datNum = nan(size(Data));
numeric = true(1,length(Header));
for iCol=1:length(Header)
    varName = Header{iCol};
    varName = parseVarName(varName);
    disp(['Column ' num2str(iCol) ': ' varName])
    Header{iCol} = varName;
    
    cdat = Data(:,iCol);
    if iscell(cdat)
        empty = cellfun(@isempty,cdat);
        num = cellfun(@isnumeric,cdat);
        let = cellfun(@ischar,cdat);
        if sum(num(~empty))>sum(let(~empty))
            cdat = can2mat(cdat);
        end
    end
    if iscell(cdat)
        [uniqueX,~,ic] = unique(cdat(~empty));
        if any(empty)
            uniqueX{end+1} = '';
            datNum(empty,iCol) = max(ic)+1;
        end
        levels{iCol} = uniqueX;
        numeric(iCol) = false;
        datNum(~empty,iCol) = ic;
    else
        idnan = isnan(cdat);
        [uniqueX,~,ic] = unique(cdat(~idnan));
        if any(idnan)
            uniqueX(end+1) = nan;
            datNum(idnan,iCol) = max(ic)+1;
        end
        levels{iCol} = uniqueX;
        datNum(~idnan,iCol) = ic;
    end
end

uniqueRows = unique(datNum(:,cols),'rows');
reps = ones(size(datNum,1),1);
for iRow=1:size(uniqueRows,1)
    comp = repmat(uniqueRows(iRow,:),size(datNum,1),1);
    id = all(comp==datNum(:,cols),2);
    r = 1:sum(id);
    
    reps(id) = r;
end
datNum = [datNum reps];
cols = [cols size(datNum,2)];
Header{end+1} = 'Replications';
levels{end+1} = 1:max(datNum(:,end));
numeric(end+1) = true;

sz = max(datNum(:,cols),[],1);
idIn = sz>1;

cols = cols(idIn);
sz = sz(idIn);

datCols = 1:size(datNum,2)-1;
datCols = datCols(~ismember(datCols,cols));

dims = length(sz);

s.dimNames = Header(cols);
s.dimLevels = levels(cols);
s.dimNumeric = numeric(cols);
for iDim=1:dims
    
    dimName = s.dimNames{iDim};
    disp(['Dimension ' num2str(cols(iDim)) ': ' dimName])
    
    rs = ones(1,dims);
    rs(iDim) = sz(iDim);
    rp = sz;
    rp(iDim) = 1;
    
    tm = repmat(reshape(1:sz(iDim),rs),rp);
    
    if s.dimNumeric(iDim)
        s.(dimName) = s.dimLevels{iDim}(tm);
    else
        s.(dimName).Names = s.dimLevels{iDim}(tm);
        for iLevel=1:length(s.dimLevels{iDim})
            dimLevel = s.dimLevels{iDim}{iLevel};
            if isempty(dimLevel)
                dimLevel = 'Empty';
            end
            s.(dimName).(dimLevel) = tm==iLevel;
        end
    end
end

evalStr = '';
for iDim=1:dims
    evalStr = [evalStr 'datNum(:,' num2str(cols(iDim)) '),'];
end
evalStr = evalStr(1:end-1);
I = eval(['sub2ind(sz,' evalStr ')']);

for iField=1:length(datCols)
    iCol = datCols(iField);
    
    fname = Header{iCol};
    
    if numeric(iCol)
        s.(fname) = nan(sz);
        s.(fname)(I) = levels{iCol}(datNum(:,iCol));
    else
        s.(fname).Names = cell(sz);
        s.(fname).Names(I) = levels{iCol}(datNum(:,iCol));
        if length(levels{iCol})<nBool
            for iLevel=1:length(levels{iCol})
                dimLevel = levels{iCol}{iLevel};
                if isempty(dimLevel)
                    dimLevel = 'Empty';
                end
                dimLevel = parseVarName(dimLevel);
                
                s.(fname).(dimLevel) = datNum(I,iCol)==iLevel;
            end
        end
    end
    
end

function varNameOut = parseVarName(varNameIn)

    idAlpha = regexpi(varNameIn,'[a-z]');
    idNum = regexpi(varNameIn,'[0-9]');
    idAll = 1:length(varNameIn);
    idAlphaNum = sort([idAlpha(:)' idNum(:)']);
    idNonAlphaNum = idAll(~ismember(idAll,idAlphaNum));
    
    varNameOut = varNameIn;
    varNameOut(idNonAlphaNum) = '_';
    if ~isvarname(varNameOut);
        varNameOut = ['Col' varNameOut];
    end