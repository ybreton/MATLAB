function regions = findRecTargetExpKeys(fd)
% Support function to return a list of the regions in field 'Target' of the
% experiment keys.
% regions = findRecTargetExpKeys(fd)
% where     regions         is a nTarget x 1 cell array of unique Target
%                               values
%
%           fd              is a list of file directories to search.
% 

regions = {};
fprintf('\n')
for iSSN=1:length(fd)
    d = fd{iSSN};
    if ~isempty(d)
        pushdir(d);
        
        %Progress bar
        if mod(iSSN,100)==1
            fprintf('\n');
        end
        fprintf('.');
        
        delim = max(regexpi(d,'\'));
        SSN = d(delim+1:end);
        keysSSN = strrep(SSN,'-','_');
        keysFile = FindFiles([keysSSN '*_keys.m'],'CheckSubdirs',0);
        
        ExpKeys = struct('SSN',SSN);
        if ~isempty(keysFile)
            [~,keysCmd] = fileparts(keysFile{1});
            eval(keysCmd);
        end
        if isfield(ExpKeys,'Target')
        	sdTargets = ExpKeys.Target(:);
            empty = cellfun(@isempty,sdTargets);
            regions = unique(cat(1,regions(:),sdTargets(~empty)));
        end
        popdir;
    end
end
fprintf('\n')