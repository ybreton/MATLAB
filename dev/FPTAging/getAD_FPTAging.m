function AD = getAD_FPTAging(MasterSSNList,varargin)
%
%
%
%

nLaps = 20;
process_varargin(varargin);

AD = nan(size(MasterSSNList.DATA,1),1);
for f = 1 : size(MasterSSNList.DATA,1)
    pushdir(MasterSSNList.DATA{f,end});
    fn=FindFile('R*-DD.mat');
    sd = FPTInit(fn,'Spikes',false);
    D = DD_getDelays(sd,'nL',sd.TotalLaps);
    Laps = 1:length(D);
    [DD,LL] = DD_getDelays(sd);
    Last20 = LL(Laps>sd.TotalLaps-20);
    FD = mean(Last20);
    
    AD(f) = mean(LL);
    
    popdir;
end
