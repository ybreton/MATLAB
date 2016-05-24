function L = RRlinearizedVal(sd,t,x,y,varargin)
% Converts the (x,y) position obtained at time t to a linearized version L
% using the sd.Linearized data in sd.
% L = RRlinearizedVal(sd,t,x,y)

trialTypeField = 'stayGo';
trialTypeList = [0 1];
trialTypes = {'Skip' 'Stay'};
process_varargin(varargin);

Trl = tsd(sd.EnteringZoneTime(:),(1:length(sd.EnteringZoneTime))');
T = Trl.data(t);

sg = sd.(trialTypeField)(T);
id = trialTypeList==sg;
type = trialTypes{id};
S = sd.Linearized.(type);

I = nan(length(x),1);
D = (x-S.Zx).^2+(y-S.Zy).^2;
if any(~isnan(D(:)))
    [~,I] = min(D(:));
end
L = S.Zt(I);