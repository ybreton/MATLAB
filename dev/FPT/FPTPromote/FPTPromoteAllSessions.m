function [] = FPTPromoteAllSessions( varargin )
%2012-07-16 JJS 
%   Promotes all FPT sessions within a directory. 
fd = FindFiles('*Events*');
start_day = 1;
end_day = length(fd);
process_varargin(varargin);

for iSess = start_day : end_day;
	fd{iSess} = fileparts(fd{iSess});
end
for iSess = start_day : end_day;
	pushdir(fd{iSess});
    FPTPromote;
    sprintf('%s', fileparts(fd{iSess}))
    popdir;
end
end

