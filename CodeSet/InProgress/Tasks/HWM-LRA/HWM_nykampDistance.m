function D = HWM_nykampDistance(sd, L0, L1, varargin)

% output = HWM_nykampDistance(sd, L0, L1, iL)
% inputs: sd
%   L0, L1 - start and end times for each lap
% 
% resamples each lap at nSampsPerLap 
% compares distance for corresponding points to minimumlengthlap

nSampsPerLap = 1000;
process_varargin(varargin);

[~,shortest] = min(L1-L0);

% create z
zT = sd.x.range;
xD = sd.x.data;
yD = sd.y.data;
ok = ~isnan(xD+yD);
z = tsd(zT(ok), [xD(ok) yD(ok)]);

% create zL
nLaps = length(L0);

zL = nan(nLaps, nSampsPerLap, 2);
for iL = 1:nLaps
    if ~isnan(L0(iL)+L1(iL))
        z0 = z.restrict(L0(iL), L1(iL));
        zL(iL,:,:) = z0.data(linspace(L0(iL), L1(iL), nSampsPerLap), 'extrapolate', nan);
    end
end

% calculate distance
D = zeros(nLaps,1);
for iL = 1:nLaps
    d0 = (zL(iL,:,:) - zL(shortest,:,:)).^2;
    D(iL) = nansum(d0(:));        
end

D = sqrt(D/nSampsPerLap/2);
