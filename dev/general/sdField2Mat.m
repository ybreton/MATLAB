function M = sdField2Mat(ssn,field,init,varargin)
% Returns a matrix of the values found in field for each of the session
% directories in ssn, initializing the task with function handle init.
% M = sdField2Mat(ssn,field,init)
% where     M           is m x n x ... x p x nTrials matrix of values,
%
%           field       is a string with the sd.field to extract,
%           init        is a function handle with the initialization
%                           function for the task
%
% e.g.,
% fn = FindFiles('RR-*.mat');
% fd = cell(length(fn),1); for iF=1:length(fn); fd{iF}=fileparts(fn{iF}); end
% ssn = sortSessDimByExpKey(fd,{'Rat' 'Drug' 'Session'})
%
%           ssn is now nRat x nDrug x nSession cell array of the sessions
%           found in fd.
%
% M = sdField2Mat(ssn,'ZoneDelay',@RRInit)
%
%           M is now nRat x nDrug x nSession x nTrials matrix of ZoneDelay
%           values.
%
% OPTIONAL ARGUMENTS:
% ******************
% maxSubsess (default 5)
%                       a scalar pre-allocating 5 subsessions per SSN
%                       directory in case of 4x20-like multiple-subsession
%                       experiments.
% postProcess (default {})
%                       a cell array of function handles that take as input
%                       an sd and return as first output an sd. After
%                       initializing, a list of these function handles can
%                       be run in series.
%
%
maxSubsess = 5;
postProcess = {};
process_varargin(varargin);

disp(['Pre-processing sessions in ' inputname(1) ' for field ' field '.'])
sz = size(ssn);
nT = nan(length(ssn(:)),maxSubsess);
nSubsess = nan(length(ssn(:)),1);
for iSSN=1:length(ssn(:))
    if ~isempty(ssn{iSSN})
        d = ssn{iSSN};
        disp(d);
        pushdir(d);
        sd = init;
        
        nSubsess(iSSN) = length(sd);
        for iS=1:length(sd)
            sd0 = sd(iS);
            for pp=1:length(postProcess)
                procFun = postProcess{pp};
                sd0 = procFun(sd0);
            end
            f = getfield(sd0,field);
            nT(iSSN,iS) = length(f);
        end
        
        popdir;
    end
end

M = nan([prod(sz) nSubsess max(nT)]);
disp(['Assembling matrix of ' field ' values.'])
for iSSN=1:length(ssn(:))
    if ~isempty(ssn{iSSN})
        d = ssn{iSSN};
        disp(d);
        pushdir(d);
        sd = init;
        nSubsess(iSSN) = length(sd);
        for iS=1:length(sd)
            sd0 = sd(iS);
            for pp=1:length(postProcess)
                procFun = postProcess{pp};
                sd0 = procFun(sd0);
            end
            f = getfield(sd0,field);
            M(iSSN,iS,1:length(f(:))) = f(:);
        end
        popdir;
    end
end

if nSubsess==1
    M = reshape(M,[sz max(nT)]);
else
    M = reshape(M,[sz nSubsess max(nT)]);
end