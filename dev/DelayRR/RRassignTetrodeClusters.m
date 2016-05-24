function I = RRassignTetrodeClusters(sd,varargin)
% Returns an s x n logical of the n, sd.fn file names that correspond to each
% of the s structures in sd.ExpKeys.Target.
% I = RRassignTetrodeClusters(sd)
% where     I       is an s x n logical with sd.fn-to-target assignments
%
%           sd      is a standard session data structure.
%
% OPTIONAL ARGUMENTS:
% ******************
% fn        (default sd.fn)         field with cluster file names
% TTstr     (default '-TT')     is a string that specifies the prefix to
%                                   the tetrode number
% CLUdelim  (default '-')       is a string that specifies the delimiter
%                                   between the tetrode number and the
%                                   cluster number.
% 
% Notes:
% Support function to return a logical index of the sd.fn clusters that
% come from tetrodes that have been tagged as each of the targets in
% sd.ExpKeys.Target.
%
TTstr = '-TT';
CLUdelim = '-';
if isfield(sd,'fn')
    fn = sd.fn;
else
    fn = cell(0,1);
end
process_varargin(varargin);

if ~isempty(fn)
    TTs = RRassignTetrodes(sd,'fn',fn,'TTstr',TTstr,'CLUdelim',CLUdelim);
    idnan = isnan(TTs);
    fn = fn(~idnan);
    TTs = TTs(~idnan);
    

    uniqueTargets = unique(sd.ExpKeys.Target);
    I = false(length(uniqueTargets),length(fn));

    for iTT=1:length(TTs)
        for iTarget = 1 : length(uniqueTargets)
            Target = find(strcmpi(uniqueTargets{iTarget},sd.ExpKeys.Target));
            I(Target,iTT) = sd.ExpKeys.TetrodeTargets(TTs(iTT))==Target;
        end
    end
else
    I = [];
end