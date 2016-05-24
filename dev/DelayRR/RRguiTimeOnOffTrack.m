function [Ton,Toff] = RRguiTimeOnOffTrack(nvtfn)
%
%
%
%

[x,y]=LoadVT_lumrg(nvtfn);
x = tsd(x.range,atan2(y.data,x.data));
clf
plot(x.range,x.data);
xlim([min(x.range) max(x.range)]);
ylim([min(x.data) max(x.data)]);
title(sprintf('Start of session\n(Right-click to try; left-click to confirm)'))

button = 3;
while button~=1
    [Ton,~,button]=ginput(1);
    clf
    plot(x.range,x.data);
    hold on
    plot([Ton Ton],[min(x.data) max(x.data)],'g-','linewidth',2)
    xlim([min(x.range) max(x.range)]);
    ylim([min(x.data) max(x.data)]);
    title(sprintf('Start of session\n(Right-click to try; left-click to confirm)'))
    hold off
end

clf
plot(x.range,x.data);
hold on
plot([Ton Ton],[min(x.data) max(x.data)],'g-','linewidth',2)
text(Ton,min(x.data),sprintf('%.3f',Ton));
xlim([min(x.range) max(x.range)]);
ylim([min(x.data) max(x.data)]);
title(sprintf('End of session\n(Right-click to try; left-click to confirm)'))
button = 3;
hold off
while button~=1
    [Toff,~,button]=ginput(1);
    clf
    plot(x.range,x.data);
    hold on
    plot([Ton Ton],[min(x.data) max(x.data)],'g-','linewidth',2)
    plot([Toff Toff],[min(x.data) max(x.data)],'r-','linewidth',2)
    xlim([min(x.range) max(x.range)]);
    ylim([min(x.data) max(x.data)]);
    title(sprintf('End of session\n(Right-click to try; left-click to confirm)'))
    hold off
end

clf
plot(x.range,x.data);
hold on
plot([Ton Ton],[min(x.data) max(x.data)],'g-','linewidth',2)
text(Ton,min(x.data),sprintf('%.3f',Ton));
plot([Toff Toff],[min(x.data) max(x.data)],'r-','linewidth',2)
text(Toff,min(x.data),sprintf('%.3f',Toff));

text(mean([Ton Toff]),max(x.data),sprintf('%.3fs',Toff-Ton));
xlim([min(x.range) max(x.range)]);
ylim([min(x.data) max(x.data)]);
hold off