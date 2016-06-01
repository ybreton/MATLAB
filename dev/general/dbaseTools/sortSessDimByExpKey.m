function [fdSorted,sdCA] = sortSessDimByExpKey(fd,D,varargin)
% Sorts the file directories in fd according to dimensions in D. Uses keys
% file and special keys to sort according to dimensions specified.
%
% fdSorted = sortSessDimByExpKey(fd)
% where     fdSorted        is a structure array with fields:
%
%                   .directories     
%                               a x b x ... x c cell array of file
%                               directories with session information
%
%                   .dimKey 
%                               a structure with fields
%                          .dimLevels 
%                               nLevels x nDims cell array of labels for each dimension.
%                          .dimList, 
%                               structure with m x n x ... x p ExpKeys field values.
%
% will sort sessions in fd according to rat and arbitrary chronological
% session number.
%
% fdSorted = sortSessDimByExpKey(fd,D)
% [fdSorted] = sortSessDimByExpKey(fd,D)
% where     D               is 1 x nDims cell array of ExpKeys field names
%                               (and special keys).
% 
% Special keys for dimension cell array:
% 'SSN'     (Final portion of fd string)
% 'Rat'     (Only R part of SSN string)
% 'RatNum' (Number part following R in R part of SSN string)
% 'Date'    (Only YYYY-MM-DD part of SSN string)
% 'Session' (Arbitrary session number for each rat, ordered
%           chronologically)
% 'SessNum' (Chronologically-ordered session number for each unique
%            combination of the other dimensions)
% 'Subj'    (Same as Rat except any A0 alphanumeric designation)
% 'SubjNum' (Same as RatNum except any A0 alphanumeric designation)
% 
% Session will ignore any non-Rat dimensions, so it represents the true
% rat's chronological session number. If the rat has 4 sessions, 2 of Drug
% and 2 of Saline, for example, the dimension of Session would be 4
% elements long, and would be empty for half the Drug and half the Saline
% conditions.
%
% SessNum will take into account all dimensions, so it represents the
% chronological session corresponding to the unique combination of all other
% dimensions. If the rat has 4 sessions, 2 of Drug and 2 of Saline, for
% example, the dimension of SessNum (assuming Condition is one of the
% dimensions) would be 2 elements long--one for each combination of rat and
% condition.
%
% Example:
% D = {'Rat' 'Condition' 'Session'};
% fdSorted = sortSessDimByExpKey(fd,D)
%
% will return an nRats x nConditions x nSessions cell array of directories in fd.directories,
% dimKey.dimLevels will list the rats corresponding to each row (dimKey(:,1)), the conditions
% corresponding to each column (dimKey(:,2)) and the session numbers
% corresponding to each page (dimKey(:,3));
% dimKey.dimList will contain the following fields:
%               .Rat, an nRats x nConditions x nSessions cell array of rats
%               .Condition, an nRats x nConditions x nSessions cell array
%                           of condition names
%               .Session, an nRats x nConditions x nSessions cell array of
%                         chronological session numbers for each rat
%
% [fdSorted,dimKey,sdCA] = sortSessDimByExpKey(fd,D)
%
% will return the fd's sorted by rat, the dimension labels corresponding to
% each level of the dimension, and sdCA will save the sd's in the same
% sorted order.
% 
% If multiple sessions have unique combinations of the dimensions specified
% in D (for example, D = {'Rat'}), an extra dimension of "replication
% number" will be added to the output.
%
% OPTIONAL ARGUMENTS:
% forceReplicates   (default: false)    if true, forces an extra dimension
%                                       of replication number even when
%                                       each value of fd has a unique
%                                       combination of the levels of each
%                                       dimension D.
%

forceReplicates = false;
if nargin<2
    D = {'Rat' 'Session'};
end
process_varargin(varargin);

tab = tabulateExpKeys(fd,D);
num = nan(size(tab));
for dim=1:length(D)
    dimVals = tab(:,dim);
    empty = cellfun(@isempty,dimVals);
    numeric = cellfun(@isnumeric,dimVals);
    if any(numeric(~empty))
        dimVals = can2mat(dimVals);
    end
    dimVal0 = dimVals(~empty);
            
    uniqueVal = unique(dimVal0);
    for iVal=1:length(uniqueVal)
        idVal = false(size(tab,1),1);
        for iRow=1:size(tab,1)
            c = tab{iRow,dim};
            if isnumeric(c) && ~isempty(c)
                idVal(iRow) = c==uniqueVal(iVal);
            elseif ~isempty(c)
                idVal(iRow) = strcmpi(c,uniqueVal{iVal});
            end
        end
        num(idVal,dim) = iVal;
    end
    num(empty,dim) = length(uniqueVal)+1;
