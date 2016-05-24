function playMPEG_NVT(mpgfn,XYmpg,XYnvt,offset)
VP = VideoPlayer(mpgfn);
fh = figure;
set(fh,'position',[1921,57,1280,948])
for iF = 1 : VP.NumFrames-4
    clf
    set(gca,'xlim',[0 VP.Width])
    set(gca,'ylim',[0 VP.Height])
    Fr = VP.getFrameAtNum(iF);
    t = floor((iF-1)*1/30*1000)/1000;
    imshow(Fr)
    hold on
    if iF<size(XYmpg.data,1)
        XY0 = XYmpg.restrict(min(XYmpg.range)+t-0.033,min(XYmpg.range)+t+0.033);
        D = XY0.data;
        plot(D(:,1),D(:,2),'mo')
    end
    if iF<size(XYnvt.data,1)
        XY0 = XYnvt.restrict(min(XYnvt.range)+t-0.033,min(XYnvt.range)+t+0.033);
        D = XY0.data;
        plot(D(:,1),D(:,2),'w+')
    end
    hold off
    drawnow
end