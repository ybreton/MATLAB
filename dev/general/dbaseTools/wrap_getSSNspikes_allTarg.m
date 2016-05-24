function S = wrap_getSSNspikes_allTarg(fd,dimensions,initFcn,varargin)
% Returns a structure with the spikes from all recorded regions.
% S = wrap_getSSNspikes_allTarg(fd,dimensions,initFcn)
% where     S           is a structure with fields
%           S.directories
%                       m x n x ... x p cell array of session directories
%                       sorted by the dimensions specified
%           S.dimNames
%                       1 x nDimensions cell array of experiment and
%                       special keys names along which the arrays are
%                       sorted
%           S.dimLevels
%                       1 x nDimensions cell array of cell arrays (strings)
%                       or vectors (numericals) with the levels
%                       corresponding to each element of that dimension
%           S.Targets.Target1.spikes, S.Target2.spikes, ..., S.TargetN.spikes
%                       m x n x ... x p cell array of ts objects with spike
%                       times for the specified target
%           S.Targets.Target1.nCells, S.Target2.nCells, ..., S.TargetN.nCells
%                       m x n x ... x p matrix of the number of cells
%           S.dimension1.Names, S.dimension2.Names, ..., S.dimensionN.Names
%                       m x n x ... x p cell arrays with the values of the
%                       dimension specified for each element for
%                       string-specified dimensions
%           S.dimension1.level1, S.dimension1.level2, ...
%                       m x n x ... x p logical arrays with a boolean index
%                       of whether the element corresponds to that level of
%                       that dimension. 
%           S.dimension1, S.dimension2, ...
%                       m x n x ... x p matrices with the values of the
%                       dimension specified for each element for
%                       numerically-specified dimensions
%
%           S.Merged.merged_TargetA_TargetB.spikes
%                       m x n x ... x p cell array of ts objects, merging
%                       all targets that correspond to the merging rules
%                       below.
%           S.Merged.merged_TargetA_TargetB.nCells
%                       m x n x ... x p matrix of the number of cells for
%                       the specified region with merged targets.
%           S.Merged.merged_TargetA_TargetB.merged
%                       Cell array of the targets that were asked to be
%                       merged together in the function call. This cell
%                       array may include target names that do not appear
%                       in any ExpKeys.Target keys. If so, the name of the
%                       field (merged_TargetA_TargetB) will only include
%                       targets that were actually merged, and the merged
%                       subfield will include all merging targets,
%                       regardless of whether or not they appear in
%                       ExpKeys.Target.
%           S.mergedRegions
%                       1 x nMergers cell array of cell arrays specifying
%                       which targets to merge together.
%
%           dimensions  is a cell array of ExpKeys and special keys along
%                       which to sort the arrays.
%           initFcn     is a handle to a function that initializes the
%                       standard session data structure.
%
% SPECIAL DIMENSIONS
% ******************
% 'SSN'     (Final portion of fd string)
% 'Rat'     (Only R part of SSN string)
% 'RatNum' (Number part following R in R part of SSN string)
% 'Date'    (Only YYYY-MM-DD part of SSN string)
% 'Session' (Arbitrary session number for each rat, ordered
%           chronologically)
% 'SessNum' (Arbitrary chronological session number for the unique
%           combination of all other dimensions)
%
% OPTIONAL ARGUMENTS
% ******************
% maxBool   (default 3)
%       highest number of levels a dimension can have in order to return a
%       boolean index field for each level.
% isBoolDim (default false)
%       logical vector forcing particular dimensions to return boolean
%       index fields for each of their levels.
% mergeRegions (default {})
%       Cell array of cell arrays with names of Targets (from sd.Target)
%       that should be considered the same region. 
%       For example, 
%       one might want to merge cells where the target was listed as
%       Hippocampus, CA1, HIPP, and HC together, and merge cells where the
%       target was listed as vStr, Striatum, Ventral Striatum, VS, NAc,
%       NAs, Nucleus Accumbens, Nucleus Accumbens Core or Nucleus Accumbens
%       Shell. In this case, we could specify
%
%       mergeRegions = {{'Hippocampus' 'HC' 'CA1' 'HIPP'};
%                       {'Ventral Striatum' 'vStr' 'Striatum' 'VS' 'NAc'
%                       'NAs' 'Nucleus Accumbens' 'Nucleus Accumbens Core'
%                       'Nucleus Accumbens Shell'}}
%       to indicate we wish to merge the first set together and the second
%       set together, and use the optional argument
%       'mergeRegions',mergeRegions
%       in the function call.
%       The merged regions will be referred to in the S structure array by
%       adding 'merged_' and each element of the merging list for which
%       there is a corresponding ExpKeys.Target. The merging list will also
%       be stored within the S structure.
%
% EXAMPLE
% *******
%           Suppose we want all the cells arranged by ViralTarget, RatNum,
%           Condition, and SessNum. Furthermore, the recording Target for
%           some sites was written differently: one experimenter wrote
%           'CA1' while another wrote 'HIPP' for hippocampal tetrode
%           targets, and one experiment wrote 'Striatum' while another
%           wrote 'vStr' for ventral striatum tetrode targets. We would
%           like to merge together cells tagged as "Hippocampus", "Hipp",
%           or "CA1" together, and cells tagged as "Ventral Striatum",
%           "vStr", or "Striatum" together. There are also cells from 'OFC'
%           and 'PFC'. Standard session data structures are initialized
%           with RRInit, from each of the directories listed in fd.
%
% >> S = wrap_getSSNspikes_allTarg(fd,{'ViralTarget' 'RatNum' 'Condition' 'SessNum'},@RRInit,'mergeRegions',{{'Hippocampus' 'HIPP' 'CA1'},{'Ventral Striatum' 'vStr' 'Striatum'}})
% 
%           The following fields are for record-keeping.
% S.directories => 4D cell array, nViralTarget x nRats x nConditions x nSessions
% S.dimNames => {'ViralTarget' 'RatNum' 'Condition' 'SessNum'}
% S.dimLevels => {{'OFC';'NA'} {1;2;3;4} {'CNO';'Saline'} {1;2;3;4;5}}
%
%           The following fields contain spike ts objects in each cell
% S.Targets.OFC.spikes => 4D cell array, nViralTarget x nRats x nConditions x nSessions
% S.Targets.PFC.spikes => 4D cell array, nViralTarget x nRats x nConditions x nSessions
% S.Merged.merged_HIPP_CA1.spikes => 4D cell array, nViralTarget x nRats x nConditions x nSessions
% S.Merged.merged_vStr_Striatum.spikes => 4D cell array, nViralTarget x nRats x nConditions x nSessions
% 
%           The following fields contain the number of spike ts objects in
%           each cell
% S.Targets.OFC.nCells => 4D double, nViralTarget x nRats x nConditions x nSessions
% S.Targets.PFC.nCells => 4D double, nViralTarget x nRats x nConditions x nSessions
% S.Merged.merged_HIPP_CA1.nCells => 4D double, nViralTarget x nRats x nConditions x nSessions
% S.Merged.merged_vStr_Striatum.nCells => 4D double, nViralTarget x nRats x nConditions x nSessions
%
%           The following fields contain information about which structures
%           were merged from the function call.
% S.Merged.merged_HIPP_CA1.merged => {'Hippocampus' 'HIPP' 'CA1'}
% S.Merged.merged_vStr_Striatum.merged => {'Ventral Striatum' 'vStr' 'Striatum'}
%
%           The following fields contain the values of the dimension levels
%           for each cell
% S.ViralTarget.Names => 4D cell, nViralTarget x nRats x nConditions x nSessions
% S.RatNum => 4D double, nViralTarget x nRats x nConditions x nSessions
% S.Condition.Names => 4D cell, nViralTarget x nRats x nConditions x nSessions
% S.SessNum => 4D double, nViralTarget x nRats x nConditions x nSessions
% 
%           The following fields contain boolean indices of whether the
%           cell corresponds to the indicated level of the indicated
%           dimension
% S.ViralTarget.NA => 4D logical, nViralTarget x nRats x nConditions x nSessions
% S.ViralTarget.OFC => 4D logical, nViralTarget x nRats x nConditions x nSessions
% S.Condition.CNO => 4D logical, nViralTarget x nRats x nConditions x nSessions
% S.Condition.Saline => 4D logical, nViralTarget x nRats x nConditions x nSessions
% 
%           The following field preserves the desired merging rules from
%           the function call
% S.mergedRegions => {{'HIPP' 'CA1'}; {'vStr' 'Striatum'}}
%

