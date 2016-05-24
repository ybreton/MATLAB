function R = addSSNfield_multiple(R,fd,field,initFcn,varargin)
% Support function to add a field to structure R from sd's produced by
% initialization function initFcn in each directory in fd.
% R = addSSNfield(R,fd,field,initFcn)
% where     R       is a structure array
% 
%           fd      is a structure array produced by sortSessDimByExpKey
%           field   is a cell array with the field names to be extracted from sd
%           initFcn is a handle to the initialization function that
%                       produces sd's
%
% OPTIONAL ARGUMENTS
% ******************
% postProcess   (default {})
%       cell array of function handles that take and return sd with new
%       fields, to be executed in order after initialization
% nTrials       (default 800)
%       number of trials to initialize in extracted matrix. The number of
%       trials in each session can be calculated from getTrialsFromSSNs
% nSubsess      (default 1)
%       number of sub-sessions included per session. Useful for 4x20.
% progressBar   (default true)
%       display a bar of the progress made through the list of file
%       directories.
%
postProcess = {};
nTrials = 800; % 4 trials per lap; 200 laps max
nSubsess = 1;
progressBar = true;
process_varargin(varargin);

directories = fd.directories;
sz0 = ones(1,length(fd.dimKey.dimFactors));
sz = size(directories);
sz0(1:length(sz)) = sz;
sz = sz0;
directories = directories(:);
nSubsessMax = max(nSubsess(:));
nTrialsMax = max(nTrials(:));

if ischar(field)
    field = {field};
end
nFields = length(field);

if nSubsessMax==1
    M0 = nan([sz nTrialsMax]);
else
    M0 = nan([sz nSubsessMax nTrialsMax]);
    warning('Multiple sub-sessions in a session. Dimension of subsessions added.');
end
szOut = size(M0);
for iField=1:length(field)
    M.(field{iField}) = M0;
end

I = nan([prod(szOut) length(szOut)]);
for iDim=1:length(szOut)
    rs = ones(1,length(szOut));
    rs(iDim) = szOut(iDim);
    rp = szOut;
    rp(iDim) = 1;
    I0 = repmat(reshape(1:szOut(iDim),rs),rp);
    I(:,iDim) = I0(:);
end

disp('Pulling out fields from sd''s')
if progressBar
    pbarHandle = timedProgressBar('addSSNfield',length(directories));
end
for iSSN=1:length(directories)
    fd0 = directories{iSSN};
    if ~isempty(fd0)
        pushdir(fd0);
        disp(fd0);
        sd = initFcn('addSpikes',false);
        nSubsess=length(sd);
        for iSubsess=1:nSubsess
            sd0 = sd(iSubsess);
            disp(sd0.ExpKeys.SSN)
            for iPP=1:length(postProcess)
                ppFcn = postProcess{iPP};
                sd0 = ppFcn(sd0);
            end
            
            for iField=1:nFields
                disp(['Extracting ' field{iField} '...'])
                if isfield(sd0(iSubsess),field{iField})
                    val = sd0(iSubsess).(field{iField});
                    nTrials = numel(val);
                    if nSubsessMax==1
                        val = reshape(val,[ones(1,length(sz)) nTrials]);
                    else
                        val = reshape(val,[ones(1,length(sz)) 1 nTrials]);
                    end
                    evalStr = ['M.' field{iField} '('];
                    for iDim=1:length(sz)
                        evalStr = [evalStr num2str(I(iSSN,iDim)) ','];
                    end
                    nTrials = length(val);
                    if nSubsessMax==1
                        evalStr = [evalStr '1:' num2str(nTrials) ')=val;'];
                    else
                        evalStr = [evalStr num2str(iSubsess) ',1:' num2str(nTrials) ')=val;'];
                    end
                    eval(evalStr);
                else
                    disp(['Field ' field{iField} ' not found.'])
                end
            end
        end
        if progressBar
            pbarHandle=pbarHandle.update();
        end
        popdir;
    end
end

for iField=1:nFields
    disp(['Field ' field{iField} ' extracted.'])
    R.(field{iField}) = M.(field{iField});
end

if progressBar
    pbarHandle.close();
end
% eval(['R.' field '=M;'] );