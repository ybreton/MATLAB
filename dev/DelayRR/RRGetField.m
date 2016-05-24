function [extractedField] = RRGetField(sd,fieldName,varargin)
% Produces nSubsess x trial matrix of restaurant row field values.
% extractedField = RRGetField(sd,fieldName)
% where     extractedField      is nSubsess x trial matrix or cell array of
%                                   extracted field values from
%                                   sd.fieldName
%           
%           sd is nSess x 1 structure of sd,
%           fieldName is a string specifying which field to extract.
%
% OPTIONAL:
% nLaps     (default 200)   maximum number of laps
% nZones    (default 4)     number of zones
% numeric   (default true)  extracted field is numeric.
%

nLaps = 200;
nZones = 4;
numeric = true;
process_varargin(varargin);

if numeric
    extractedField = nan(numel(sd),nLaps*nZones*numel(sd));
else
    extractedField = cell(numel(sd),nLaps*nZones*numel(sd));
end

fprintf('\nExtracting %s from sd\n',fieldName)
fprintf('\n');

for s = 1 : numel(sd)
    outField = getfield(sd(s),fieldName);
    if numeric | length(outField)>1
        extractedField(s,1:length(outField)) = reshape(outField,1,length(outField));
    else
        extractedField{s} = outField;
    end
end
