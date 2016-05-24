function ADVolts = GetADVolts(fn)

% ADVolts = GetADVolts(fn)
%   Finds the ADVolts from the header of a file.
% INPUT:
%   fn -- filename
% OUTPUT:
%   ADVolts - number of AD volts per bit
%
% ADR 2014
 


H = ReadNewHeader(fn);
L = find(~cellfun(@isempty,strfind(H, '-ADBitVolts')));
[~,remain] = strtok(H{L});
ADVolts = str2double(remain);
