function [rate,pellets,IRI] = FPTGetReinfRate(fn,varargin)
% Produces a 3D matrix with rows and columns from fn and dim-3 of laps with
% the rate of reinforcement.
% [rate,pellets,IRI] = FPTGetReinfRate(fn)
%
%

nLaps = 200;
process_varargin(varargin);

rate = nan(size(fn,1),size(fn,2),nLaps);
pellets = rate;
IRI = rate;
np = 0;
for r = 1 : size(fn,1)
    for c = 1 : size(fn,2)
        if ~isempty(fn{r,c})
            fd = fileparts(fn{r,c});
            pushdir(fd);
            
            load(fn{r,c});
            feederFireTimes = sd.FeederTimes;
            feederFireTimes = feederFireTimes(sd.FeederSkip==0);
            interRewInt = diff([min(sd.x.range) feederFireTimes]);
            idLL = sd.ZoneIn==sd.DelayZone;
            pelletRatio = 10.^(abs(log10(sd.World.nPleft/sd.World.nPright)));
            
            nPellets = nan(1,length(interRewInt));
            nPellets(~idLL) = 1;
            nPellets(idLL) = pelletRatio;
            
            nL = min(length(interRewInt),length(nPellets));
            nPellets = nPellets(1:nL);
            ERR = nPellets(1:nL)./interRewInt(1:nL);
            rate(r,c,1:nL) = reshape(ERR,[1 1 nL]);
            pellets(r,c,1:nL) = reshape(nPellets,[1 1 nL]);
            IRI(r,c,1:nL) = reshape(interRewInt,[1 1 nL]);
            np = max(np,nL);
            popdir;
        end
    end
end
rate = rate(:,:,1:np);
pellets = pellets(:,:,1:np);
IRI = IRI(:,:,1:np);