maxBool = 3;
isBoolDim = false(length(dimensions),1);
mergeRegions = {};
process_varargin(varargin);
if ~isempty(mergeRegions)
    c = cellfun(@iscell,mergeRegions);
    if all(~c)
        disp('Merging all selected regions together.')
        mergeRegions = {mergeRegions};
    end
end
mergeRegions = mergeRegions(:);
for iMerge=1:length(mergeRegions)
    mergeRegions{iMerge} = mergeRegions{iMerge}(:)';
end

% get list of regions
disp('Looking for all unique values of ExpKeys.Target in fd list...')
regions = findRecTargetExpKeys(fd);

if ~isempty(regions)
    disp('Found targets:')
    for iTarg=1:length(regions)
        disp(['-' regions{iTarg}])
    end
    
    S = wrap_getSSNspikes(fd,dimensions,regions,initFcn,'maxBool',maxBool,'isBoolDim',isBoolDim);
    
    sz = cellfun(@length,S.dimLevels);
    
    for iMerge = 1:length(mergeRegions)
        disp('Merging regions:')
        merged = mergeRegions{iMerge};
        s = cell(sz);
        nCells = zeros(sz);
        fieldName = 'merged';
        for iRegion=1:length(merged)
            disp(['- ' merged{iRegion}])
            fieldName = [fieldName '_' merged{iRegion}];
            if isfield(S.Targets,merged{iRegion})
                s0 = S.(merged{iRegion}).spikes;
                for iSSN=1:numel(s)
                    s{iSSN} = cat(1,s{iSSN},s0{iSSN});
                    
                end
                if isfield(S.(merged{iRegion}),'nCells');
                    n0 = S.(merged{iRegion}).nCells;
                    nCells = nCells+n0;
                end
            end
        end
        S.Merged.(fieldName).merged =  mergeRegions{iMerge};
        
        empty = cellfun(@isempty,s);
        if ~all(empty(:))
            S.Merged.(fieldName).spikes = s;
            S.Merged.(fieldName).nCells = nCells;
        end
    end
    disp('Removing redundant regions:')
    for iMerge = 1:length(mergeRegions)
        merged = mergeRegions{iMerge};
        for iRegion=1:length(merged)
            if isfield(S,merged{iRegion})
                disp(['- ' merged{iRegion}]);
                S = rmfield(S,merged{iRegion});
            end
        end     
    end
end

S.mergedRegions = mergeRegions;