function fd = searchKeys(varargin)
% Searches through keys files to find directories and SSNs:
%
% searchKeys(...) will return the directories and SSNs for which
% ALL indicated keys are matched,
% Keys are matched to any in the requested list.
%
% searchKeys(...,'any') will return the directories and SSNs for which
% ANY indicated keys are matched,
% Keys are matched to any in the requested list.
%
% fd = searchKeys(key1,value1,key2,value2,...)
% where 	fd 		is a structure with fields
% 				.directories 	the list of directories with keys files that match
% 				.SSNs 			the list of session numbers with keys files that match
%               .keysFn         the list of keys files that match
% 
% 			key_i 	is a string indicating which key MUST be matched,
% 			value_i	is a numerical or cell array of values the key CAN take on, or
% 					a string with the text value the key must take on
% fd = searchKeys(key1,value1,key2,value2,...,'any')
% where     key_i 	is a string indicating which key CAN be matched,
% 			value_i	is a numerical or cell array of values the key CAN take on, or
% 					a string with the text value the key must take on
%
%
% For example, if we want to identify sessions for which ALL the following are true:
% Target contains 'OFC' or 'vStr'		AND
% ViralTarget contains 'PFC'			AND
% Condition contains 'Saline'
% Then at the root directory to search,
% fd = searchKeys('Target',{'OFC' 'vStr'},'ViralTarget','PFC','Condition','Saline')
% will return a structure array with the following fields:
% fd.directories, with the path to each keys file for which Target, ViralTarget, and 
% Condition are all matched, and Target is either 'OFC' or 'vStr', ViralTarget is 'PFC', 
% and Condition is 'Saline'. 
%
% In order to match all items of a key, simply repeat the key. For example, if we want 
% to identify sessions for which
% Target contains 'OFC' 				AND
% Target contains 'vStr'				AND
% Target contains 'HC'
% (That is, at least triple-site recordings of OFC, vStr and HC)
% we would search from the root
% fd = searchKeys('Target','OFC','Target','vStr','Target','HC')
% which will require any Target to match OFC and any Target to match vStr and any Target 
% to match HC.
%
% To search across keys inclusively, use the 'any' flag.
% For example, for either OFC recording target or PFC viral target, identify sessions for which
% Target contains 'OFC' 				OR
% ViralTarget contains 'PFC'
% we would search from the root
% fd = searchKeys('Target','OFC','ViralTarget','PFC','any')
%

matchAnyKey = false;
if mod(nargin,2)==1
    % odd number of inputs
    if strcmpi(varargin{end},'any')
        matchAnyKey = true;
        disp('Searching for sessions that match any of the keys indicated.')
    end
end

keyname = varargin(1:2:end);
keyvalue = varargin(2:2:end);
for iKey=1:length(keyvalue)
	if ischar(keyvalue{iKey})
		keyvalue{iKey} = {keyvalue{iKey}};
	end
end

fn = FindFiles('*keys.m');
directories = cell(size(fn));
SSNs = cell(size(fn));
KEYs = cell(size(fn));
h = waitbar(0,'Searching keys, 0% Complete');
for iF=1:length(fn)
	d = fileparts(fn{iF});
	
	pushdir(d);
	SSN = GetSSN;
	Match = false(length(keyname),1);
	keysfile = strrep(SSN,'-','_');
	keysfn = FindFiles([keysfile '*keys*.m'],'CheckSubdirs',0);
	if ~isempty(keysfn)
		keysfn = keysfn{1};
		[d,f,x] = fileparts(keysfn);
        try
            eval(f);
		
            for iKey=1:length(keyname)
                if isfield(ExpKeys,keyname{iKey})
                    key = ExpKeys.(keyname{iKey});
                    keyComp = keyvalue{iKey};

                    if isnumeric(key) && isnumeric(keyComp)
                        % If key in keys file is numeric, only match if numeric comparison
                        M1 = repmat(key(:)',length(keyComp(:)),1);
                        M2 = repmat(keyComp(:),1,length(key(:)));
                        M = any(M1==M2,2);
                        Match(iKey) = any(M);
                    elseif ischar(key) && iscell(keyComp)
                        % If key in keys file is a string, only match if string comparison
                        for iVal1=1:length(keyComp)
                            newMatch = strcmpi(keyComp{iVal1},key);
                            Match(iKey) = Match(iKey) || newMatch;
                        end
                    elseif iscell(key)
                        % If key in keys file is a cell, only match if cell comparison
                        for iVal1=1:length(keyComp)
                            for iVal2=1:length(key)
                                newMatch = strcmpi(keyComp{iVal1},key{iVal2});
                                Match(iKey) = Match(iKey) || newMatch;
                            end
                        end
                    end
                end
            end
        catch 
            warning([keysfn{1} ' is wrong.'])
        end
    end
    if all(Match)
		directories{iF} = d;
		SSNs{iF} = SSN;
        KEYs{iF} = [d '\' f x];
    end
    if matchAnyKey && any(Match)
        directories{iF} = d;
		SSNs{iF} = SSN;
        KEYs{iF} = [d '\' f x];
    end
	
	popdir;
	waitbar(iF/length(fn),h,sprintf('Searching keys, %.1f%% Complete',iF/length(fn)*100));
end
empty1 = cellfun(@isempty,directories);
empty2 = cellfun(@isempty,SSNs);
empty3 = cellfun(@isempty,KEYs);
empty = empty1|empty2|empty3;
directories = directories(~empty);
SSNs = SSNs(~empty);
KEYs = KEYs(~empty);

fd.directories = directories;
fd.SSNs = SSNs;
fd.keysFn = KEYs;

delete(h);