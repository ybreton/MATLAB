function PFN = IdentifyPFNs(sd,varargin)
% Produces a TF matrix of phasically firing neurons for target.
%

target = {'vStr' 'VS' 'NAc' 'NAs'}; % target name
LongISI = 2; % what constitutes a long ISI
pfnPropLong = 0.4; % minimum proportion of session spent in long ISIs
process_varargin(varargin);
if ischar(target)
    target = {target};
end
assert(isfield(sd.ExpKeys,'Target'),'sd must have fields ExpKeys and ExpKeys.Target.');

A = repmat(target(:)',[length(sd.ExpKeys.Target) 1]);
B = repmat(sd.ExpKeys.Target(:),[1 length(target(:))]);
id = any(strcmpi(A,B),2);
col = find(id);

I = RRassignTetrodeClusters(sd);
if ~isempty(I)
    Itarg = any(I(col,:),1)';

    S0 = sd.S(Itarg);

    p = nan(length(sd.S),1);
    p(Itarg) = propLongISI(S0,LongISI,sd.ExpKeys.TimeOffTrack-sd.ExpKeys.TimeOnTrack);
    PFN = p(:)>=pfnPropLong; % phasically-firing neurons
else
    PFN = [];
end