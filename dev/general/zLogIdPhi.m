function sd = zLogIdPhi(sd,varargin)
% 
% 
IdPhiFcn = @zIdPhi;
IdPhiLo = 10;
process_varargin(varargin);

sd = IdPhiFcn(sd);

sd.LogIdPhi = log10(sd.IdPhi);
sd.LogIdPhi(sd.IdPhi<IdPhiLo) = nan;
sd.zLogIdPhi = nanzscore(sd.LogIdPhi);