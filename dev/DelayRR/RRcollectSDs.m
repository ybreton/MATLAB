function sdList = RRcollectSDs(fd)
% Collects SDs into a single cell array of sd's.
%
%
%

if nargin<1
    fn = FindFiles('RR-*.mat');
    fd = cell(length(fn),1);
    for iF=1:length(fn); fd{iF}=fileparts(fn{iF}); end;
    fd = unique(fd);
end

nTrls = nan(length(fd),1);
sdList = cell(length(fd),1);
for iD = 1 : length(fd)
    pushdir(fd{iD});
    disp(fd{iD});
    
    sd = RRInit;
    sd.x = sd.x.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);
    sd.y = sd.y.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);
    [sd.x,sd.y] = RRcentreMaze(sd);
    
    sd = RRFindQuadrant(sd);
    sd = RRrotateXYalign(sd);
    
    sd.nTrials = length(sd.ZoneIn);
    
    sdList{iD} = sd;
    popdir;
end