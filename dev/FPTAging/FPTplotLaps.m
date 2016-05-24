function ph = FPTplotLaps(sd)
%
%
%
%

cmap = jet(sd.TotalLaps);
ph = nan(sd.TotalLaps,1);
clf
hold on
for lap = 1 : sd.TotalLaps
    t1 = sd.EnteringCPTime(lap)-sd.Head.videoStart-sd.Head.offset;
    t2 = sd.ExitingCPTime(lap)-sd.Head.videoStart-sd.Head.offset;
    if isnan(t1)
        t1 = sd.ExpKeys.TimeOnTrack - sd.Head.videoStart - sd.Head.offset;
    end
    if isnan(t2)
        t2 = sd.ExpKeys.TimeOffTrack - sd.Head.videoStart - sd.Head.offset;
    end
    x0 = sd.Head.x.restrict(t1,t2);
    y0 = sd.Head.y.restrict(t1,t2);
    
    ph(lap) = plot(x0.data,y0.data,'-','color',cmap(lap,:));
    
end
hold off 