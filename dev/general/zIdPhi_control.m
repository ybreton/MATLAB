function sd = zIdPhi_control(sd,varargin)
% Control for zIdPhi by taking path from zone entry to VTEtime sec before
% zone entry (or feeder fire+consumption time for rewarded/previous zone
% entry+VTEtime), whichever is latest.
% Path begins either:
%       - VTEtime seconds before next zone entry if that is later than the
%       following conditions,
%           - consumptionTime seconds after feeder fire when reward is
%               delivered, or
%           - VTEtime seconds after zone entry when reward is not delivered
% Path ends just before entry into the next zone.
%
% sd = zIdPhi_control(sd)
% where     sd      is a standard session data structure
%
% OPTIONAL ARGUMENTS:
% ******************
% VTEtime   (default 3)     
%           number of seconds for which to take VTE control path
% consumptionTime (default 5)
%           number of seconds after reward that is "protected" (i.e., will
%           not be included in VTE control path)
% debug     (default true)
%           returns a histogram of control LogIdPhi values along with
%           skewness of distribution

VTEtime = 3;
consumptionTime=5;
debug=true;
process_varargin(varargin);

stayGo = ismember(sd.ExitZoneTime,sd.FeederTimes);

Next = sd.NextZoneTime-sd.x.dt;
Rew = nan(length(Next),1);
Rew(stayGo) = sd.FeederTimes+consumptionTime;
Rew(~stayGo) = sd.EnteringZoneTime(~stayGo)+VTEtime;

tend = Next(:);
tstart = max(Rew(:),tend-VTEtime);
tstart(1) = nan;
tend(end) = nan;

sd0 = sd;
sd0.EnteringCPTime = tstart;
sd0.ExitingCPTime = tend;
sd0 = zIdPhi(sd0);

sd.IdPhi_control = nan(length(sd.EnteringZoneTime),1);
sd.zIdPhi_control = nan(length(sd.EnteringZoneTime),1);
sd.IdPhi_control = sd0.IdPhi;
sd.zIdPhi_control = sd0.zIdPhi;

if debug
    idinf = sd0.IdPhi==0;
    idnan = isnan(sd0.IdPhi);
    [f,bin]=hist((log10(sd0.IdPhi(~idinf&~idnan))),ceil(sqrt(sum(~idinf(:)&~idnan(:)))));
    clf; 
    subplot(1,2,1)
    plot(sd.x.data,sd.y.data,'.','color',[0.8 0.8 0.8])
    hold on
    plot(data(sd.x.restrict(tstart,tend)),data(sd.y.restrict(tstart,tend)),'k.')
    hold off
    subplot(1,2,2)
    bar(bin,f/sum(f),1); 
    title(sprintf('%s\nSkew=%.1f',sd.ExpKeys.SSN,skewness(log10(sd0.IdPhi(~idinf&~idnan))))); drawnow
end