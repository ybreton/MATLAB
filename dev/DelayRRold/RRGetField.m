function [extractedField,fnOut] = RRGetField(fn,fieldName,varargin)
% Produces n x lap matrix of restaurant row field values.
% [extractedField,fnOut] = RRGetField(fn,fieldName)
% where     extractedField is n x lap matrix or cell array of extracted field values from sd.fieldName,
%           fnOut is nSubSess x 1 vector of sd file names.
%           
%           fn is nSess x 1 cell array of sd files,
%           fieldName is a string specifying which field to extract.
%
% OPTIONAL:
% nLaps     (default 200)   maximum number of laps
% nZones    (default 4)     number of zones
% numeric   (default true)  extracted field is numeric.
%
% Note:
% fnOut might be longer than numel(fn) if there are 4x20 sessions included.

nLaps = 200;
nZones = 4;
numeric = true;
process_varargin(varargin);

if nargin<1
    fn = FindFiles('*-sd.mat');
end
% If filename is string
if ischar(fn)
    fn = {fn};
end

fd = cell(length(fn),1);
for f=1:length(fn)
    d = fileparts(fn{f});
    fd{f} = d;
end

% If filename is multidimensional
fn = fn(:);

if numeric
    extractedField = nan(length(fn)*nZones,nLaps*nZones);
else
    extractedField = cell(length(fn)*nZones,nLaps*nZones);
end

fnOut = cell(length(fn)*nZones,1);

k = 0;
nc = 0;

fprintf('\nExtracting %s from sd structs\n',fieldName)
fprintf('\n');
for f = 1 : length(fn)
    pushdir(fd{f});
    fprintf('%s\n',fd{f});
    
    load(fn{f});
    
    for s = 1 : length(sd)
        if length(sd)>4
            minsPerSubsess = sd.maxTimeToRun/60;
            fprintf('%d x %.0f: Subsess %d',length(sd),minsPerSubsess,s);
        end
        k = k+1;
        
        outField = getfield(sd(s),fieldName);
        if numeric | length(outField)>1
            extractedField(k,1:length(outField)) = reshape(outField,1,length(outField));
        else
            extractedField{k} = outField;
        end
        nc = max(nc,length(outField));
        
        fnOut{k} = fn{f};
        
    end
    
    popdir;
end

% triage extra rows/cols
extractedField = extractedField(1:k,1:nc);
fnOut = fnOut(1:k);