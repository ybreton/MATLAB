function [cscList,cscNums] = getCSCfn(region,keysFn,varargin)
% Loads keys, identifies tetrode numbers that correspond to region target(s)
% specified, and returns list of NCS file names that correspond.
% Only works on promoted/promotable data.
% [cscList,cscNums] = getCSCfn(region,keysFn,varargin)
% where     cscList         is a nFiles x 1 cell array of CSC file names
%           cscNums         is a nFiles x 1 double of CSC tetrode numbers
% 
%           region          is a nTargets x 1 cell array or string
%                               with the target names to match
%           keysFn          is a string with the keys file name
%
% CSC must be named with zero-padding for the program to work.
%
% OPTIONAL ARGUMENTS:
% ******************
% targetField       (default: Target)
%   Name of ExpKeys key with target information to match to any of those
%   listed in region
% tetrodeTargetsField   (default: TetrodeTargets)
%   Name of ExpKeys key with numeric assignments of targets to each tetrode
% CSCprefix         (default: *CSC)
%   Prefix of any CSC file names to look for
% CSCext            (default: *.ncs)
%   Extension of any CSC file names to look for
%

targetField = 'Target';
tetrodeTargetsField = 'TetrodeTargets';
CSCprefix = '*CSC';
CSCext = '*.ncs';
process_varargin(varargin);

if ischar(region)
    region = {region};
end

[d,f,x] = fileparts(keysFn);
if ~isempty(d)
    pushdir(d);
    disp(d);
end
disp([f x]);
eval(f);
Target = ExpKeys.(targetField); 

C1 = repmat(region(:)',length(Target(:)),1);
C2 = repmat(Target(:),1,length(region(:)'));

TargetNumbers = find(any(strcmpi(C1,C2),2));

tetrodeTargets = ExpKeys.(tetrodeTargetsField);

T1 = repmat(tetrodeTargets(:),1,length(TargetNumbers(:)'));
T2 = repmat(TargetNumbers(:)',length(tetrodeTargets(:)),1);

cscNums = find(any(T1==T2,2));

cscList = cell(length(cscNums),1);
for iNum=1:length(cscNums)
    searchStr = sprintf('%s%02d%s',CSCprefix,cscNums(iNum),CSCext);
    fn = FindFiles(searchStr,'CheckSubdirs',false);
    if ~isempty(fn)
        cscList(iNum,1:length(fn)) = fn(:)';
    else
        disp(['File not found: ' searchStr]);
    end
end
empty = cellfun(@isempty,cscList);
cscList = cscList(~empty);
cscList = unique(cscList);

if ~isempty(d)
    popdir;
end