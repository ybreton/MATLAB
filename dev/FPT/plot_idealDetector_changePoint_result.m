function plot_idealDetector_changePoint_result(Choices,Delays,cp,minTime,tol)

CumChoices = tsd(Choices.range,cumsum(Choices.data));
id = Choices.data==1;
Delays.T = Delays.T(id);
Delays.D = Delays.D(id);
[FinalAlternation,pChoice,propSSN] = identify_final_alternation_phase(Choices,cp,'minTime',minTime,'B',tol);

cmap = jet(length(cp)-1);

fh = gcf;
clf
ah(1)=subplot(1,3,1);
% Plot choices
cla
hold on
p = ones(length(cp),1)*0.5;
for seg = 2 : length(cp)
    t0 = cp(seg-1)+1;
    t1 = cp(seg);
    segment = Choices.restrict(t0,t1);
    p(seg) = sum(segment.data)/length(segment.data);
    plot(segment.range,segment.data,'ko','markerfacecolor',cmap(seg-1,:))
    plot([t0 t1],[p(seg) p(seg)],'-','color',cmap(seg-1,:),'linewidth',3)
end
patchX = [min(Choices.range) min(Choices.range) max(Choices.range) max(Choices.range)];
patchY = [0.5-tol 0.5+tol 0.5+tol 0.5-tol];
ph = patch(patchX,patchY,[0.8 0.8 0.8],'facealpha',0.2,'edgecolor','none','facecolor',[0.8 0.8 0.8]);

CPidx = 1:length(cp);
if CPidx(FinalAlternation)-1>0
    FinalStart = cp(CPidx(FinalAlternation)-1)+1;
    FinalFinish = cp(FinalAlternation);
else
    FinalStart = nan;
    FinalFinish = nan;
end
if ~isnan(FinalStart)&&~isnan(FinalFinish)
    plot([FinalStart FinalFinish],[p(FinalAlternation) p(FinalAlternation)],'k-','linewidth',1)
end
xlabel('Lap')
ylabel('Choice')
set(gca,'ylim',[-0.05 1.05])
set(gca,'ytick',[0:0.1:1])
yticklabel = mat2can(0:0.1:1);
yticklabel{1} = 'Non-delayed';
yticklabel{end} = 'Delayed';
set(gca,'yticklabel',yticklabel)

hold off
ah(2)=subplot(1,3,2);
% Plot cumulative record
cla
hold on
for seg = 2 : length(cp)
    t0 = cp(seg-1);
    t1 = cp(seg);
    segment = CumChoices.restrict(t0,t1);
    stairs(segment.range,segment.data,'-','color',cmap(seg-1,:),'linewidth',3)
end
xlabel('Lap')
ylabel('Cumulative Record')
set(gca,'ylim',[0 max(CumChoices.data)+1])

hold off

ah(3)=subplot(1,3,3);
% Plot last delay
cla
hold on
for seg = 2 : length(cp)
    t0 = cp(seg-1);
    t1 = cp(seg);
    if any(logical(Choices.data))&any(~logical(Choices.data))
        try
            segment = Delays.restrict(t0,t1);
            plot(segment.range,segment.data,'-','color',cmap(seg-1,:),'linewidth',3)
        catch exception
            disp('Exception thrown when plotting the delay sequence.')
        end
    end
end
if any(FinalAlternation)
    cps = 1:length(FinalAlternation);
    start = cp(cps(FinalAlternation)-1)+1;
    finish = cp(FinalAlternation);
    delay = Delays.restrict(start,finish);
    meanDelay = mean(delay.data);
    plot([start finish],[meanDelay meanDelay],'k-')
end
xlabel('Lap')
ylabel('Chosen Delay')
set(ah(3),'ylim',[0 45])
hold off
