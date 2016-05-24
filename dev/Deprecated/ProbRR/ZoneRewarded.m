function Rew = ZoneRewarded(FireFeeder,ZoneIn,varargin)
%
%
%
%
ZF = 10;
process_varargin(varargin);

k = 0;
Rew = nan(1,length(ZoneIn));
for z = 1 : length(ZoneIn)
    if ZoneIn(z)<ZF
        k = k+1;
    end
    Rew(z) = FireFeeder(k);
end