end

uniqueRows = unique(num,'rows');

if size(uniqueRows,1)<size(num,1)
    disp('Some combinations of ExpKeys correspond to multiple sessions. Adding a column of replications.')
end
if size(uniqueRows,1)<size(num,1) || forceReplicates
    repCol = length(D)+1;
    D{end+1} = 'Replication';
    num(:,repCol) = 1;
    for iR=1:size(uniqueRows,1)
        idRow = find(all(repmat(uniqueRows(iR,:),[size(num,1) 1])==num(:,1:end-1),2));
        for iRep=1:length(idRow)
            num(idRow(iRep),repCol) = iRep;
            tab{idRow(iRep),repCol} = iRep;
        end
    end
end
sz = max(num,[],1);


directories = cell(sz);
for iD=1:size(num,1)
    % For each fd, the series of values in num provides the dimensional
    % index.
    
    evalStr = 'directories{';
    for dim=1:size(num,2)
        evalStr = [evalStr num2str(num(iD,dim)) ','];
    end
    evalStr = evalStr(1:end-1); % remove trailing comma
    evalStr = [evalStr '} = fd{iD};'];
    eval(evalStr);
end

levels = cell(max(sz),length(D));
for dim=1:length(D)
    eval(['dimKey.dimList.' D{dim} '=nan(sz);']);
    eval(['dimKey.dimIndices.' D{dim} '=nan(sz);']);

    dimVals = tab(:,dim);
    empty = cellfun(@isempty,dimVals);
    numeric = cellfun(@isnumeric,dimVals);
    if any(numeric(~empty))
        dimVals = can2mat(dimVals);
    end

    uniqueVal = unique(dimVals(~empty));
    for iVal=1:length(uniqueVal)
        if any(numeric)
            levels{iVal,dim} = uniqueVal(iVal);
        else
            levels{iVal,dim} = uniqueVal{iVal};
        end
    end

    if any(empty)
        levels{length(uniqueVal)+1,dim} = '';
        if ~isempty(uniqueVal)
            uniqueVal{end+1} = '';
        else
            uniqueVal = {''};
        end
    end
    rp = sz;
    rp(dim) = 1;
    rz = ones(1,length(sz));
    rz(dim) = sz(dim);
    idx = repmat(reshape(1:length(uniqueVal),rz),rp);
    field = uniqueVal(idx);

    dimKey.dimList=setfield(dimKey.dimList,D{dim},field);
    dimKey.dimIndices=setfield(dimKey.dimIndices,D{dim},idx);
end

for iField=1:length(D);
    field=getfield(dimKey.dimList,D{iField});
    if iscell(field)
        num = cellfun(@isnumeric,field);
        empty = cellfun(@isempty,field);
        if all(num(~empty))
            field = can2mat(field);
        end
    end
    dimKey.dimList=setfield(dimKey.dimList,D{iField},field);
end

dimKey.dimLevels = levels;
dimKey.dimFactors = D;
dimKey.SSNtable = tab;

fdSorted.directories = directories;
fdSorted.dimKey = dimKey;

if nargout>1
    sdCA = cell(sz);
    for iD=1:size(num,1)
        % For each fd, the series of values in num provides the dimensional
        % index.
        pushdir(fd{iD});
        sdfn = FindFiles('*-sd.mat');
        if ~isempty(sdfn)
            load(sdfn{1});
            evalStr = 'sdCA{';
            for dim=1:size(num,2)
                evalStr = [evalStr num2str(num(iD,dim)) ','];
            end
            evalStr = evalStr(1:end-1); % remove trailing comma
            evalStr = [evalStr '} = sd'];
            eval(evalStr);
        else
            disp('Could not find *-sd.mat file for inclusion in cell array.')
        end
        popdir;
    end
end

function tab = tabulateExpKeys(fd,D,varargin)
% Support function to tabulate the list of keys found in directories fd
% according to dimensions in D:
% D = {D1, D2, D3 ... }
% e.g.,
%      D1 = 'Rat'
%      D3 = 'Condition'
%      D2 = 'SSN'
% Special non-ExpKeys keys 
% 'Rat', finds session directory and extracts portion before date
% 'Date', finds session directory and extracts portion after rat 
% 'SSN', finds session directory
% 'Session', arbitrary session number for rat.
% 'SessNum', session number for each unique combination of other dimensions.
%
% Each row in tab is a line in fd.
% Each column in tab is a dimension in D.
% Entries represent value of dimension for fd.

fd = fd(:);
D = D(:);

