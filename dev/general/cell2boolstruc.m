function s = cell2boolstruc(ca,varargin)
% Wrapper to convert a cell array of strings to a structure with booleans.
% Any non-alphanumeric parts of the string will be replaced by a special
% character, any numbers will be prefixed with a special alphabetical code.
%
% OPTIONAL ARGUMENTS:
% ******************
%
%

alphaNumericString = '_';
numericPrefix = 'No';
process_varargin(varargin);

uniqueNames = unique(ca(cellOK(ca)));
for iN=1:length(uniqueNames);
    string = uniqueNames{iN};
    id = strcmp(uniqueNames{iN},ca);
    
    indices = 1:length(string);
    alpha = regexpi(string,'[a-z]');
    num = regexp(string,'[0-9]');
    nonalphanum = indices(~ismember(indices,alpha)&~ismember(indices,num));
    
    fname = string;
    fname(nonalphanum) = alphaNumericString;
    nonalpha = indices(~ismember(indices,alpha));
    if min(nonalpha)==1
        fname = [numericPrefix fname];
    end
    
    disp(fname)
    s.(fname) = false(size(ca));
    s.(fname)(id) = true;
end