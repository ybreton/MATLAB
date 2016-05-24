function CreateFPTKeysAllSessions(varargin)
%2012-07-23 JJS
%   Runs CreateFPTKeys.m on all sessions within the directory.
numFiles = FindFiles('*Events.Nev');
start_day = 1;
end_day = length(numFiles);
process_varargin(varargin);
for iSess = start_day: end_day;
    pushdir(fileparts(numFiles{iSess}));
    SSN = GetSSN('SingleSession');
    disp(strcat('Creating Keys file for session_',SSN));
    CreateFPTKeys;
    popdir;
end