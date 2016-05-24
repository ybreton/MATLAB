function [ D ] = NykampDistance( z, L0, L1, varargin)
% [ D ] = NykampDistance( z, L0, L1, varargin)
% z = tsd of nT x nD (e.g. [x y] or Q matrix)
% will restrict z to each lap, resample to nSampsPerLap and calculate the
% euclidean distance

nSampsPerLap = 1000;
varargin = process_varargin(varargin);

% check
assert(length(L0)==length(L1), 'lap ID mismatch');
assert(all(L1>L0), 'lapend < lapstart');

% go
nLaps = length(L0);
nD = size(z.data,2);

% generate zL matrix 
zL = nan(nLaps, nSampsPerLap, nD);
for iL = 1:nLaps
  z0 = z.restrict(L0(iL), L1(iL));
  zD = z0.data;
  
  if (~isempty(zD)) && (size(zD,1)>1) && (~all(isnan(zD(:))))	  
	  zL(iL,:,:) = interp1(z0.range, z0.data, ...
		  linspace(L0(iL), L1(iL), nSampsPerLap), 'linear', 'extrap');     
  end
end

% calculate D
D = zeros(nLaps);
for iL = 1:nLaps
	for jL = (iL+1):nLaps
        d0 = (zL(iL,:,:) - zL(jL,:,:)).^2;
        D(iL, jL) = sum(d0(:));        
	end
end
D = sqrt((D+D')/nSampsPerLap/nD);

end

