function H = ReadNewHeader(fn)
% H = ReadHeader(fp)
%  Reads new Cheetah header header
%  INPUT: 
%      fn -- filename
%  OUTPUT: 
%      H -- cell array.  Each entry is one line from the NSMA header
%
% ADR 2014

fp = fopen(fn, 'r');
if fp==-1
    error('Cannot open %s.\n', fn);
end
H = {};
while ftell(fp) < 16384
    H{end+1} = fgetl(fp);
end
end

