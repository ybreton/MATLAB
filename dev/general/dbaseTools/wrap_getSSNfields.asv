function R = wrap_getSSNfields(fd,dimensions,fields,initFcn,varargin)
% Wrapper to obtain multiple fields from sd's arranged in arrays with
% dimensionality according to experiment keys.
% R = Wrap_getSSNfields(fd,dimensions,fields,initFcn)
% where     R       is a structure array with fields
%           R.directories
%                   m x n x ... x p x nSubsess x nTrials, or
%                   m x n x ... x p x nTrials 
%                   cell array of directories,
%                   arranged by the specified experiment keys dimensions.
%           R.field1, R.field2, ...
%                   m x n x ... x p x nSubsess x nTrials, or
%                   m x n x ... x p x nTrials 
%                   matrices of fields to be returned from sd structures, 
%                   arranged by the specified experiment keys dimensions.
%           R.(dimensions1).Names, R.(dimensions2).Names, ...
%                   m x n x ... x p x nSubsess x nTrials, or
%                   m x n x ... x p x nTrials arrays of the dimension
%                   values from the experiment keys, 
%                   arranged by the specified experiment keys dimensions.
%           R.(dimensions1).level1, ...
%                   m x n x ... x p x nSubsess x nTrials, or
%                   m x n x ... x p x nTrials 
%                   logical arrays specifying which entries correspond to
%                   that level of that dimension, one for each keys
%                   dimension where the number of levels is at most
%                   maxBool, and one for each dimension that has been
%                   forced to have a boolean index in isBoolDim. These
%                   dimensions cannot be numeric--their levels must be
%                   specified by strings.
%           R.(dimensions), ...
%                   m x n x ... x p x nSubsess x nTrials, or
%                   m x n x ... x p x nTrials arrays of the numerical
%                   dimension values from the experiment keys, arranged by
%                   the specified experiment keys dimensions.
%           R.dimNames
%                   a 1 x nDimensions cell array of the names of each
%                   dimension of the included arrays.
%           R.dimLevels
%                   a 1 x nDimensions cell array of 1 x nLevel cell arrays
%                   that correspond to each level of each dimension of the
%                   included arrays.
%           R.size
%                   a 1 x nDimensions vector with the number of elements of
%                   each dimension of the fields of R.
%
%           fd      is a cell array of directories to sort,
%           dimensions
%                   is a cell array of experiment keys and special keys
%                   along which to sort fd. Special keys are listed below.
%           fields
%                   is a cell array of sd fields to extract.
%           initFcn
%                   is a handle to the initialization function that
%                   produces sd's.
%
% SPECIAL KEYS
% ************
% 'SSN'     (Final portion of fd string)
% 'Rat'     (Only R part of SSN string)
% 'Date'    (Only YYYY-MM-DD part of SSN string)
% 'RatNumber' (Number part following R in R part of SSN string; numerical)
% 'Session'   (Arbitrary session number for each rat, ordered
%             chronologically; numerical)
% 'SessNum'   (Arbitrary chronological session number for the unique
%             combination of all other dimensions; numerical)
%
% OPTIONAL ARGUMENTS
% ******************
% postProcess   (default {})
%       a cell array of function handles that take sd and return an sd with
%       new fields, to be processed after the sd is produced for a session.
% maxBool       (default: 3)
%       largest number of levels for a dimension to have boolean index
%       arrays for each level.
% isBoolDim     (default: false)
%       1 x nDimensions vector of logicals forcing the levels of that
%       dimension to each receive a boolean index array.
%
% EXAMPLE:
% ********
%       Suppose we want to take the list of 4x20 file directories in fd, and
%       return the fields 'ZoneDelay', 'stayGo', and 'IdPhi' from the sd's
%       that can be initialized from those directories using RRInit, then
%       running sd=zIdPhi(sd), and arranged by ViralTarget, Rat, and Condition.
%       The directories in fd come from 4 rats, which have
%       viral targets OFC and N/A, and underwent conditions Saline and
%       CNO. We want to collect ZoneDelay, stayGo, and IdPhi from sessions
%       of each unique combination of ViralTarget, RatNum, and Condition.
%
% >> R = Wrap_getSSNfields(fd,{'ViralTarget' 'RatNum' 'Condition' 'SessNum'},{'ZoneDelay' 'stayGo' 'IdPhi'},@RRInit,'postProcess',{@zIdPhi})
%
%       The following fields provide information about the dimensionality
%       of all the arrays in the structure. Each dimension corresponds to a
%       field of the experiment keys, and each subscript of the dimension
%       corresponds to a unique value of the experiment key. Note that the
%       special key 'RatNum' is not an experiment key, but deduced from the
%       SSN string. Special keys not part of the ExpKeys structure are
%       listed above.
%       Additionally, dimensions for both subsession (in 4x20) and trial
%       have been added here, as there are multiple subsessions in this
%       dataset.
%       These fields simply summarize in plain English what's in the arrays
%       that are stored within the structure R; they do not index them.
%
% R.dimNames => {'ViralTarget' 'RatNum' 'Condition' 'SessNum' 'Subsession' 'Trial'}
% R.dimLevels => {{'OFC'; 'NA'}, [266; 267; 268; 269], {'CNO'; 'Saline'}, [1:10]', [1:4]', [1:384]'};
%
%       The following field provides information concerning the directory
%       from which the data came.
%
% R.directories => 6D cell array, nViralTarget x nRats x nConditions x nSessions x nSubsess x nTrials
%
%       The following fields were extracted from the sd structures after
%       post-processing them with sd=zIdPhi(sd). They are arranged
%       according to the dimensionality summarized above.
%
% R.ZoneDelay => 6D double, nViralTarget x nRats x nConditions x nSessions x nSubsess x nTrials
% R.stayGo => 6D double, nViralTarget x nRats x nConditions x nSessions x nSubsess x nTrials
% R.IdPhi => 6D double, nViralTarget x nRats x nConditions x nSessions x nSubsess x nTrials
%
%       The following fields provide the values of the experiment keys that
%       correspond to each element in the above extracted arrays.
%
% R.ViralTarget.Names => 6D cell array, nViralTarget x nRats x nConditions x nSessions x nSubsess x nTrials
% R.RatNum => 6D double, nViralTarget x nRats x nConditions x nSessions x nSubsess x nTrials
% R.Condition.Names => 6D cell array, nViralTarget x nRats x nConditions x nSessions x nSubsess x nTrials
% R.SessNum => 6D double, nViralTarget x nRats x nConditions x nSessions x nSubsess x nTrials
%
%       The following fields provide logical indices (booleans) of whether
%       a particular element corresponds to the indicated level of the
%       indicated dimension. For example, wherever true, R.ViralTarget.OFC
%       indicates that the element has a ViralTarget of OFC. Since RatNum
%       and SessNum are matrices, their levels do not have boolean logical
%       arrays.
%
% R.ViralTarget.OFC => 6D logical, nViralTarget x nRats x nConditions x nSessions x nSubsess x nTrials
% R.ViralTarget.NA => 6D logical, nViralTarget x nRats x nConditions x nSessions x nSubsess x nTrials
% R.Condition.CNO => 6D logical, nViralTarget x nRats x nConditions x nSessions x nSubsess x nTrials
% R.Condition.Saline => 6D logical, nViralTarget x nRats x nConditions x nSessions x nSubsess x nTrials
%
%       The following fields provide the subsession and trial numbers for
%       each element in the arrays above.
%
% R.SubSession => 6D double, nViralTarget x nRats x nConditions x nSessions x nSubsess x nTrials
% R.Trial => 6D double, nViralTarget x nRats x nConditions x nSessions x nSubsess x nTrials
%

postProcess = {};
maxBool = 3;
isBoolDim = false(1,length(dimensions));
progressBar = true;
process_varargin(varargin);

fdSorted = sortSessDimByExpKey(fd,dimensions);

% preprocess fd's for number of trials and subsessions, if any.
[nTrials,nSubsess] = getTrialsFromSSNs(fdSorted.directories,initFcn);

if ischar(fields)
    fields = {fields};
end
fields = fields(:);

R = getFieldFromSSNs(fdSorted,fields,initFcn,'postProcess',postProcess,'nTrials',nanmax(nTrials(:)),'nSubsess',nanmax(nSubsess(:)),'maxBool',maxBool,'isBoolDim',isBoolDim,'progressBar',progressBar);
sz = cellfun(@length,R.dimLevels);
% 
% nT = nan(length(nTrials),nanmax(nTrials(:)));
% for iS=1:numel(nTrials)
%     if isOK(nTrials(iS))
%         nT(iS,1:nTrials(iS)) = 1:nTrials(iS);
%     end
% end
%nT = reshape(nT,sz);
%R.Trial = nT;

R.size = sz;
R.fdSorted = fdSorted;