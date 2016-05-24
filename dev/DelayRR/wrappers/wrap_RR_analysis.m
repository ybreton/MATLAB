function COND = wrap_RR_analysis(AllSessions,condStr)
% Wrapper to produce a 1 x nSess structure array, with structure produced
% by wrap_RR_session, containing only sessions for which Condition is
% condStr.
% COND = wrap_RR_analysis(AllSessions,condStr)
% where     COND            is 1 x nSess structure array produced by
%                               wrap_RR_session.
%
%           AllSessions     is 1 x nSess structure array produced by
%                               wrap_RR_collectSess, which accumuluates structures
%                               produced by wrap_RR_session across sessions,
%           condStr         is a string identifying which condition to
%                               extract from AllSessions.
%
%

if isempty(AllSessions)
    disp('Collecting all sessions...')
    fn = FindFiles('RR-*.mat');
    fd = cell(length(fn),1);
    for f = 1 : length(fn); 
        fd{f} = fileparts(fn{f}); 
    end
    fd = unique(fd);
    AllSessions = wrap_RR_collectSess(fd);
end

conditions = cell(length(AllSessions),1);
for s = 1 : length(AllSessions)
    conditions{s} = AllSessions(s).sd.Condition;
end

idCOND = strcmp(conditions,condStr);
if any(idCOND)
    COND = AllSessions(idCOND);
else
    validStr = unique(conditions);
    if length(validStr)>1
        errorStr = 'Valid condition strings are ';
        for iCond = 1 : length(validStr)-1
            errorStr = [errorStr sprintf('%s, ',validStr{iCond})];
        end
        errorStr = [errorStr sprintf('and %s.',validStr{end})];
    else
        errorStr = ['Only valid condition string is ' validStr{1}];
    end
    error(errorStr);
end
