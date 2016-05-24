function [Rat,SSN] = parseSSNlist(SSNs)
% Parses a list of SSN strings into rats and sessions.

Rat = cell(size(SSNs));
SSN = cell(size(SSNs));
SSNs = SSNs(:);

for iC=1:length(SSNs)
    [fd,ssn,ext] = fileparts(SSNs{iC});
    delim1 = regexp(ssn,'R');
    if isempty(delim1);delim1=0;end
    delim2 = regexpi(ssn,'-');
    if isempty(delim2);delim2=length(ssn);end
    
    idx = min(delim1):min(delim2)-1;
    
    SSN{iC} = ssn;
    Rat{iC} = ssn(idx);
end