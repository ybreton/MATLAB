function R = zLogIdPhi_Struct(R,grouping,varargin)
% Applies Z[Log[IdPhi]] to IdPhi data in R, z-scoring across each unique value
% of grouping.
% R = zLogIdPhi_Struct(R,grouping)
% where     R           is a structure with fields extracted from sd's using
%                       wrap_getSSNfields containing R.IdPhi
%   
%           grouping    is a field indicating how data ought to be grouped
%                       together for z-scoring.
%
% Example:
% >> R = wrap_getSSNfields(fd,{'RatNum' 'SessNum'},{'IdPhi'},@RRInit,'postProcess',{@zIdPhi})
% >> R = zLogIdPhi_Struct(R,R.RatNum)
%
% R.zLogIdPhi contains the Log[IdPhi] values, z-scored by rat.
%
%
minIdPhi = 1;
InitFcn = @RRInit;
postProcess = {@zIdPhi};
process_varargin(varargin);
if ~isfield(R,'IdPhi')
    fd = R.directories(:);
    empty = cellfun(@isempty,fd);
    fd = unique(fd(~empty));
    warning('IdPhi not found; adding field to structure...')
    M = getFieldFromSSNs(R.fdSorted,{'IdPhi'},InitFcn,'postProcess',postProcess);
    R.IdPhi = M;
end

IdPhi = R.IdPhi;
IdPhi(IdPhi<minIdPhi) = nan;

LogIdPhi = log10(IdPhi);
R.zLogIdPhi = nan(size(LogIdPhi));

if ischar(grouping)
    grouping = R.(grouping);
end

if isstruct(grouping)
    G = fieldnames(grouping);
    G = G(~ismember(G,{'Names'}));
    for iG=1:length(G)
        id = R.grouping.(G{iG})==1;
        m = nanmean(LogIdPhi(id));
        s = nanstd(LogIdPhi(id));
        z = (LogIdPhi(id)-m)./(s+eps);
        R.zLogIdPhi(id) = z;
    end
else
    G = unique(grouping(isOK(grouping)));
    for iG=1:length(G)
        id = grouping==G(iG);

        m = nanmean(LogIdPhi(id));
        s = nanstd(LogIdPhi(id));
        z = (LogIdPhi(id)-m)./(s+eps);

        R.zLogIdPhi(id) = z;
    end
end