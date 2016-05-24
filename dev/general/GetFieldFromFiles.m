function [ExtractedField,fnOut] = GetFieldFromFiles(fn,objname,fieldname,varargin)
% Function to extract a field fieldname from a workspace object objname
% saved in the list of file names fn.
% [ExtractedField,fnOut] = GetFieldFromFiles(fn,objname,fieldname)
% where     ExtractedField is nSess x n x m x ... matrix of values 
%               or nSess x 1 cell array of field structures,
%           fnOut is nSess x 1 cell array of filenames containing the
%               object.
% 
%           fn is nSess x 1 cell array of workspace filenames to include,
%           objname is string of workspace object,
%           fieldname is string of field name in workspace object.
%

process_varargin(varargin);

if ischar(fn)
    fn = {fn};
end

nrc = 0;

idNum = false(length(fn),1);
type = cell(length(fn),1);
for iF = 1 : length(fn)
    fd = fileparts(fn{iF});
    pushdir(fd);
    ws_obj0 = who;
    
    dat = load(fn{iF});
    objFound = false;
    try
        newObj = getfield(dat,objname);
        objFound = true;
    catch exception
        disp(['Object ' objname ' not found in ' fn{iF}])
    end
    
    if objFound
        try
            objField = getfield(newObj,fieldname);

            type{iF} = class(objField);
            idNum(iF) = isnumeric(objField);

            sz = size(objField);

            if length(sz)>length(nrc)
                xtra = length(sz)-length(nrc);
                nrc(end+1:end+xtra) = 0;
            end

            for d = 1 : length(sz)
                nrc(d) = max(nrc(d),sz(d));
            end
        catch exception
            disp(['Field ' fieldname ' not found in ' objname ' in ' fn{iF}])
        end
    end
    
    clear dat
    
    popdir;
end

NoObj = isempty(type);
fn(NoObj) = [];
type(NoObj) = [];

assert(length(unique(type))==1,'Field is cast as different class in each file.');

if all(idNum);
    disp([fieldname ' is numeric in all files.'])
    ExtractedField = nan([length(fn) nrc]);
else
    disp([fieldname ' is non-numeric in all files.'])
    ExtractedField = cell([length(fn) 1]);
end
fnOut = fn;

for iF = 1 : length(fn)
    fd = fileparts(fn{iF});
    disp(['Extracting ' fieldname ' from ' fn{iF}])
    pushdir(fd);
    
    data = load(fn{iF});
    wsObj = getfield(data,objname);
    
    fieldVals = getfield(wsObj,fieldname);
    
    if all(idNum)
        toInsert = reshape(fieldVals,[1 size(fieldVals)]);
        insertionStr = sprintf('1:%d,',size(fieldVals));
        insertionStr = insertionStr(1:end-1); % remove trailing comma
        
        eval(['ExtractedField(iF,' insertionStr ') = toInsert;'])
    else
        toInsert = fieldVals;
        ExtractedField{iF} = toInsert;
    end
    clear data wsObj
    popdir;
end