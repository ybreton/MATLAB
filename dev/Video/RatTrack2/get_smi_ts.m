function [TS,T0] = get_smi_ts(smi)
%
%
%
%

% Time stamps need to be synchronized with .smi.
% .smi contains time stamps in microseconds. Multiply by 1e-6 for
% seconds.
SMI = import_ascii_text(smi);
idSYNC = cellfun(@(SMI) ~isempty(regexp(SMI,'<P Class=ENUSCC>','once')),SMI);
SYNClines = SMI(idSYNC);
T = nan(length(SYNClines),1);
T0 = nan(length(SYNClines),1);
parfor l = 1 : length(SYNClines)
    str = SYNClines{l};
    start = regexp(str,'<P Class=ENUSCC>','once')+16;
    stop  = regexp(str,'</SYNC>','once')-1;
    movStart = regexpi(str,'<SYNC Start=','once')+12;
    movEnd = regexpi(str,'<P Class=ENUSCC>','once')-2;
    movStr = str(movStart:movEnd);
    T0(l) = str2double(movStr);
    T(l) = str2double(str(start:stop));
end
[T,id] = sort(T);
TS = ts(T*1e-6);
T0 = ts(T0(id)/1000);