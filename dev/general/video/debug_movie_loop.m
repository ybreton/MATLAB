VW = VideoWriter('VTE_movie.mp4','MPEG-4');
VW.FrameRate = 30;
k = 1;
laps = 1:length(sd.EnteringCPTime);
highlaps = laps(idHi);
for pass = 1 : length(HighPassesIn)
    idPass = CheetahTime >= HighPassesIn(pass) & CheetahTime <= HighPassesOut(pass);
    lapnum = highlaps(pass);
    t = CheetahTime(idPass);
    x = sd.x.restrict(min(t),max(t)+1);
    y = sd.y.restrict(min(t),max(t)+1);
    Fr = FrameList(idPass);
    % Section showing trajectory
    for ifr = 1 : length(Fr)
        tFr = t(ifr);
        xFr = x.restrict(tFr-window,tFr);
        yFr = y.restrict(tFr-window,tFr);
        clf
        cla
        set(gca,'xlim',[0 720])
        set(gca,'ylim',[0 480])
        th=text(720/2,480,sprintf('VTE, lap %d',lapnum));
        set(th,'verticalalignment','top')
        set(th,'horizontalalignment','center')
        hold on
        imshow(F1)
        mx = cos(0:0.01:2*pi)*4;
        my = sin(0:0.01:2*pi)*4;
        for d = length(xFr.data):-1:1
            od = length(xFr.data)-d+1;
            x0 = xFr.data;
            x0 = x0(d);
            y0 = yFr.data;
            y0 = y0(d);
            ch = patch(mx+x0,my+y0,[1 1 1]);
            set(ch,'edgecolor','none')
            set(ch,'FaceAlpha',O(od))
        end
        hold off
        drawnow
        curFrame = getFrame;
        writeVideo(VW,curFrame)
        k = k+1;
    end
    clf
    cla
    set(gca,'xlim',[0 720])
    set(gca,'ylim',[0 480])
    th=text(720/2,480,sprintf('VTE, lap %d',lapnum));
    set(th,'verticalalignment','top')
    set(th,'horizontalalignment','center')
    hold on
    imshow(F1)
    curFrame = getFrame;
    for iti = 1 : VR.FrameRate
        writeVideo(VW,curFrame)
    end
    
    for ifr = 1 : length(Fr)
        tFr = t(ifr);
        xFr = x.restrict(tFr-window,tFr);
        yFr = y.restrict(tFr-window,tFr);
        clf
        cla
        set(gca,'xlim',[0 720])
        set(gca,'ylim',[0 480])
        th=text(720/2,480,sprintf('VTE, lap %d',lapnum));
        hold on
        F = read(VR,Fr(ifr));
        imshow(F)
        mx = cos(0:0.01:2*pi)*4;
        my = sin(0:0.01:2*pi)*4;
        for d = length(xFr.data):-1:1
            od = length(xFr.data)-d+1;
            x0 = xFr.data;
            x0 = x0(d);
            y0 = yFr.data;
            y0 = y0(d);
            ch = patch(mx+x0,my+y0,C(od,:));
            set(ch,'edgecolor','none')
            set(ch,'FaceAlpha',O(od))
        end
        hold on
        drawnow
        curFrame = getFrame;
        writeVideo(VW,curFrame)
        k = k+1;
    end
end