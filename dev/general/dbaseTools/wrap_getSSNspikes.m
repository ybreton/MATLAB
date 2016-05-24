function S = wrap_getSSNspikes(fd,dimensions,regions,initFcn,varargin)
% wrapper to get the spikes from each region of the sessions in fd
% S = wrap_getSSNspikes(fd,dimensions,regions,initFcn)
% where     S           is a structure with fields
%           S.directories
%                       m x n x ... x p cell array of the directories from
%                       which the data were obtained.
%           S.dimNames
%                       a 1 x nDimensions cell array of the names of each
%                       dimension of the included arrays.
%           S.dimLevels
%                       a 1 x nDimensions cell array of 1 x nLevel cell arrays
%                       that correspond to each level of each dimension of the
%                       included arrays.
%           S.Targets.region1.spikes, S.Targets.region2.spikes, ...,
%           S.Targets.regionN.spikes
%                       m x n x ... x p cell arrays of spike ts for each
%                       region, arranged by the experiment and special keys
%                       dimensions specified
%           S.Targets.region1.nCells, S.Targets.region2.nCells, ...,
%           S.Targets.regionN.nCells 
%                       m x n x ... x p matrices of number of cells for each
%                       region, arranged by the dimensions specified
%           S.dimension1, S.dimension2, ..., S.dimensionN
%                       m x n x ... x p arrays of the values of each
%                       dimension
%           S.dimension1_level1, S.dimension1_level2, etc.
%                       m x n x ... x p logical arrays with boolean indices
%                       of whether the cell array corresponds to the
%                       indicated level of that dimension
%
% SPECIAL KEYS
% ************
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
% maxBool       (default: 3)
%       largest number of levels for a dimension to have boolean index
%       arrays for each level.
% isBoolDim     (default: false)
%       1 x nDimensions vector of logicals forcing the levels of that
%       dimension to each receive a boolean index array.
%
% EXAMPLE
% *******
%           Suppose we want the spike times from all OFC and vStr (coded as
%           such in ExpKeys.Target) in an experiment with rats in various
%           ViralTarget groups, run according to two Conditions. We would
%           like OFC and vStr cells to be grouped by ViralTarget, RatNum,
%           Condition, and SessNum. The list of all directories to
%           initialize is in fd, and the initialization function is RRInit.
%
% >> S = wrap_getSSNspikes(fd,{'ViralTarget' 'RatNum' 'Condition'
% 'SessNum'},{'OFC' 'vStr'},@RRInit)
%
%           The following is for record-keeping.
%
% S.directories => 4D cell array, nViralTarget x nRat x nCondition x nSess
% S.dimNames => {'ViralTarget' 'RatNum' 'Condition' 'SessNum'}
% S.dimLevels = > {{'OFC'; 'PFC'; 'NA'} [267;268;269] {'CNO'; 'Saline'} [1;2;3;4;5;6;7;8;9;10]}
% 
%           The following provides the cells recorded from each target for
%           each combination of the above dimensions.
%
% S.OFC.spikes => 4D cell array, nViralTarget x nRat x nCondition x nSess
%                   each cell is a cell of ts objects corresponding to
%                   cells.
% S.vStr.spikes => 4D cell array, nViralTarget x nRat x nCondition x nSess
%                   each cell is a cell of ts objects corresponding to
%                   cells.
%
%           The following provide the number of cells recorded from each
%           target in each combination of the above dimensions.
%
% S.OFC.nCells => 4D double, nViralTarget x nRat x nCondition x nSess
% S.vStr.nCells => 4D double, nViralTarget x nRat x nCondition x nSess
%
%           The following provide dimensionality information for the cells
%           recorded for each target.
%
% S.ViralTarget.Names => 4D cell array, nViralTarget x nRat x nCondition x nSess
% S.RatNum => 4D double, nViralTarget x nRat x nCondition x nSess
% S.Condition.Names => 4D cell array, nViralTarget x nRat x nCondition x nSess
% S.SessNum => 4D double, nViralTarget x nRat x nCondition x nSess
%
%           The following provide a boolean index for which cells
%           correspond to particular levels of the dimension.
%
% S.ViralTarget.OFC => 4D logical, nViralTarget x nRat x nCondition x nSess
% S.ViralTarget.PFC => 4D logical, nViralTarget x nRat x nCondition x nSess
% S.ViralTarget.NA => 4D logical, nViralTarget x nRat x nCondition x nSess
% S.Condition.CNO => 4D logical, nViralTarget x nRat x nCondition x nSess
% S.Condition.Saline => 4D logical, nViralTarget x nRat x nCondition x nSess
%
% REVISIONS
% 2015-10-14    YAB         Added 
%
maxBool = 3;
isBoolDim = false(length(dimensions),1);
process_varargin(varargin);
regions = regions(:);

