function keep = plot_session_CPpasses(sd,varargin)
% Plots the choice-point passes of each potential VTE instance, in
% sequence, with all zone passes underlain.
% keep = plot_session_CPpasses(sd)
% where     keep        is an n x 1 vector of trials on which VTE is
%                           believed to have occurred.
%
%           sd          is a 1 x 1 standard session data structure from
%                           RRInit. To plot sd's with subsessions, enter
%                           argument sd(iSubsess), where iSubsess is the
%                           subsession to visualize.
%
% OPTIONAL ARGUMENTS:
% ******************
% VTEtime   (default 3)     number of seconds following zone entry for VTE
% VTEthresh (default 5)     maximum LnIdPhi value to consider non-VTE
% flavours  (default {'Cherry' 'Banana' 'Plain White' 'Chocolate'})
%                           list of zone flavours
% smooth    (default true)  smoothes the path.
%
%

VTEtime = 3;
VTEthresh = 5.0;
flavours = {'Cherry' 'Banana' 'Plain White' 'Chocolate'};
smooth = false;
process_varargin(varargin);

if smooth
    sd = SmoothPath(sd);
end

sd.ExitingCPTime = sd.EnteringCPTime+VTEtime;

sd = zIdPhi(sd);
sd.LnIdPhi = log(sd.IdPhi);
sd.LnIdPhi(isinf(sd.LnIdPhi)) = nan;

VTEtrials = find(sd.LnIdPhi>VTEthresh);
VTElaps = floor(VTEtrials/length(flavours))+1;

SSN = sd.ExpKeys.SSN;
figure;
keep = nan(length(VTEtrials),1);
for iVTE = 1 : length(VTEtrials)
    trial = VTEtrials(iVTE);
    lap = VTElaps(iVTE);
    
    zone = sd.ZoneIn(trial);
    LnIdPhi = sd.LnIdPhi(trial);
    
    idZone = sd.ZoneIn==zone;
    zoneTrials = find(idZone);
    enteringTimes = sd.EnteringZoneTime(idZone);
    exitingTimes = sd.EnteringZoneTime(idZone)+VTEtime;
    
    clf
    hold on
    for iZ = 1 : length(exitingTimes)
        x0 = sd.x.restrict(enteringTimes(iZ),exitingTimes(iZ));
        y0 = sd.y.restrict(enteringTimes(iZ),exitingTimes(iZ));
        ph=plot(x0.data,y0.data,'-','color',[0.8 0.8 0.8],'linewidth',1);
        drawnow
    end
    
    x1 = sd.x.restrict(sd.EnteringZoneTime(trial),sd.EnteringZoneTime(trial)+VTEtime);
    y1 = sd.y.restrict(sd.EnteringZoneTime(trial),sd.EnteringZoneTime(trial)+VTEtime);
    ph(2)=plot(x1.data,y0.data,'r-','linewidth',2);
    drawnow
    hold off
    title(flavours{zone})
    set(gca,'xcolor','w')
    set(gca,'xtick',[])
    set(gca,'ycolor','w')
    set(gca,'ytick',[])
    legendStr{1} = sprintf('All passes, %s',SSN);
    legendStr{2} = sprintf('Lap %d (trial %d), Ln[Id\\phi]=%.2f',lap,trial,LnIdPhi);
    legend(ph,legendStr)
    drawnow
    inStr = input('[K]eep?','s');
    if strcmpi(inStr,'K')
        keep(iVTE) = trial;
        saveas(gcf,sprintf('%s-CPpasses-trial%d.fig',SSN,trial),'fig')
    end
end