% Preprocess Rat, Date, SSN and Sess.
for iD=1:length(fd);
    d = fd{iD};
    delim = regexpi(d,'\');
    % Create "special" keys.
    SSN{iD} = d(max(delim)+1:end);
    id1 = min(regexp(SSN{iD},'[A-Z][0-9]'));
    id2 = min(regexpi(SSN{iD},'-'));
    Subj{iD} = SSN{iD}(id1:id2-1);
    SubjNum{iD} = str2num(SSN{iD}(id1+1:id2-1));
    Date{iD} = SSN{iD}(id2+1:end);
    id1 = min(regexp(SSN{iD},'R'));
    id2 = min(regexpi(SSN{iD},'-'));
    Rat{iD} = SSN{iD}(id1:id2-1);
    RatNum{iD} = str2num(SSN{iD}(id1+1:id2-1));
    Date{iD} = SSN{iD}(id2+1:end);
end
uniqueRat = unique(Rat);
Session = nan(length(Rat),1);
for iR=1:length(uniqueRat)
    idRat = strcmpi(uniqueRat{iR},Rat);
    ratSSN = SSN(idRat);
    uniqueRatSSN = unique(ratSSN);
    for iSSN=1:length(uniqueRatSSN);
        idSSN = strcmpi(uniqueRatSSN{iSSN},SSN);
        Session(idSSN) = iSSN;
    end
end

% Create a table with the values for each session.
tab = cell(length(fd),length(D));
for iD=1:length(fd);
    d = fd{iD};
    
    % Load keys
    pushdir(d);
    disp(d);
    keys = [strrep(SSN{iD},'-','_')];
    keysfn = FindFiles([keys '*_keys.m'],'CheckSubdirs',0);
    [~,keys,ext] = fileparts(keysfn{1});
    keysfn = [keys ext];
%     keysfn = [keys '.m'];
    if exist('ExpKeys','var')==1
        clear ExpKeys
    end
    if exist(keysfn,'file')==2
        eval(keys);
    else
        disp(['No ' keysfn ' keys file.'])
    end
    popdir;
    ExpKeys.Subj = Subj{iD};
    ExpKeys.SubjNum = SubjNum{iD};
    ExpKeys.Rat = Rat{iD};
    ExpKeys.Date = Date{iD};
    ExpKeys.SSN = SSN{iD};
    ExpKeys.Session = Session(iD);
    ExpKeys.RatNum = RatNum{iD};
    for dim=1:length(D);
        if isfield(ExpKeys, D{dim})
            fieldVal = getfield(ExpKeys, D{dim});
            if iscell(fieldVal) & ~isempty(fieldVal)
                if length(fieldVal)>1
                    val = '{';
                else
                    val = '';
                end
                for iC=1:length(fieldVal)
                    val0 = fieldVal{iC};
                    if isnumeric(val0)
                        val = [val num2str(val0) ', '];
                    end
                    if ischar(val0)
                        val = [val val0 ', '];
                    end
                end
                val = val(1:end-2);
                if length(fieldVal)>1
                    val = [val '}'];
                end
                
                clear fieldVal
                fieldVal = val;
            end
            if isempty(fieldVal)
                fieldVal = 'N/A';
            end
            tab{iD,dim} = fieldVal;
        else
            tab{iD,dim} = 'N/A';
        end
    end
end
empty = cellfun(@isempty,tab);
for iR=1:size(empty,1)
    for iC=1:size(empty,2)
        if empty(iR,iC)
            tab{iR,iC} = {};
        end
    end
end
I = zeros(size(tab));
for iDim=1:size(I,2)
    col = tab(:,iDim);
    num = cellfun(@isnumeric,col);
    empty = cellfun(@isnumeric,col);
    if all(num(~empty)); col = can2mat(col); end
    
    uniqueVals = unique(col);
    for iVal=1:length(uniqueVals)
        if iscell(uniqueVals)
            val = uniqueVals{iVal};
        else
            val = uniqueVals(iVal);
        end
        idx = false(size(tab,1),1);
        for iRow=1:size(tab,1)
            if isnumeric(val) && isnumeric(tab{iRow,iDim});
                idx(iRow) = val==tab{iRow,iDim};
            elseif ischar(val) && ischar(tab{iRow,iDim});
                idx(iRow) = strcmpi(val,tab{iRow,iDim});
            end
        end
        I(idx,iDim) = iVal;
    end
end

if any(strcmpi('SessNum',D))
    SessNumDim = find(strcmpi('SessNum',D));
    uniqueRows = unique(I,'rows');
    for iRow=1:size(uniqueRows,1)
        row = uniqueRows(iRow,:);
        idx = find(all(repmat(row,[size(I,1) 1])==I,2));
        for iSess=1:length(idx)
            tab{idx(iSess),SessNumDim} = iSess;
        end
    end
end