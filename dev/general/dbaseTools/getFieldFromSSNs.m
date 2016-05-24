function OutStruct = getFieldFromSSNs(fd,field,initFcn,varargin)
% Assembles a structure array with values from 'field' obtained from fd. The
% fields that make up the dimensionality of fd are also included. fd is a
% structure array produced by sortSessDimByExpKey.
% M = getFieldFromSSNs(fd,field,initFcn)
% where     M.field       
%                       is m x n x ... x p x nTrials matrix of field
%                       values
%           M.(dim).Names
%                       are m x n x ... x p x nTrials cell arrays of values
%                       for the named variables that make up the dimensions
%                       of M.field
%           M.(dim).(level)
%                       are m x n x ... x p x nTrials logicals of boolean
%                       indicators for the levels of each dimension with 3
%                       or fewer levels.
%           M.(dim)
%                       are m x n x ... x p x nTrials matrices of values
%                       for the named variables that make up strictly
%                       numeric dimensions of M.field
%
%           M.dimNames
%                       is a 1 x nDims cell array with the fields that make
%                       up each dimension
%           M.dimLevels
%                       is a 1 x nDims cell array of nLevels x 1 cell
%                       arrays containing the levels of each dimension.
%                       M.dimLevels{1}{2} is the second level of dimension
%                       1.
%                       OR
%                       nLevels
% 
%           fd          is a structure produced by sortSessDimByExpKey with
%                       fields
%             .directories
%                       is m x n x ... x p cell array of file directories with
%                       SSN data
%             .dimKey
%                       is a structure array with the key to each
%                       dimension
%           field   
%                       is a string, or cell array of strings, specifying
%                       which field of sd to get
%           initFcn 
%                       is a function handle to the initialization function
%                       (e.g., @RRInit)
%
% OPTIONAL ARGUMENTS:
% ******************
% postProcess   (default: {})
%                   cell array of function handles that take sd as input
%                   and sd as first output. Each cell will be evaluated
%                   sequentially in order.
% maxBool       (default: 3)
%                   largest number of levels for a dimension to have
%                   boolean index arrays for each level.
% isBoolDim     (default: false)
%                   1 x nDimensions vector of logicals forcing the levels
%                   of that dimension to each receive a boolean index array.
%
% EXAMPLE:
% *******
% >> fdSorted = sortSessDimByExpKey(fd,{'ViralTarget' 'Rat' 'Condition'})
% 
% >> delays = getFieldFromSSNs(fdSorted, 'ZoneDelay')
% 
%
postProcess = {};
nTrials = 800; % 4 trials per lap; 200 laps max
nSubsess = 1;
maxBool = 3;
sz0 = ones(1,length(fd.dimKey.dimFactors));
sz = size(fd.directories);
sz0(1:length(sz)) = sz;
sz = sz0;
isBoolDim = false(1,length(sz));
process_varargin(varargin);
nSubsessMax = max(nSubsess(:));
nTrialsMax = max(nTrials(:));

if nSubsessMax>1
    OutStruct.directories = repmat(fd.directories,[ones(1,length(sz)) nSubsessMax nTrialsMax]);
    szOut = [sz nSubsessMax nTrialsMax];
    rpOut = [ones(1,length(sz)) nSubsessMax nTrialsMax];
    isBoolDim(length(sz)+1:length(sz)+2) = false;
else
    OutStruct.directories = repmat(fd.directories,[ones(1,length(sz)) nTrialsMax]);
    szOut = [sz nTrialsMax];
    rpOut = [ones(1,length(sz)) nTrialsMax];
    isBoolDim(length(sz)+1) = false;
end


if ischar(field)
    field = {field};
end

% for iField=1:length(field)
%     OutStruct = addSSNfield(OutStruct,fd,field{iField},initFcn,'postProcess',postProcess,'nTrials',nTrials,'nSubsess',nSubsess);
% end
OutStruct = addSSNfield_multiple(OutStruct,fd,field,initFcn,'postProcess',postProcess,'nTrials',nTrials,'nSubsess',nSubsess);


str = '';
for iDim=1:length(szOut)
    str = [str num2str(szOut(iDim)) ' x '];
end
str = str(1:end-3);
disp(['Getting dimensionality characteristics of ' str ' array...']);

dimNames = fieldnames(fd.dimKey.dimList);
str = '';
for iDim=1:length(dimNames)
    str = [str 'n' dimNames{iDim} ' x '];
end
str = str(1:end-3);
if nSubsessMax>1
    str = [str ' x nSubSession x nTrial'];
else
    str = [str ' x nTrial'];
end
disp(['Arrays are ' str '.'])

OutStruct.dimNames = cell(1,length(szOut));
OutStruct.dimNames(1:length(dimNames)) = dimNames;
OutStruct.dimLevels = cell(1,length(szOut));

for iDim=1:length(dimNames)
    disp(['Dimension ' num2str(iDim) ': ' dimNames{iDim}]);
    dimValues = fd.dimKey.dimList.(dimNames{iDim});
    dimValues = repmat(dimValues,rpOut);
    nLevels = sz(iDim);
    Levels = fd.dimKey.dimLevels(1:nLevels,iDim);
    if iscell(dimValues)
        disp('(dimension of string-specified types)')
        OutStruct.(dimNames{iDim}).Names = dimValues;
        OutStruct.dimLevels{iDim} = cell(nLevels,1);
        
        for iLevel=1:length(Levels)
            levelName = Levels{iLevel};
            if isempty(levelName)
                levelName = 'Empty';
            end
            if ischar(levelName)
                levelName = strrep(levelName,'-','_');
                idxAlphaNumeric = sort([regexpi(levelName,'[a-z,0-9]') regexpi(levelName,'_')]);
                levelName = levelName(idxAlphaNumeric);
            else
                levelName = num2str(levelName);
            end

            disp(['     Level ' num2str(iLevel) ': ' levelName]);

            OutStruct.dimLevels{iDim}{iLevel} = Levels{iLevel};

            if nLevels<=maxBool || isBoolDim(iDim)
                disp(['     Adding ' levelName ' boolean...'])
                % This is the field name the boolean will be stored in
                dimIndices = repmat(fd.dimKey.dimIndices.(dimNames{iDim}),rpOut);
                boolLevel = dimIndices==iLevel;

                try
                    OutStruct.(dimNames{iDim}).(levelName) = boolLevel;
                catch
                    warning(['Could not create boolean field for level ' levelName ' in dimension field ' dimNames{iDim} '.'])
                end
            end
        end
    else
        disp('(numeric dimension of values)')
        OutStruct.(dimNames{iDim}) = dimValues;
        Levels = cellfun(@mean,Levels);
        OutStruct.dimLevels{iDim} = Levels(:);
    end
end
if nSubsessMax>1
    OutStruct.SubSession = repmat(reshape(1:nSubsessMax,[ones(1,length(sz)) nSubsessMax 1]),[sz 1 nTrialsMax]);
    OutStruct.Trial = repmat(reshape(1:nTrialsMax,[ones(1,length(sz)) 1 nTrialsMax]),[sz nSubsessMax 1]);
    OutStruct.dimNames{end-1} = 'Subsession';
    OutStruct.dimNames{end} = 'Trial';
    OutStruct.dimLevels{end-1} = (1:nSubsessMax)';
    OutStruct.dimLevels{end} = (1:nTrialsMax)';
else
    OutStruct.Trial = repmat(reshape(1:nTrialsMax,[ones(1,length(sz)) nTrialsMax]),[sz 1]);
    OutStruct.dimNames{end} = 'Trial';
    OutStruct.dimLevels{end} = (1:nTrialsMax)';
end