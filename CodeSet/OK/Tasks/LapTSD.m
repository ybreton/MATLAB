function L = LapTSD(tsa, T)

%
% L = LapTSD(tsa, T)
% returns a tsd L such that it increases by 1 
% each time the time crosses T
%
% ADR v1.0 2012/06

assert(isa(tsa, 'ts'), 'Input must be a subclass of ts.');

nT = length(T);

tsaT = tsa.range;

LD = ones(size(tsaT));

for iT = 1:nT
	ix = tsaT>T(iT);
	LD(ix) = LD(ix)+1;
end

L = tsd(tsaT, LD);