fdSorted = sortSessDimByExpKey(fd,dimensions);
sz = size(fdSorted.directories);
isBoolDim(end+1:length(sz)) = false;
idx = reshape(1:prod(sz),sz);
fd = fdSorted.directories(:);
spikes = cell(length(regions),length(fd));
barHandle = timedProgressBar('wrap_getSSNspikes',length(fd));
for iSSN=1:length(fd)
    if ~isempty(fd{iSSN})
        pushdir(fd{iSSN});
        disp(fd{iSSN});
        
        sd = initFcn();
        sd0 = sd(1);
        if isfield(sd0.ExpKeys,'Target')
            Targets = sd0.ExpKeys.Target(:);
            extract = false(length(Targets),length(regions));
            for iRegion=1:length(regions)
                extract(:,iRegion) = strcmpi(regions{iRegion},Targets);
            end
            extractID = find(any(extract,2));
            % if the targets correspond to any the regions of interest,
            % extract it. Since TetrodeTargets contains the target number,
            % we want the linear, not logical subcript. extractID is the
            % Target to extract.
            regionNum = nan(length(extractID),1);
            for iRegion=1:length(extractID)
                regionNum(iRegion) = find(extract(extractID(iRegion),:),1,'first');
            end
            % regionNum contains the subscript to region that corresponds
            % to extractID.
            I = RRassignTetrodeClusters(sd0);
            % rows of I correspond to targets; each column is an entry
            % in sd.S.

            for iTarget=1:length(extractID)
                if ~isempty(I)
                    if any(I(iTarget,:))
                        disp(['Extracting ' num2str(sum(I(iTarget,:))) ' ' Targets{extractID(iTarget)} ' cells.'])
                        spikes{regionNum(iTarget),iSSN} = sd0.S(I(extractID(iTarget),:));
                    else
                        disp('No clusters found.')
                    end
                end
            end
        end
        
        popdir;
    end
    barHandle = barHandle.update();
end
barHandle.close();

S.directories = fdSorted.directories;
S.dimNames = fdSorted.dimKey.dimFactors;
S.dimLevels = cell(1,length(S.dimNames));

for iRegion=1:length(regions)
    s = cell(sz);
    empty = cellfun(@isempty,spikes(iRegion,:));
    ssnList = find(~empty);
    for iSSN=ssnList
        s{idx(iSSN)} = spikes{iRegion,iSSN};
    end
    nCells = cellfun(@length,s);
    
    regionName = regions{iRegion};
    idxAlpha = regexpi(regionName,'[a-z,0-9]');
    idxNonAlphaBool = true(1,length(regionName));
    idxNonAlphaBool(idxAlpha) = false;
    if any(idxNonAlphaBool)
        warning(['Target ' regionName ' is not a valid field for structure arrays.'])

        regionName = strrep(regionName,' ','_');
        idxAlpha = regexpi(regionName,'[a-z,0-9]');
        idxNonAlphaBool = true(1,length(regionName));
        idxNonAlphaBool(idxAlpha) = false;
        regionName(idxNonAlphaBool) = '_';
        
        warning(['Renamed to ' regionName ' for structure array.'])
    end
    
    S.Targets.(regionName).Target = regions{iRegion};
    S.Targets.(regionName).spikes = s;
    S.Targets.(regionName).nCells = nCells;
end

for iField=1:length(fdSorted.dimKey.dimFactors)
    field = fdSorted.dimKey.dimFactors{iField};
    disp(['Dimension ' num2str(iField) ': ' field]);
    indices = fdSorted.dimKey.dimIndices.(field);
    val = fdSorted.dimKey.dimList.(field);
    
    if iscell(val)
        nLevels = length(unique(indices(:)));
        levels = fdSorted.dimKey.dimLevels(1:nLevels,iField);
        S.dimLevels{iField} = levels;
        if nLevels<maxBool || isBoolDim(iField)
            for iLevel=1:nLevels
                if isnumeric(levels{iLevel})
                    levelName = num2str(levels{iLevel});
                else
                    levelName = levels{iLevel};
                end

                levelName = strrep(levelName,'-','_');
                idxAlphaNumeric = sort([regexpi(levelName,'[a-z,0-9]') regexpi(levelName,'_')]);
                levelName = levelName(idxAlphaNumeric);
                disp(['     Level ' num2str(iLevel) ': ' levelName]);
                I = indices == iLevel;
                S.(field).Names = val;
                S.(field).(levelName) = I;
            end
        end
    else
        nLevels = length(unique(indices(:)));
        levels = fdSorted.dimKey.dimLevels(1:nLevels,iField);
        levels = cellfun(@mean,levels);
        S.dimLevels{iField} = levels;
        
        S.(field) = val;
    end
end