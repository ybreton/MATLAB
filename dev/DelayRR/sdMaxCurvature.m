function sd = sdMaxCurvature(sd,varargin)
% Adds fields
%   .curvmax        with curvature value at maximum,
%   .curvtime       with time of maximum curvature,
% to standard session data structure.
% Maximum is taken over all curvature values from zone entry to the first
% of zone entry+window and zone exit.
%

debug=false;
window=5;
process_varargin(varargin);

C = sd.C;
sd.curvmax = nan(length(sd.EnteringZoneTime),1);
sd.curvtime = nan(length(sd.EnteringZoneTime),1);
for iTrl=1:length(sd.EnteringCPTime)
    t1 = sd.EnteringZoneTime(iTrl);
    t2 = min(sd.EnteringZoneTime(iTrl)+window,sd.ExitZoneTime(iTrl)-C.dt);
    
    c = C.restrict(t1,t2);
    d = c.data;
    t = c.range;
    if ~isempty(d)
        [m,I] = max(d);
        sd.curvmax(iTrl) = m;
        sd.curvtime(iTrl) = t(I);
        if debug
            clf
            hold on
            plot(sd.x.data,sd.y.data,'k.');
            scatterplotc(sd.x.data(t),sd.y.data(t),d,'plotchar','.')
            plot(sd.x.data(t(I)),sd.y.data(t(I)),'ro');
            colorbar;
            hold off
            set(gca,'xtick',[])
            set(gca,'ytick',[])
            title(sprintf('Trial %.0f',iTrl));
            drawnow
            pause(1)
        end
    end
end
