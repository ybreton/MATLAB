function sd = sdRRlinearize(sd,varargin)
% Linearize restaurant row for skips and stays separately. 
% 

nxbins = inf;
nybins = inf;
process_varargin(varargin);

for iS=1:numel(sd)
    sd0 = sd(iS);
    sd0.Linearized = RRlinearize(sd0,'nxbins',nxbins,'nybins',nybins);
    sd1(iS) = sd0;
end
sd = sd1;