function S2 = copy_structindexing(S1,S2,varargin)
% Adds the 
%   dimLevels,
%   dimNames,
%   (dimNames).Names
%   (dimNames).(dimLevels)
% fields from structure S1 to structure S2.

extraDims = [];
extraNames = {};
extraLevels = {};
process_varargin(varargin);
extraN = nan(1,length(extraDims));
for iextra=1:length(extraDims)
    extraN(iextra) = length(extraLevels{iextra});
end

dimNames = S1.dimNames;
dimLevels = S1.dimLevels;

S2.dimNames = dimNames;
S2.dimLevels = dimLevels;
for idim=1:length(dimNames);
    if isfield(S1,dimNames{idim});
        D = S1.(dimNames{idim});
        if isstruct(D)
            N = S1.(dimNames{idim}).Names;
            rp = ones(1,length(size(N)));
            if ~isempty(extraN)
                rp(extraDims) = extraN;
            end
            
            N = repmat(N,rp);
            
            S2.(dimNames{idim}).Names = N;
            
            for ilevel=1:length(dimLevels{idim})
                if isfield(S1.(dimNames{idim}),dimLevels{ilevel})
                    L = S1.(dimNames{idim}).(dimLevels{idim}{ilevel});
                    rp = ones(1,length(size(L)));
                    if ~isempty(extraN);
                        rp(extraDims) = extraN;
                    end
                    L = repmat(L,rp);
                    
                    S2.(dimNames{idim}).(dimLevels{idim}{ilevel}) = L;
                end
            end
        else
            rp = ones(1,length(size(D)));
            if ~isempty(extraN);
                rp(extraDims) = extraN;
            end
            D = repmat(D,rp);
            S2.(dimNames{idim}) = D;
        end
    end
end
S2.dimNames(extraDims) = extraNames;
S2.dimLevels(extraDims) = extraLevels;