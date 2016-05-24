function B = basen(dec,base,sigfigs)
% Converts decimal number dec to a vector of its base-n representation:
%

if nargin<3
    str = dec2base(dec,base);
    sigfigs = length(str);
end

str = dec2base(dec,base,sigfigs);
n = max(sigfigs,length(str));

B = zeros(1,n);
for digit = length(str):-1:1;
    B(digit) = base2dec(str(digit),base);
end